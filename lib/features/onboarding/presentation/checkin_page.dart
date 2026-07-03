import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/surveyor_profile.dart';
import '../providers/surveyor_profile_provider.dart';

class CheckinPage extends ConsumerStatefulWidget {
  const CheckinPage({super.key});

  @override
  ConsumerState<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends ConsumerState<CheckinPage> {
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefill);
  }

  void _prefill() {
    final profile = ref.read(surveyorProfileProvider).valueOrNull;
    if (profile != null && mounted) {
      _nameController.text = profile.name;
      _regionController.text = profile.region ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '請輸入調查員姓名');
      return;
    }
    final region = _regionController.text.trim();
    await ref.read(surveyorProfileProvider.notifier).save(
          SurveyorProfile(
            name: name,
            region: region.isEmpty ? null : region,
          ),
        );
    if (mounted) context.go('/records');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: WeaveBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('田野語料採集', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      '調查員簽到後開始採集語料',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '調查員姓名 *',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: '請輸入您的姓名',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '調查地區',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _regionController,
                            decoration: const InputDecoration(
                              hintText: '例如：花蓮縣秀林鄉',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _submit,
                            child: const Text('進入採集系統'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
