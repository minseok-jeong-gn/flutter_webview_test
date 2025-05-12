class JavascriptMessageHandlerResult {
  const JavascriptMessageHandlerResult({
    required this.resultOk,
    this.data,
    this.errorMessage,
  });

  final Map<String, Object?>? data;
  final bool resultOk;
  final Object? errorMessage;

  Map<String, Object?> toJson() => {
        'data': data,
        'resultOk': resultOk,
        'errorMessage': errorMessage,
      };
}
