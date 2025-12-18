class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(Map<String, dynamic>)? fromJson
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: fromJson != null && json['data'] != null 
          ? fromJson(json['data']) 
          : json['data'],
      error: json['error'],
    );
  }
}