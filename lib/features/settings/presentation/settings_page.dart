import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_settings_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/surveyor_profile_provider.dart';
import '../../records/data/record_repository.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _apiController;
  bool _isSavingApi = false;
  bool _isTestingApi = false;
  String? _apiMessage;

  @override
  void initState() {
    super.initState();
    _apiController = TextEditingController();
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  void _syncApiField(String url) {
    if (_apiController.text != url) {
      _apiController.text = url;
    }
  }

  Future<void> _saveApi() async {
    setState(() {
      _isSavingApi = true;
      _apiMessage = null;
    });
    try {
      await ref.read(apiBaseUrlProvider.notifier).save(_apiController.text);
      if (mounted) {
        setState(() => _apiMessage = 'API 網址已儲存');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _apiMessage = e.toString().replaceFirst('ArgumentError: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSavingApi = false);
    }
  }

  Future<void> _testApi() async {
    setState(() {
      _isTestingApi = true;
      _apiMessage = null;
    });
    try {
      await ref.read(apiBaseUrlProvider.notifier).save(_apiController.text);
      final ok = await ref.read(recordRepositoryProvider).checkHealth();
      if (mounted) {
        setState(() => _apiMessage = ok ? '連線成功' : '連線失敗，請確認網址與後端狀態');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiMessage = e.toString().replaceFirst('AppException: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isTestingApi = false);
    }
  }

  Future<void> _resetApi() async {
    await ref.read(apiBaseUrlProvider.notifier).resetToDefault();
    final url = ref.read(apiBaseUrlProvider).valueOrNull ?? AppConfig.defaultApiBaseUrl;
    _syncApiField(url);
    if (mounted) {
      setState(() => _apiMessage = '已恢復預設 API');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登出'),
        content: const Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('登出'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyor = ref.watch(surveyorProfileProvider).valueOrNull;
    final apiUrl = ref.watch(apiBaseUrlProvider);

    apiUrl.whenData(_syncApiField);

    return WeaveBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('設定', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '調查員',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (surveyor != null) ...[
                    Text(surveyor.name, style: theme.textTheme.titleLarge),
                    if (surveyor.region != null)
                      Text(
                        surveyor.region!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ] else
                    Text(
                      '尚未簽到',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/checkin'),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('切換調查員'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API 連線',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'https://cip-lang-test-20260624.nfs.tw',
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  if (_apiMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _apiMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _apiMessage == '連線成功' ||
                                _apiMessage == 'API 網址已儲存' ||
                                _apiMessage == '已恢復預設 API'
                            ? AppColors.secondary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSavingApi ? null : _saveApi,
                          child: _isSavingApi
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('儲存'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isTestingApi ? null : _testApi,
                          child: _isTestingApi
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('測試連線'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetApi,
                      child: const Text('恢復預設'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _logout,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('登出'),
            ),
          ],
        ),
      ),
    );
  }
}
