import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../onboarding/models/parsed_record_note.dart';

class RecordNoteDisplay extends StatelessWidget {
  const RecordNoteDisplay({
    super.key,
    required this.note,
  });

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = ParsedRecordNote.parse(note);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '備註',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (parsed.hasSurveyorInfo) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.person_outline,
                label: parsed.surveyorName!,
              ),
              if (parsed.region != null)
                _InfoChip(
                  icon: Icons.place_outlined,
                  label: parsed.region!,
                ),
            ],
          ),
          if (parsed.userNote != null) const SizedBox(height: 12),
        ],
        if (parsed.userNote != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              parsed.userNote!,
              style: theme.textTheme.bodyLarge,
            ),
          )
        else if (!parsed.hasSurveyorInfo)
          Text(note, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
