import 'dart:async';
import 'dart:developer';

FutureOr<void> measureExecutionTime({
  required final String description,
  required final FutureOr<void> Function() logic,
}) async {
  final Stopwatch stopwatch = Stopwatch();
  stopwatch.start();
  final ret = logic.call();
  if (ret is Future) {
    await ret;
  }
  stopwatch.stop();

  log('$description took ${stopwatch.elapsedMilliseconds} ms');
}
