import 'package:flutter/material.dart';

extension GetColorScheme on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
}