import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/record_repository.dart';
import 'records_providers.dart';

enum CreateRecordStep { form, audio, photo, review }

class CreateRecordState {
  const CreateRecordState({
    this.step = CreateRecordStep.form,
    this.title = '',
    this.category = '錄音',
    this.note = '',
    this.audioPath,
    this.imagePath,
    this.isUploading = false,
    this.uploadError,
  });

  final CreateRecordStep step;
  final String title;
  final String category;
  final String note;
  final String? audioPath;
  final String? imagePath;
  final bool isUploading;
  final String? uploadError;

  CreateRecordState copyWith({
    CreateRecordStep? step,
    String? title,
    String? category,
    String? note,
    String? audioPath,
    bool clearAudio = false,
    String? imagePath,
    bool clearImage = false,
    bool? isUploading,
    String? uploadError,
    bool clearError = false,
  }) {
    return CreateRecordState(
      step: step ?? this.step,
      title: title ?? this.title,
      category: category ?? this.category,
      note: note ?? this.note,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearError ? null : (uploadError ?? this.uploadError),
    );
  }
}

final createRecordProvider =
    NotifierProvider<CreateRecordNotifier, CreateRecordState>(
  CreateRecordNotifier.new,
);

class CreateRecordNotifier extends Notifier<CreateRecordState> {
  @override
  CreateRecordState build() => const CreateRecordState();

  void setTitle(String value) => state = state.copyWith(title: value);
  void setCategory(String value) => state = state.copyWith(category: value);
  void setNote(String value) => state = state.copyWith(note: value);
  void setAudioPath(String? path) =>
      state = state.copyWith(audioPath: path, clearAudio: path == null);
  void setImagePath(String? path) =>
      state = state.copyWith(imagePath: path, clearImage: path == null);

  bool validateForm() =>
      state.title.trim().isNotEmpty && state.category.isNotEmpty;

  void goToStep(CreateRecordStep step) =>
      state = state.copyWith(step: step, clearError: true);

  void nextFromForm() {
    if (!validateForm()) {
      state = state.copyWith(uploadError: '請填寫標題與類型');
      return;
    }
    goToStep(CreateRecordStep.audio);
  }

  void nextFromAudio() => goToStep(CreateRecordStep.photo);
  void nextFromPhoto() => goToStep(CreateRecordStep.review);

  Future<int?> submit() async {
    if (!validateForm()) {
      state = state.copyWith(uploadError: '請填寫標題與類型');
      return null;
    }
    if (state.audioPath == null) {
      state = state.copyWith(uploadError: '請完成錄音後再上傳');
      return null;
    }

    state = state.copyWith(isUploading: true, clearError: true);
    final repo = ref.read(recordRepositoryProvider);

    try {
      final record = await repo.createRecord(
        title: state.title.trim(),
        category: state.category,
        note: state.note.trim().isEmpty ? null : state.note.trim(),
      );

      final audioUrl = await repo.uploadAudio(
        recordId: record.id,
        audioFile: File(state.audioPath!),
      );

      String? imageUrl;
      if (state.imagePath != null) {
        imageUrl = await repo.uploadImage(
          recordId: record.id,
          imageFile: File(state.imagePath!),
        );
      }

      await repo.updateRecordUrls(
        recordId: record.id,
        audioUrl: audioUrl,
        imageUrl: imageUrl,
      );

      state = const CreateRecordState();
      ref.invalidate(recordsListProvider);
      return record.id;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadError: e.toString().replaceFirst('AppException: ', ''),
      );
      return null;
    }
  }

  void reset() => state = const CreateRecordState();
}
