import 'package:flutter/material.dart';

class LongDurationTransitionPageRoute extends MaterialPageRoute {
  LongDurationTransitionPageRoute({required super.builder});

  final _transitionDuration = Durations.long4;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _transitionDuration;
}
