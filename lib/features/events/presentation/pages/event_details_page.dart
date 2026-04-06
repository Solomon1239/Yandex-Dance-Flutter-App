import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/snackbar/app_snackbar.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key, required this.event});

  final EventPreview event;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _eventRepository = sl<EventRepository>();
  final _profileRepository = sl<ProfileRepository>();
  final _authRepository = sl<AuthRepository>();
  final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

  late final Stream<List<DanceEvent>> _eventsStream;

  Future<List<_ParticipantViewData>>? _participantsFuture;
  String _participantsKey = '';

  bool _isMembershipActionInProgress = false;
  bool _isOwnerActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventRepository.watchAllEvents();
  }

  DanceEvent? _findEventById(List<DanceEvent> events) {
    for (final event in events) {
      if (event.id == widget.event.id) return event;
    }
    return null;
  }

  void _ensureParticipantsFuture(List<String> participantIds) {
    final key = participantIds.join('|');
    if (_participantsFuture != null && _participantsKey == key) {
      return;
    }
    _participantsKey = key;
    _participantsFuture = _loadParticipants(participantIds);
  }

  Future<List<_ParticipantViewData>> _loadParticipants(List<String> ids) async {
    final result = <_ParticipantViewData>[];
    for (final uid in ids) {
      try {
        final profile = await _profileRepository.getProfile(uid);
        final name = profile?.displayName?.trim();
        result.add(
          _ParticipantViewData(
            uid: uid,
            name:
                (name != null && name.isNotEmpty)
                    ? name
                    : 'Пользователь ${_shortUid(uid)}',
            avatarUrl: profile?.avatarThumbUrl ?? profile?.avatarUrl,
          ),
        );
      } catch (_) {
        result.add(
          _ParticipantViewData(
            uid: uid,
            name: 'Пользователь ${_shortUid(uid)}',
            avatarUrl: null,
          ),
        );
      }
    }
    return result;
  }

  String _shortUid(String uid) {
    if (uid.length <= 6) return uid;
    return uid.substring(0, 6);
  }

  ImageProvider<Object>? _eventCoverImage(DanceEvent event) {
    final url = (event.coverThumbUrl ?? event.coverUrl)?.trim();
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }

  Future<void> _handleMembershipAction(DanceEvent event) async {
    final uid = _authRepository.currentUserId;
    if (uid == null) {
      AppSnackBar.showError(context, 'Нужна авторизация');
      return;
    }

    if (event.isCreator(uid)) {
      AppSnackBar.showInfo(context, 'Вы организатор мероприятия');
      return;
    }

    if (_isMembershipActionInProgress) return;
    setState(() => _isMembershipActionInProgress = true);
    try {
      if (event.isParticipant(uid)) {
        await _eventRepository.leaveEvent(eventId: event.id, uid: uid);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Вы отписались от мероприятия');
        }
      } else {
        if (event.isFull) {
          if (mounted) AppSnackBar.showInfo(context, 'Свободных мест нет');
          return;
        }
        await _eventRepository.joinEvent(eventId: event.id, uid: uid);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Вы записались на мероприятие');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isMembershipActionInProgress = false);
      }
    }
  }

  Future<void> _deleteEvent(DanceEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Удалить мероприятие?'),
            content: const Text(
              'Действие нельзя отменить. Мероприятие и связанные файлы будут удалены.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirm != true || _isOwnerActionInProgress) return;

    setState(() => _isOwnerActionInProgress = true);
    try {
      await _eventRepository.deleteEvent(event.id);
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Мероприятие удалено');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Ошибка удаления: $e');
    } finally {
      if (mounted) setState(() => _isOwnerActionInProgress = false);
    }
  }

  Future<void> _editEvent(DanceEvent event) async {
    final payload = await showModalBottomSheet<_EditEventPayload>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditEventSheet(event: event),
    );
    if (payload == null || _isOwnerActionInProgress) return;

    setState(() => _isOwnerActionInProgress = true);
    try {
      final updated = event.copyWith(
        title: payload.title,
        description: payload.description,
        danceStyle: payload.danceStyle,
        dateTime: payload.dateTime,
        address: payload.address,
        maxParticipants: payload.maxParticipants,
        ageRestriction: payload.ageRestriction,
      );
      await _eventRepository.updateEvent(updated);
      if (mounted) AppSnackBar.showSuccess(context, 'Мероприятие обновлено');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Ошибка сохранения: $e');
    } finally {
      if (mounted) setState(() => _isOwnerActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DanceEvent>>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        final event = _findEventById(snapshot.data ?? const []);
        final currentUid = _authRepository.currentUserId;
        final isOwner =
            event != null && currentUid != null && event.isCreator(currentUid);
        final isParticipant =
            event != null &&
            currentUid != null &&
            event.isParticipant(currentUid);

        if (event != null) {
          _ensureParticipantsFuture(event.participantIds);
        }

        return Scaffold(
          backgroundColor: AppColors.gray500,
          appBar: AppBar(
            title: const Text('Мероприятие'),
            scrolledUnderElevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: AppButton(
                iconWidget: const SvgIcon(
                  AppIcons.back,
                  size: 20,
                  color: AppColors.gray0,
                ),
                onTap: () => Navigator.of(context).pop(),
                style: const AppButtonStyle(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            actions:
                isOwner
                    ? [
                      IconButton(
                        tooltip: 'Редактировать',
                        onPressed:
                            _isOwnerActionInProgress
                                ? null
                                : () => _editEvent(event),
                        icon: const SvgIcon(
                          AppIcons.edit,
                          size: 20,
                          color: AppColors.gray0,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Удалить',
                        onPressed:
                            _isOwnerActionInProgress
                                ? null
                                : () => _deleteEvent(event),
                        icon: const SvgIcon(
                          AppIcons.trash,
                          size: 20,
                          color: AppColors.gray0,
                        ),
                      ),
                    ]
                    : null,
          ),
          body: SafeArea(
            child:
                snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : event == null
                    ? const Center(
                      child: Text('Мероприятие не найдено или удалено'),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Cover(
                                  styleLabel: event.danceStyle.title,
                                  coverImage: _eventCoverImage(event),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  event.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.gray0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _MetaLine(
                                  icon: AppIcons.calendar,
                                  text: _dateFormat.format(event.dateTime),
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.pin,
                                  text: event.address,
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.info,
                                  text:
                                      'Возраст: ${event.ageRestriction.trim().isEmpty ? 'Для всех' : event.ageRestriction}',
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.friends,
                                  text:
                                      '${event.currentParticipants}/${event.maxParticipants} участников',
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  event.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.gray100,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Кто записан',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: AppColors.gray0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<List<_ParticipantViewData>>(
                                  future: _participantsFuture,
                                  builder: (context, participantsSnapshot) {
                                    if (participantsSnapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !participantsSnapshot.hasData) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }

                                    final participants =
                                        participantsSnapshot.data ?? const [];
                                    if (participants.isEmpty) {
                                      return Text(
                                        'Пока никто не записан',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.gray100,
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: participants.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final participant = participants[index];
                                        return _ParticipantRow(
                                          participant: participant,
                                          isOwner:
                                              participant.uid ==
                                              event.creatorId,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: AppButton(
                            label:
                                isOwner
                                    ? 'Вы организатор'
                                    : isParticipant
                                    ? 'Отписаться'
                                    : event.isFull
                                    ? 'Мест нет'
                                    : 'Записаться',
                            style:
                                isParticipant && !isOwner
                                    ? const AppButtonStyle(
                                      width: double.infinity,
                                      height: 52,
                                      backgroundColor: Colors.transparent,
                                      border: AppButtonBorder(
                                        borderRadius: 999,
                                        borderWidth: 1,
                                        borderColor: AppColors.gray100,
                                        borderStyle: ButtonBorderStyle.solid,
                                      ),
                                      textColor: AppColors.gray0,
                                    )
                                    : AppButtonStyle.gradientFilled.copyWith(
                                      width: double.infinity,
                                    ),
                            onTap:
                                (isOwner || (event.isFull && !isParticipant))
                                    ? null
                                    : () => _handleMembershipAction(event),
                            needLoading: _isMembershipActionInProgress,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.styleLabel, this.coverImage});

  final String styleLabel;
  final ImageProvider<Object>? coverImage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  coverImage != null
                      ? DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: coverImage!,
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                      )
                      : Container(color: AppColors.gray400),
            ),
            if (coverImage == null)
              const Positioned.fill(
                child: Center(
                  child: SvgIcon(
                    AppIcons.notImage,
                    size: 72,
                    color: AppColors.gray300,
                  ),
                ),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: AppColors.gradient,
                ),
                child: Text(
                  styleLabel,
                  style: const TextStyle(
                    color: AppColors.gray0,
                    fontWeight: FontWeight.w600,
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgIcon(icon, size: 20, color: AppColors.gray100),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray100),
          ),
        ),
      ],
    );
  }
}

class _ParticipantViewData {
  const _ParticipantViewData({
    required this.uid,
    required this.name,
    required this.avatarUrl,
  });

  final String uid;
  final String name;
  final String? avatarUrl;
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant, required this.isOwner});

  final _ParticipantViewData participant;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = participant.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.gray400,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child:
              hasAvatar
                  ? null
                  : Text(
                    participant.name.isNotEmpty
                        ? participant.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.gray0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isOwner ? '${participant.name} (Организатор)' : participant.name,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray0),
          ),
        ),
      ],
    );
  }
}

