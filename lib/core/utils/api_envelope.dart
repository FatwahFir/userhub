class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final Pagination? pagination;
  final Map<String, dynamic>? meta;

  const ApiEnvelope({
    required this.success,
    this.data,
    this.error,
    this.pagination,
    this.meta,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null ? null : fromJsonT(json['data']),
      error: json['error'] == null
          ? null
          : ApiError.fromJson(json['error'] as Map<String, dynamic>),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      meta: (json['meta'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value),
      ),
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final dynamic details;

  const ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        details: json['details'],
      );
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['page_size'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      );
}
