class Failure {
  const Failure(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => code == null ? message : '$code: $message';
}
