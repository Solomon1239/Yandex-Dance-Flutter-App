import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  late final Stream<List<DanceEvent>> _stream;

  @override
  void initState() {
    super.initState();
    final uid = sl<AuthRepository>().currentUserId;
    _stream =
        uid != null
            ? sl<EventRepository>().watchUserEvents(uid)
            : const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      appBar: AppBar(
        title: Text('Ближайшие', style: AppTextTheme.body3Regular20pt),
      ),
      body: SafeArea(
        child: StreamBuilder<List<DanceEvent>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Не удалось загрузить мероприятия',
                  style: AppTextTheme.body4Medium16pt,
                ),
              );
            }

            final now = DateTime.now();
            final upcoming =
                (snapshot.data ?? const <DanceEvent>[])
                    .where((e) => e.dateTime.isAfter(now))
                    .toList()
                  ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

            if (upcoming.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Вы пока не записаны ни на одно мероприятие',
                    textAlign: TextAlign.center,
                    style: AppTextTheme.body2Regular14pt.copyWith(
                      color: AppColors.gray100,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _UpcomingEventTile(event: upcoming[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({required this.event});

  final DanceEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray300.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 110,
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
                        child: SvgIcon(
                          AppIcons.calendar,
                          size: 28,
                          color: AppColors.gray300,
                        ),
                      ),
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.body4Medium16pt,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SvgIcon(
                        AppIcons.calendar,
                        size: 16,
                        color: AppColors.gray100,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          DateFormat(
                            'dd MMM, HH:mm',
                          ).format(event.dateTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTheme.body2Regular14pt.copyWith(
                            color: AppColors.gray100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SvgIcon(
                        AppIcons.pin,
                        size: 16,
                        color: AppColors.gray100,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTheme.body2Regular14pt.copyWith(
                            color: AppColors.gray100,
                          ),
                        ),
                      ),
                    ],
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
