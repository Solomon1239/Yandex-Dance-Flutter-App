class Optional<T> {
  const Optional(this.value);
  const Optional.absent() : value = null;

  final T? value;
}
