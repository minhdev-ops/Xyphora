class ExceptionWithMessage implements Exception {
  final String mess;
  ExceptionWithMessage({required this.mess});

  @override
  String toString() => mess;
}