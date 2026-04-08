import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/utils/russian_plural.dart';

/// Блок «подписчики / подписки» в скруглённой карточке с тенью.
class ProfileFollowStatsRow extends StatelessWidget {
  const ProfileFollowStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
  });

  final int followersCount;
  final int followingCount;

  static String followersPhrase(int n) {
    final word = _followersWord(n);
    return '$n $word';
  }

  static String followingPhrase(int n) {
    final word = _followingWord(n);
    return '$n $word';
  }

  static String _followersWord(int n) {
    return russianPlural(
      n: n,
      one: 'подписчик',
      few: 'подписчика',
      many: 'подписчиков',
    );
  }

  static String _followingWord(int n) {
    return russianPlural(
      n: n,
      one: 'подписка',
      few: 'подписки',
      many: 'подписок',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              count: followersCount,
              label: _followersWord(followersCount),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.gray300.withValues(alpha: 0.35),
          ),
          Expanded(
            child: _StatCell(
              count: followingCount,
              label: _followingWord(followingCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          textAlign: TextAlign.center,
          style: AppTextTheme.body1Medium18pt.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray100,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
