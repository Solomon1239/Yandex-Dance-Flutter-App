import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';

class ProfileEventsSection extends StatelessWidget {
  const ProfileEventsSection({
    super.key,
    required this.events,
    required this.onSeeAll,
  });

  final List<DanceEvent> events;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'Мероприятия',
                style: AppTextTheme.body3Regular20pt,
              ),
              const Spacer(),
              AppButton(
                onTap: onSeeAll,
                label: 'Все',
                style: AppButtonStyle(
                  height: 32,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  textStyle: AppTextTheme.body3RegularPurple14pt.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Пока нет мероприятий',
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray100,
              ),
            ),
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder:
                  (context, index) => _EventMiniCard(event: events[index]),
            ),
          ),
      ],
    );
  }
}

class _EventMiniCard extends StatelessWidget {
  const _EventMiniCard({required this.event});

  final DanceEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray300.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 96,
            width: double.infinity,
            child:
                event.coverThumbUrl != null
                    ? CachedNetworkImage(
                      imageUrl: event.coverThumbUrl!,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(color: AppColors.gray500),
                      errorWidget:
                          (_, __, ___) => Container(color: AppColors.gray500),
                    )
                    : Container(
                      color: AppColors.gray500,
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: AppColors.gray300,
                          size: 32,
                        ),
                      ),
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.body4Medium16pt,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(event.dateTime),
                    style: AppTextTheme.body2Regular14pt.copyWith(
                      color: AppColors.gray100,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    event.danceStyle.title,
                    style: AppTextTheme.body3RegularPurple14pt.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
