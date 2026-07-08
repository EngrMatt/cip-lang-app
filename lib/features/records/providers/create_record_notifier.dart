import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../drafts/data/draft_storage.dart';
import '../../drafts/models/record_draft.dart';
import '../../drafts/providers/draft_providers.dart';
import '../../explore/providers/map_records_provider.dart';
import '../../location/location_service.dart';
import '../../onboarding/models/surveyor_profile.dart';
import '../../onboarding/providers/surveyor_profile_provider.dart';
import '../data/record_repository.dart';
import 'records_providers.dart';

enum CreateRecordStep { form, audio, photo, review }

enum UploadPhase { idle, creating, uploadingAudio, uploadingImage, done }

class CreateRecordState {
  const CreateRecordState({
    this.draftId,
    this.step = CreateRecordStep.form,
    this.title = '',
    this.category = '錄音',
    this.note = '',
    this.audioPath,
    this.imagePath,
    this.isUploading = false,
    this.uploadPhase = UploadPhase.idle,
    this.uploadProgress,
    this.uploadError,
  });

  final String? draftId;
  final CreateRecordStep step;
  final String title;
  final String category;
  final String note;
  final String? audioPath;
  final String? imagePath;
  final bool isUploading;
  final UploadPhase uploadPhase;
  final double? uploadProgress;
  final String? uploadError;

  bool get hasContent =>
      title.trim().isNotEmpty ||
      note.trim().isNotEmpty ||
      audioPath != null ||
      imagePath != null;

  CreateRecordState copyWith({
    String? draftId,
    CreateRecordStep? step,
    String? title,
    String? category,
    String? note,
    String? audioPath,
    bool clearAudio = false,
    String? imagePath,
    bool clearImage = false,
    bool? isUploading,
    UploadPhase? uploadPhase,
    double? uploadProgress,
    bool clearProgress = false,
    String? uploadError,
    bool clearError = false,
  }) {
    return CreateRecordState(
      draftId: draftId ?? this.draftId,
      step: step ?? this.step,
      title: title ?? this.title,
      category: category ?? this.category,
      note: note ?? this.note,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isUploading: isUploading ?? this.isUploading,
      uploadPhase: uploadPhase ?? this.uploadPhase,
      uploadProgress:
          clearProgress ? null : (uploadProgress ?? this.uploadProgress),
      uploadError: clearError ? null : (uploadError ?? this.uploadError),
    );
  }

  String get uploadStatusLabel => switch (uploadPhase) {
        UploadPhase.creating => '建立語料紀錄…',
        UploadPhase.uploadingAudio => '上傳錄音…',
        UploadPhase.uploadingImage => '上傳照片…',
        UploadPhase.done => '完成',
        UploadPhase.idle => '',
      };
}

final createRecordProvider =
    NotifierProvider<CreateRecordNotifier, CreateRecordState>(
  CreateRecordNotifier.new,
);

class CreateRecordNotifier extends Notifier<CreateRecordState> {
  static const _uuid = Uuid();

  @override
  CreateRecordState build() => const CreateRecordState();

  void setTitle(String value) {
    state = state.copyWith(title: value);
    _autoSaveDraft();
  }

  void setCategory(String value) {
    state = state.copyWith(category: value);
    _autoSaveDraft();
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
    _autoSaveDraft();
  }

  void setAudioPath(String? path) {
    state = state.copyWith(audioPath: path, clearAudio: path == null);
    _autoSaveDraft();
  }

  void setImagePath(String? path) {
    state = state.copyWith(imagePath: path, clearImage: path == null);
    _autoSaveDraft();
  }

  bool validateForm() =>
      state.title.trim().isNotEmpty && state.category.isNotEmpty;

  void goToStep(CreateRecordStep step) {
    state = state.copyWith(step: step, clearError: true);
    _autoSaveDraft();
  }

  void nextFromForm() {
    if (!validateForm()) {
      state = state.copyWith(uploadError: '請填寫標題與類型');
      return;
    }
    goToStep(CreateRecordStep.audio);
  }

  void nextFromAudio() => goToStep(CreateRecordStep.photo);
  void nextFromPhoto() => goToStep(CreateRecordStep.review);

