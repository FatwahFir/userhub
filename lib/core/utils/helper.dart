import 'dart:async';

typedef VoidCallback = void Function();

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

String extractMessage(dynamic error) {
  if (error is Map<String, dynamic>) {
    return error['message']?.toString() ?? 'Unexpected error';
  }
  if (error is String) return error;
  return 'Unexpected error';
}
