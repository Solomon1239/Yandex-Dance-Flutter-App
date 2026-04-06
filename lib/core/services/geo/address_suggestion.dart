import 'package:equatable/equatable.dart';

class AddressSuggestion extends Equatable {
  const AddressSuggestion({
    required this.displayLabel,
    required this.latitude,
    required this.longitude,
  });

  final String displayLabel;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [displayLabel, latitude, longitude];
}
