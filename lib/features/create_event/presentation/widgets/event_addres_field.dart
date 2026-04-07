import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_dance/core/services/geo/address_search_service.dart';
import 'package:yandex_dance/core/services/geo/address_suggestion.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';

class EventAddressField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool touched;
  final InputState state;
  final String? Function(String) validator;
  final void Function(String) onChanged;
  final void Function(InputState) onStateChange;
  final AddressSearchService searchService;
  final AddressSuggestion? selectedAddress;
  final ValueChanged<AddressSuggestion?> onAddressSelected;

  const EventAddressField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    required this.touched,
    required this.state,
    required this.validator,
    required this.onChanged,
    required this.onStateChange,
    required this.searchService,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  State<EventAddressField> createState() => _EventAddressFieldState();
}

class _EventAddressFieldState extends State<EventAddressField> {
  Timer? _debounce;
  int _requestId = 0;
  List<AddressSuggestion> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant EventAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddress != null &&
        widget.selectedAddress != oldWidget.selectedAddress) {
      setState(() {
        _results = const [];
        _isLoading = false;
        _hasSearched = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _onTextChanged(String value) {
    widget.onChanged(value);

    final trimmed = value.trim();
    if (widget.selectedAddress != null &&
        trimmed != widget.selectedAddress!.displayLabel) {
      widget.onAddressSelected(null);
    }

    _debounce?.cancel();
    if (trimmed.length < 3) {
      setState(() {
        _results = const [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String query) async {
    final currentRequest = ++_requestId;
    final results = await widget.searchService.search(query);
    if (!mounted || currentRequest != _requestId) return;
    setState(() {
      _results = results;
      _isLoading = false;
      _hasSearched = true;
    });
  }

  void _selectAddress(AddressSuggestion suggestion) {
    _requestId++;
    _debounce?.cancel();

    widget.controller.text = suggestion.displayLabel;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.displayLabel.length),
    );
    widget.onAddressSelected(suggestion);
    widget.onChanged(suggestion.displayLabel);

    setState(() {
      _results = const [];
      _isLoading = false;
      _hasSearched = false;
    });
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions =
        widget.focusNode.hasFocus &&
        (_isLoading || _results.isNotEmpty || _hasSearched);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Адрес', style: AppTextTheme.body4Medium16pt),
        const SizedBox(height: 6),
        AppTextField(
          hint: 'Введите адрес мероприятия',
          state: widget.state,
          contoller: widget.controller,
          focusNode: widget.focusNode,
          nextFocusNode: widget.nextFocusNode,
          touched: widget.touched,
          validator: widget.validator,
          isLongText: false,
          textInputAction:
              widget.nextFocusNode == null
                  ? TextInputAction.done
                  : TextInputAction.next,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          onChanged: _onTextChanged,
          onStateChange: widget.onStateChange,
        ),
        if (showSuggestions) ...[
          const SizedBox(height: 8),
          _AddressSuggestionsBox(
            isLoading: _isLoading,
            results: _results,
            selectedAddressLabel: widget.selectedAddress?.displayLabel,
            onSelect: _selectAddress,
          ),
        ],
      ],
    );
  }
}

class _AddressSuggestionsBox extends StatelessWidget {
  const _AddressSuggestionsBox({
    required this.isLoading,
    required this.results,
    required this.selectedAddressLabel,
    required this.onSelect,
  });

  final bool isLoading;
  final List<AddressSuggestion> results;
  final String? selectedAddressLabel;
  final ValueChanged<AddressSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purple500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ищем адреса...',
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray300,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          'Ничего не найдено',
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray300,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < results.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AppFilterChip(
              label: results[i].displayLabel,
              isSelected: selectedAddressLabel == results[i].displayLabel,
              onTap: () => onSelect(results[i]),
              colors: AppFilterChipColors(
                selectedGradient: AppColors.gradient,
                selectedBorderColor: Colors.transparent,
                unselectedBackgroundColor: Colors.transparent,
                unselectedBorderColor: AppColors.gray300,
                textColor: AppColors.gray0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
