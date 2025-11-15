/// Generic API response wrapper for paginated data
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasMore => next != null;
  bool get hasPrevious => previous != null;
}

/// Generic API response for single items
class ApiResponse<T> {
  final T data;
  final String? message;

  ApiResponse({required this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      data: fromJsonT(json),
      message: json['message'] as String?,
    );
  }
}

/// API error response
class ApiError {
  final String detail;
  final Map<String, List<String>>? errors;
  final String? code;

  ApiError({required this.detail, this.errors, this.code});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      detail: json['detail'] as String? ?? 'An error occurred',
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            )
          : null,
      code: json['code'] as String?,
    );
  }

  String get message {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.entries
          .map((e) => '${e.key}: ${e.value.join(", ")}')
          .join('\n');
    }
    return detail;
  }
}
