import 'package:flutter/material.dart';

class LongDurationTransitionPageRoute extends MaterialPageRoute {
  LongDurationTransitionPageRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}
