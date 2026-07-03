import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../drafts/providers/draft_providers.dart';
import '../../onboarding/providers/surveyor_profile_provider.dart';
import '../providers/records_providers.dart';

class RecordListPage extends ConsumerWidget {
  const RecordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsListProvider);
    final filter = ref.watch(recordListFilterProvider);
    final surveyor = ref.watch(surveyorProfileProvider).valueOrNull;
    final drafts = ref.watch(draftListProvider);
    final dateFormat = DateFormat('yyyy年M月d日');

    return WeaveBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ListHeader(
              surveyorName: surveyor?.name,
              onRefresh: () => ref.read(recordsListProvider.notifier).refresh(),
            ),
            if (drafts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.drafts_outlined, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${drafts.length} 筆未上傳草稿'),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push('/records/new?draft=${drafts.first.id}'),
                        child: const Text('繼續'),
                      ),
                    ],
                  ),
                ),
              ),
            _FilterBar(filter: filter),
            Expanded(
              child: AsyncValueWidget(
                value: recordsAsync,
                data: (response) {
                  if (response.items.isEmpty) {
                    return EmptyState(
                      message: '尚無語料紀錄\n點擊右下角 ＋ 開始採集',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/records/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('新增語料'),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(recordsListProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 72),
                      itemCount: response.items.length +
                          (response.items.length < response.total ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= response.items.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: OutlinedButton(
                              onPressed: () => ref
                                  .read(recordsListProvider.notifier)
                                  .loadMore(),
                              child: Text(
                                '載入更多（${response.items.length}/${response.total}）',
                              ),
                            ),
                          );
                        }

                        final record = response.items[index];
                        final featured = index == 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RecordBentoCard(
                            featured: featured,
                            title: record.title,
                            category: record.category,
                            date: dateFormat.format(record.createdAt.toLocal()),
                            hasAudio: record.audioUrl != null,
                            hasImage: record.imageUrl != null,
                            onTap: () => context.push('/records/${record.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          err.toString().replaceFirst('AppException: ', ''),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              ref.read(recordsListProvider.notifier).refresh(),
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.onRefresh,
    this.surveyorName,
  });

  final String? surveyorName;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '文化語料資料庫',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  surveyorName != null ? '調查員：$surveyorName' : '原語錄',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.sync, size: 18),
            label: Text(
              '同步',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordBentoCard extends StatelessWidget {
  const _RecordBentoCard({
    required this.featured,
    required this.title,
    required this.category,
    required this.date,
    required this.hasAudio,
    required this.hasImage,
    required this.onTap,
  });

  final bool featured;
  final String title;
  final String category;
  final String date;
  final bool hasAudio;
  final bool hasImage;
  final VoidCallback onTap;

  IconData get _categoryIcon => switch (category) {
        '歌謠' => Icons.waves,
        '訪談' => Icons.record_voice_over_outlined,
        '詞彙' => Icons.translate,
        '錄音' => Icons.graphic_eq,
        _ => Icons.description_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(featured ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_categoryIcon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                category.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '最新',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: (featured
                    ? theme.textTheme.headlineMedium
                    : theme.textTheme.titleLarge)
                ?.copyWith(fontSize: featured ? 24 : 20),
          ),
          if (hasAudio) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                6,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 3,
                  height: 8 + (i % 3) * 6.0,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: i.isEven ? 0.4 : 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                date,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                const Icon(Icons.photo_outlined, size: 14, color: AppColors.outline),
              ],
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final RecordListFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recordListFilterProvider.notifier);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _PillChip(
            label: '全部',
            selected: filter.category == null && filter.mediaFilter == MediaFilter.all,
            onTap: () {
              notifier.setCategory(null);
              notifier.setMediaFilter(MediaFilter.all);
            },
          ),
          ...AppConfig.recordCategories.map(
            (c) => _PillChip(
              label: c,
              selected: filter.category == c,
              onTap: () => notifier.setCategory(c),
            ),
          ),
          _PillChip(
            label: '含錄音',
            selected: filter.mediaFilter == MediaFilter.hasAudio,
            onTap: () => notifier.setMediaFilter(MediaFilter.hasAudio),
          ),
          _PillChip(
            label: '含照片',
            selected: filter.mediaFilter == MediaFilter.hasImage,
            onTap: () => notifier.setMediaFilter(MediaFilter.hasImage),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              gradient: selected ? AppColors.activeChipGradient : null,
              color: selected ? null : AppColors.surfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
              border: selected
                  ? null
                  : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
