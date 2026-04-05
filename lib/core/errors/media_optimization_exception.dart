class MediaOptimizationException implements Exception {
  const MediaOptimizationException(this.message);

  final String message;

  @override
  String toString() => 'MediaOptimizationException: $message';
}
