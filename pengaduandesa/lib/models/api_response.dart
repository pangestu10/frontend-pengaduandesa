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
    try {
      return ApiResponse(
        success: json['success'] ?? false,
        message: json['message']?.toString() ?? '',
        data: fromJson != null && json['data'] != null 
            ? fromJson(json['data'] as Map<String, dynamic>) 
            : (json['data'] as T?),
        error: json['error'],
      );
    } catch (e) {
      // Jika parsing gagal, return error response
      return ApiResponse(
        success: false,
        message: 'Gagal memparse response dari server',
        data: null,
        error: e.toString(),
      );
    }
  }
}