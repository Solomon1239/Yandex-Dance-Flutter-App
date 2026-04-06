part of '../events_page.dart';

class _EventsFiltersResult {
  const _EventsFiltersResult({
    required this.selectedGenres,
    required this.selectedDateFilter,
    required this.selectedSeatsFilter,
  });

  final Set<String> selectedGenres;
  final String selectedDateFilter;
  final String selectedSeatsFilter;
}

class _EventsFiltersSheet extends StatefulWidget {
  const _EventsFiltersSheet({
    required this.genres,
    required this.selectedGenres,
    required this.selectedDateFilter,
    required this.selectedSeatsFilter,
  });

  final List<String> genres;
  final Set<String> selectedGenres;
  final String selectedDateFilter;
  final String selectedSeatsFilter;

  @override
  State<_EventsFiltersSheet> createState() => _EventsFiltersSheetState();
}

class _EventsFiltersSheetState extends State<_EventsFiltersSheet> {
  static const _allGenresLabel = 'Все';
  static const _anyDateLabel = 'Любая дата';
  static const _allSeatsLabel = 'Все места';
  static const _availableSeatsLabel = 'Есть места';

  late Set<String> _selectedGenres;
  late String _selectedDateFilter;
  late String _selectedSeatsFilter;

  @override
  void initState() {
    super.initState();
    _selectedGenres = Set<String>.from(widget.selectedGenres);
    _selectedDateFilter = widget.selectedDateFilter;
    _selectedSeatsFilter = widget.selectedSeatsFilter;
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (genre == _allGenresLabel) {
        _selectedGenres
          ..clear()
          ..add(_allGenresLabel);
        return;
      }

      _selectedGenres.remove(_allGenresLabel);
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }

      if (_selectedGenres.isEmpty) {
        _selectedGenres.add(_allGenresLabel);
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedGenres = {_allGenresLabel};
      _selectedDateFilter = _anyDateLabel;
      _selectedSeatsFilter = _allSeatsLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final insetBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + insetBottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Стили', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  for (final genre in widget.genres)
                    ChipItem(label: genre, onTap: () => _toggleGenre(genre)),
                ],
                selectedLabels: _selectedGenres,
              ),
              const SizedBox(height: 14),
              Text('Даты', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  ChipItem(
                    label: _anyDateLabel,
                    onTap:
                        () =>
                            setState(() => _selectedDateFilter = _anyDateLabel),
                  ),
                  ChipItem(
                    label: 'Сегодня',
                    onTap:
                        () => setState(() => _selectedDateFilter = 'Сегодня'),
                  ),
                  ChipItem(
                    label: 'Завтра',
                    onTap: () => setState(() => _selectedDateFilter = 'Завтра'),
                  ),
                  ChipItem(
                    label: 'Эта неделя',
                    onTap:
                        () =>
                            setState(() => _selectedDateFilter = 'Эта неделя'),
                  ),
                  ChipItem(
                    label: 'Выходные',
                    onTap:
                        () => setState(() => _selectedDateFilter = 'Выходные'),
                  ),
                ],
                selectedLabels: {_selectedDateFilter},
              ),
              const SizedBox(height: 14),
              Text('Места', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  ChipItem(
                    label: _allSeatsLabel,
                    onTap:
                        () => setState(
                          () => _selectedSeatsFilter = _allSeatsLabel,
                        ),
                  ),
                  ChipItem(
                    label: _availableSeatsLabel,
                    onTap:
                        () => setState(
                          () => _selectedSeatsFilter = _availableSeatsLabel,
                        ),
                  ),
                ],
                selectedLabels: {_selectedSeatsFilter},
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Сбросить',
                      onTap: _reset,
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
                      label: 'Применить',
                      onTap: () {
                        Navigator.of(context).pop(
                          _EventsFiltersResult(
                            selectedGenres: _selectedGenres,
                            selectedDateFilter: _selectedDateFilter,
                            selectedSeatsFilter: _selectedSeatsFilter,
                          ),
                        );
                      },
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