  Future<void> loadDraft(String id) async {
    final draft = DraftStorage.get(id);
    if (draft == null) return;

    state = CreateRecordState(
      draftId: draft.id,
      step: CreateRecordStep.values[draft.stepIndex.clamp(0, 3)],
      title: draft.title,
      category: draft.category,
      note: draft.note,
      audioPath: draft.audioPath,
      imagePath: draft.imagePath,
    );
  }

  Future<void> saveDraft() async {
    if (!state.hasContent) return;

    final id = state.draftId ?? _uuid.v4();
    var audioPath = state.audioPath;
    var imagePath = state.imagePath;
    final tempDir = await getTemporaryDirectory();

    if (audioPath != null && audioPath.startsWith(tempDir.path)) {
      audioPath = await DraftStorage.persistMediaFile(audioPath, 'audio');
    }
    if (imagePath != null && imagePath.startsWith(tempDir.path)) {
      imagePath = await DraftStorage.persistMediaFile(imagePath, 'image');
    }

    final draft = RecordDraft(
      id: id,
      title: state.title,
      category: state.category,
      note: state.note,
      audioPath: audioPath,
      imagePath: imagePath,
      stepIndex: state.step.index,
      updatedAt: DateTime.now(),
    );
    await DraftStorage.save(draft);
    state = state.copyWith(
      draftId: id,
      audioPath: audioPath ?? state.audioPath,
      imagePath: imagePath ?? state.imagePath,
    );
    refreshDraftsFromRef(ref);
  }

  Future<void> deleteDraft() async {
    final id = state.draftId;
    if (id != null) {
      await DraftStorage.delete(id);
      refreshDraftsFromRef(ref);
    }
  }

  void _autoSaveDraft() {
    if (state.hasContent) {
      Future.microtask(saveDraft);
    }
  }

  /// 依 docs/api.md：POST /records → POST /upload/audio → POST /upload/image（選填）
  Future<int?> submit() async {
    if (!validateForm()) {
      state = state.copyWith(uploadError: '請填寫標題與類型');
      return null;
    }
    if (state.audioPath == null) {
      state = state.copyWith(uploadError: '請完成錄音後再上傳');
      return null;
    }

    state = state.copyWith(
      isUploading: true,
      clearError: true,
      clearProgress: true,
      uploadPhase: UploadPhase.creating,
    );
    final repo = ref.read(recordRepositoryProvider);
    final locationService = LocationService();

    try {
      final profile = ref.read(surveyorProfileProvider).valueOrNull;
      final userNote = state.note.trim().isEmpty ? null : state.note.trim();
      final note = profile != null
          ? mergeNoteWithSurveyorPrefix(profile: profile, userNote: userNote)
          : userNote;

      final coords = await locationService.getCurrentPosition();

      final record = await repo.createRecord(
        title: state.title.trim(),
        category: state.category,
        note: note,
        latitude: coords?.latitude,
        longitude: coords?.longitude,
      );

      state = state.copyWith(uploadPhase: UploadPhase.uploadingAudio);
      await repo.uploadAudio(
        recordId: record.id,
        audioFile: File(state.audioPath!),
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
          }
        },
      );

      if (state.imagePath != null) {
        state = state.copyWith(
          uploadPhase: UploadPhase.uploadingImage,
          clearProgress: true,
        );
        await repo.uploadImage(
          recordId: record.id,
          imageFile: File(state.imagePath!),
          onProgress: (sent, total) {
            if (total > 0) {
              state = state.copyWith(uploadProgress: sent / total);
            }
          },
        );
      }

      final draftId = state.draftId;
      state = const CreateRecordState();
      if (draftId != null) {
        await DraftStorage.delete(draftId);
        refreshDraftsFromRef(ref);
      }
      ref.invalidate(recordsListProvider);
      ref.invalidate(recordDetailProvider(record.id));
      invalidateMapRecords(ref);
      return record.id;
    } catch (e) {
      final message = e.toString().replaceFirst('AppException: ', '');
      state = state.copyWith(
        isUploading: false,
        uploadPhase: UploadPhase.idle,
        clearProgress: true,
        uploadError: message,
      );
      return null;
    }
  }

  void reset() => state = const CreateRecordState();
}
