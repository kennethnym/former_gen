extension ListUtils<E> on List<E> {
  /// [List.map] with index
  List<U> mapIndexed<U>(U Function(int i, E item) func) =>
      asMap().map((i, e) => MapEntry(i, func(i, e))).values.toList();
}
