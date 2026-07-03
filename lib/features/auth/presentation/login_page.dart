import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/layered_background.dart';
import '../../onboarding/providers/surveyor_profile_provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    await ref.read(authProvider.notifier).loginBypass();
    if (!mounted) return;

    final hasProfile = ref.read(surveyorProfileProvider).valueOrNull != null;
    context.go(hasProfile ? '/records' : '/checkin');
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
                      SizedBox(height: constraints.maxHeight * 0.11),
                      _BrandMark(),
                      const SizedBox(height: 28),
                      _LoginCard(
                        idController: _idController,
                        passwordController: _passwordController,
                        remember: _remember,
                        onRememberChanged: (v) =>
                            setState(() => _remember = v ?? true),
                        onEnter: _enter,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '新調查員？申請存取權限',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Icon(
        Icons.account_balance_outlined,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.idController,
    required this.passwordController,
    required this.remember,
    required this.onRememberChanged,
    required this.onEnter,
  });

  final TextEditingController idController;
  final TextEditingController passwordController;
  final bool remember;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
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
          _FieldLabel('調查員編號', theme: theme),
          const SizedBox(height: 8),
          TextField(
            controller: idController,
            decoration: const InputDecoration(
              hintText: 'investigator@archive.org',
              prefixIcon: Icon(Icons.alternate_email_outlined, size: 22),
              fillColor: Color(0xFFF8FAF9),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _FieldLabel('通行密碼', theme: theme),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline, size: 22),
              fillColor: Color(0xFFF8FAF9),
            ),
            obscureText: true,
            onSubmitted: (_) => onEnter(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 36,
                width: 36,
                child: Checkbox(
                  value: remember,
                  onChanged: onRememberChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Text(
                '記住我',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('忘記密碼？'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onEnter,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('進入系統'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onEnter,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('暫時跳過登入'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}
