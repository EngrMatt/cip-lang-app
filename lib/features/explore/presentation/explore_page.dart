import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WeaveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('探索', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '地圖與語族分布（Phase 2）',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GlassCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text('田野地圖即將推出', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '將整合採集點位、語族分布與離線地圖瀏覽。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
