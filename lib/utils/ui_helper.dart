import 'package:flutter/material.dart';

class UiHelper {
  static void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const SizedBox(
          height: 300.0,
          width: double.infinity,
          child: Center(
            child: Text('Bottom Sheet Test!'),
          ),
        );
      },
    );
  }
}