class _EditEventPayload {
  const _EditEventPayload({
    required this.title,
    required this.description,
    required this.danceStyle,
    required this.dateTime,
    required this.address,
    required this.maxParticipants,
    required this.ageRestriction,
  });

  final String title;
  final String description;
  final DanceStyle danceStyle;
  final DateTime dateTime;
  final String address;
  final int maxParticipants;
  final String ageRestriction;
}

class _EditEventSheet extends StatefulWidget {
  const _EditEventSheet({required this.event});

  final DanceEvent event;

  @override
  State<_EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<_EditEventSheet> {
  static const _ageOptions = ['Для всех', '12+', '14+', '16+', '18+'];
  static const _compactInputTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  static const _compactHintTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _maxParticipantsController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _descriptionFocusNode;
  late final FocusNode _addressFocusNode;
  late final FocusNode _maxParticipantsFocusNode;

  var _titleState = InputState.initial;
  var _descriptionState = InputState.initial;
  var _addressState = InputState.initial;
  var _maxParticipantsState = InputState.initial;

  var _titleTouched = false;
  var _descriptionTouched = false;
  var _addressTouched = false;
  var _maxParticipantsTouched = false;

  late DanceStyle _selectedDanceStyle;
  late DateTime _selectedDateTime;
  late String _selectedAgeRestriction;

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _addressController = TextEditingController(text: widget.event.address);
    _maxParticipantsController = TextEditingController(
      text: widget.event.maxParticipants.toString(),
    );
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _maxParticipantsFocusNode = FocusNode();
    _selectedDanceStyle = widget.event.danceStyle;
    _selectedDateTime = widget.event.dateTime;
    _selectedAgeRestriction =
        widget.event.ageRestriction.trim().isEmpty
            ? 'Для всех'
            : widget.event.ageRestriction;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _maxParticipantsController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _addressFocusNode.dispose();
    _maxParticipantsFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final address = _addressController.text.trim();
    final maxParticipants = int.tryParse(
      _maxParticipantsController.text.trim(),
    );

    if (title.isEmpty || description.isEmpty || address.isEmpty) {
      setState(() {
        _errorText = 'Заполни название, описание и адрес';
      });
      return;
    }

    if (maxParticipants == null || maxParticipants < 1) {
      setState(() {
        _errorText = 'Введите корректное количество мест';
      });
      return;
    }

    if (maxParticipants < widget.event.currentParticipants) {
      setState(() {
        _errorText =
            'Количество мест не может быть меньше текущих участников (${widget.event.currentParticipants})';
      });
      return;
    }

    Navigator.of(context).pop(
      _EditEventPayload(
        title: title,
        description: description,
        danceStyle: _selectedDanceStyle,
        dateTime: _selectedDateTime,
        address: address,
        maxParticipants: maxParticipants,
        ageRestriction: _selectedAgeRestriction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insetBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, insetBottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Редактирование мероприятия',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Название'),
              AppTextField(
                hint: 'Название',
                state: _titleState,
                contoller: _titleController,
                textStyle: _compactInputTextStyle,
                hintStyle: _compactHintTextStyle,
                touched: _titleTouched,
                focusNode: _titleFocusNode,
                nextFocusNode: _descriptionFocusNode,
                onChanged: (_) => setState(() => _titleTouched = true),
                onFocusChange: () => setState(() => _titleTouched = true),
                onUnfocus: () => setState(() => _titleTouched = true),
                onStateChange: (value) => setState(() => _titleState = value),
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Описание'),
              AppTextField(
                hint: 'Описание',
                state: _descriptionState,
                contoller: _descriptionController,
                textStyle: _compactInputTextStyle,
                hintStyle: _compactHintTextStyle,
                touched: _descriptionTouched,
                focusNode: _descriptionFocusNode,
                nextFocusNode: _addressFocusNode,
                isLongText: true,
                onChanged: (_) => setState(() => _descriptionTouched = true),
                onFocusChange: () => setState(() => _descriptionTouched = true),
                onUnfocus: () => setState(() => _descriptionTouched = true),
                onStateChange:
                    (value) => setState(() => _descriptionState = value),
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Адрес'),
              AppTextField(
                hint: 'Адрес',
                state: _addressState,
                contoller: _addressController,
                textStyle: _compactInputTextStyle,
                hintStyle: _compactHintTextStyle,
                touched: _addressTouched,
                focusNode: _addressFocusNode,
                nextFocusNode: _maxParticipantsFocusNode,
                onChanged: (_) => setState(() => _addressTouched = true),
                onFocusChange: () => setState(() => _addressTouched = true),
                onUnfocus: () => setState(() => _addressTouched = true),
                onStateChange: (value) => setState(() => _addressState = value),
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Количество мест'),
              AppTextField(
                hint: 'Количество мест',
                state: _maxParticipantsState,
                contoller: _maxParticipantsController,
                textStyle: _compactInputTextStyle,
                hintStyle: _compactHintTextStyle,
                touched: _maxParticipantsTouched,
                focusNode: _maxParticipantsFocusNode,
                keyboardType: TextInputType.number,
                onChanged:
                    (_) => setState(() => _maxParticipantsTouched = true),
                onFocusChange:
                    () => setState(() => _maxParticipantsTouched = true),
                onUnfocus: () => setState(() => _maxParticipantsTouched = true),
                onStateChange:
                    (value) => setState(() => _maxParticipantsState = value),
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Стиль'),
              DropdownButtonFormField<DanceStyle>(
                initialValue: _selectedDanceStyle,
                decoration: const InputDecoration(),
                items: [
                  for (final style in DanceStyle.values)
                    DropdownMenuItem(value: style, child: Text(style.title)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedDanceStyle = value);
                },
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Возраст'),
              DropdownButtonFormField<String>(
                initialValue: _selectedAgeRestriction,
                decoration: const InputDecoration(),
                items: [
                  for (final age in _ageOptions)
                    DropdownMenuItem(value: age, child: Text(age)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedAgeRestriction = value);
                },
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Дата и время'),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDateTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(_dateFormat.format(_selectedDateTime)),
                    ],
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: AppColors.pink500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Отмена',
                      onTap: () => Navigator.of(context).pop(),
                      style: const AppButtonStyle(
                        height: 44,
                        backgroundColor: Colors.transparent,
                        border: AppButtonBorder(
                          borderRadius: 999,
                          borderWidth: 1,
                          borderColor: AppColors.gray100,
                          borderStyle: ButtonBorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Сохранить',
                      onTap: _submit,
                      style: AppButtonStyle.gradientFilled.copyWith(height: 44),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.gray100,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
