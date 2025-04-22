import 'package:flutter/material.dart';

enum _TextSize {
  small,
  medium,
  large,
  extraLarge,
}

class MyText extends StatelessWidget {
  const MyText._({
    required this.text,
    required this.textSize,
  });

  factory MyText.small(String text) {
    return MyText._(
      text: text,
      textSize: _TextSize.small,
    );
  }

  factory MyText.medium(String text) {
    return MyText._(
      text: text,
      textSize: _TextSize.medium,
    );
  }

  factory MyText.large(String text) {
    return MyText._(
      text: text,
      textSize: _TextSize.large,
    );
  }

  factory MyText.extraLarge(String text) {
    return MyText._(
      text: text,
      textSize: _TextSize.extraLarge,
    );
  }

  final String text;
  // ignore: library_private_types_in_public_api
  final _TextSize textSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = switch (textSize) {
      _TextSize.small => textTheme.bodySmall,
      _TextSize.medium => textTheme.bodyMedium,
      _TextSize.large => textTheme.bodyLarge,
      _TextSize.extraLarge => textTheme.headlineSmall,
    };

    return Text(
      text,
      style: textStyle,
    );
  }
}
