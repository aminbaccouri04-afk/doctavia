/// Generic wrapper matching the backend's standard JSON response shape.
class ApiResponse<T> {
  final String status;
  final T? data;
  final String? errorMessage;

  ApiResponse({required this.status, this.data, this.errorMessage});

  bool get isSuccess => status == 'success';
}
