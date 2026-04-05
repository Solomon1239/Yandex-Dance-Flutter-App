import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.name,
    required this.fiasId,
    this.region,
  });

  final String name;
  final String fiasId;
  final String? region;

  String get displayLabel => region == null ? name : '$name, $region';

  @override
  List<Object?> get props => [name, fiasId, region];
}
