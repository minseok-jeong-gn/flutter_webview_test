import 'dart:developer';

class Log {
  Log._();

  static const _prefix = '[WT]';
  static void d(dynamic any) {
    log('$_prefix $any');
  }
}
