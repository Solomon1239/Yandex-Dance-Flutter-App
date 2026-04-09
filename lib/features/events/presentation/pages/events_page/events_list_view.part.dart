part of '../events_page.dart';

class _EventsListView extends StatelessWidget {
  const _EventsListView({
    super.key,
    required this.events,
    required this.onOpenEvent,
  });

  final List<EventPreview> events;
  final ValueChanged<EventPreview> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = events[index];

        return EventCard(
          title: event.title,
          styleLabel: event.styleLabel,
          ageRestrictionLabel: event.ageRestrictionLabel,
          dateLabel: event.dateLabel,
          locationLabel: event.locationLabel,
          authorLabel: event.authorLabel,
          participantsLabel: event.participantsLabel,
          authorAvatarImage: event.authorAvatarImage,
          coverImage: event.coverImage,
          compact: true,
          onTap: () => onOpenEvent(event),
        );
      },
    );
  }
}
