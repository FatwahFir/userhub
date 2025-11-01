import 'package:json_annotation/json_annotation.dart';

part 'api_envelope.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiEnvelope<T> {
  @JsonKey(defaultValue: false)
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
  ) =>
      _$ApiEnvelopeFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$ApiEnvelopeToJson(this, toJsonT);
}

@JsonSerializable()
class ApiError {
  @JsonKey(defaultValue: '')
  final String code;
  @JsonKey(defaultValue: '')
  final String message;
  final dynamic details;

  const ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Pagination {
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 0)
  final int pageSize;
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: 0)
  final int totalPages;

  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
