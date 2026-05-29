import 'package:flutter/material.dart';

/// Styling options for an [AppToast] notification.
///
/// Use [AppToastStyle] to customize background colors, borders, typography,
/// padding, shadows, and glass blur intensity.
class AppToastStyle {
  /// Custom border radius for the toast container.
  final double? borderRadius;

  /// Optional background color for the toast.
  final Color? backgroundColor;

  /// Optional border color for the toast container.
  final Color? borderColor;

  /// Border width for the toast container.
  final double? borderWidth;

  /// Text color for the title.
  final Color? titleColor;

  /// Text color for the description.
  final Color? descriptionColor;

  /// Background tint for the icon container.
  final Color? iconBackgroundColor;

  /// Color for the close icon.
  final Color? closeIconColor;

  /// Size of the toast icon.
  final double? iconSize;

  /// Internal padding for the toast content.
  final EdgeInsets? padding;

  /// Optional box shadow for the toast container.
  final List<BoxShadow>? boxShadow;

  /// Blur intensity when using glass styling.
  final double? blurSigma;

  /// Creates a new [AppToastStyle].
  const AppToastStyle({
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.titleColor,
    this.descriptionColor,
    this.iconBackgroundColor,
    this.closeIconColor,
    this.iconSize,
    this.padding,
    this.boxShadow,
    this.blurSigma,
  });
}
