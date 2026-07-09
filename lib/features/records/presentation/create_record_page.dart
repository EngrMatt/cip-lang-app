import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../audio/widgets/audio_capture_section.dart';
import '../../camera/widgets/photo_capture_section.dart';
import '../../input/widgets/indigenous_accessory_bar.dart';
import '../providers/create_record_notifier.dart';

class CreateRecordPage extends ConsumerStatefulWidget {
  const CreateRecordPage({super.key, this.draftId});

  final String? draftId;

  @override
  ConsumerState<CreateRecordPage> createState() => _CreateRecordPageState();
}

class _CreateRecordPageState extends ConsumerState<CreateRecordPage> {
  static const _stepLabels = ['基本資料', '錄音', '拍照', '確認上傳'];

  @override
  void initState() {
    super.initState();
    if (widget.draftId != null) {
      Future.microtask(() {
        ref.read(createRecordProvider.notifier).loadDraft(widget.draftId!);
      });
    }
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(createRecordProvider);
    if (!state.hasContent || state.isUploading) return true;

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('儲存草稿？'),
        content: const Text('離開前是否儲存目前進度為草稿？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('不儲存'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('儲存草稿'),
          ),
        ],
      ),
    );

    if (save == true) {
      await ref.read(createRecordProvider.notifier).saveDraft();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRecordProvider);
    final notifier = ref.read(createRecordProvider.notifier);
    final stepIndex = state.step.index;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          notifier.reset();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('新增語料'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                notifier.reset();
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: List.generate(_stepLabels.length, (index) {
                  final active = index <= stepIndex;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < _stepLabels.length - 1 ? 8 : 0,
                      ),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: active ? 1 : 0,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepLabels[index],
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: active
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.outline,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: switch (state.step) {
                  CreateRecordStep.form =>
                    _FormStep(state: state, notifier: notifier),
                  CreateRecordStep.audio => const AudioCaptureSection(),
                  CreateRecordStep.photo => const PhotoCaptureSection(),
                  CreateRecordStep.review => _ReviewStep(state: state),
                },
              ),
            ),
            if (state.uploadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.uploadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.isUploading && state.uploadStatusLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.uploadStatusLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (state.uploadProgress != null) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: state.uploadProgress),
                    ],
                  ],
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _BottomActions(
                  state: state,
                  notifier: notifier,
                  onSubmitted: (id) {
                    if (id != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('上傳成功')),
                      );
                      // 先關閉 wizard，再 push 詳情頁，返回鍵才能回到列表
                      context.pop();
                      if (context.mounted) {
                        context.push('/records/$id');
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormStep extends StatelessWidget {
  const _FormStep({required this.state, required this.notifier});

  final CreateRecordState state;
  final CreateRecordNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('基本資料', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            IndigenousTextField(
              key: ValueKey('title-${state.draftId ?? 'new'}'),
              label: '語料標題 *',
              hint: '輸入標題',
              initialValue: state.title,
              onChanged: notifier.setTitle,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.category,
              decoration: const InputDecoration(labelText: '語料類型 *'),
              items: AppConfig.recordCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) notifier.setCategory(v);
              },
            ),
            const SizedBox(height: 16),
            IndigenousTextField(
              key: ValueKey('note-${state.draftId ?? 'new'}'),
              label: '備註',
              hint: '選填',
              initialValue: state.note,
              maxLines: 3,
              onChanged: notifier.setNote,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.state});

  final CreateRecordState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('確認上傳', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _ReviewRow(label: '標題', value: state.title),
            _ReviewRow(label: '類型', value: state.category),
            if (state.note.isNotEmpty)
              _ReviewRow(label: '備註', value: state.note),
            _ReviewRow(
              label: '錄音',
              value: state.audioPath != null ? '已錄製' : '尚未錄製',
            ),
            _ReviewRow(
              label: '照片',
              value: state.imagePath != null ? '已拍攝' : '未拍攝（選填）',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.state,
    required this.notifier,
    required this.onSubmitted,
  });

  final CreateRecordState state;
  final CreateRecordNotifier notifier;
  final void Function(int? id) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (state.step != CreateRecordStep.form)
          Expanded(
            child: OutlinedButton(
              onPressed: state.isUploading
                  ? null
                  : () {
                      final prev =
                          CreateRecordStep.values[state.step.index - 1];
                      notifier.goToStep(prev);
                    },
              child: const Text('上一步'),
            ),
          ),
        if (state.step != CreateRecordStep.form) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: state.isUploading ? null : () => _onPrimary(context),
            child: state.isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_primaryLabel),
          ),
        ),
      ],
    );
  }

  String get _primaryLabel => switch (state.step) {
        CreateRecordStep.form => '下一步：錄音',
        CreateRecordStep.audio => '下一步：拍照',
        CreateRecordStep.photo => '下一步：確認',
        CreateRecordStep.review => '上傳',
      };

  Future<void> _onPrimary(BuildContext context) async {
    switch (state.step) {
      case CreateRecordStep.form:
        notifier.nextFromForm();
      case CreateRecordStep.audio:
        if (state.audioPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('請先完成錄音')),
          );
          return;
        }
        notifier.nextFromAudio();
      case CreateRecordStep.photo:
        notifier.nextFromPhoto();
      case CreateRecordStep.review:
        final id = await notifier.submit();
        onSubmitted(id);
    }
  }
}
