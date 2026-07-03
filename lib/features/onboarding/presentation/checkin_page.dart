import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_brand_logo.dart';
import '../../../core/widgets/layered_background.dart';
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
      backgroundColor: Colors.white,
      body: LayeredAuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.07),
                      AppBrandLogo(
                        height: 104,
                        width: constraints.maxWidth,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '田野語料採集',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '調查員簽到後開始採集語料',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                                fillColor: Color(0xFFF8FAF9),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18),
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
                                fillColor: Color(0xFFF8FAF9),
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
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: AppColors.secondary,
                              ),
                              child: const Text('進入採集系統'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
