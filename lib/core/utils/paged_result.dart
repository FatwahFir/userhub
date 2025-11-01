class PagedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
