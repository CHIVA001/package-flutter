import 'package:flutter/material.dart';

class AppToastStyle {
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Color? titleColor;
  final Color? descriptionColor;
  final Color? iconBackgroundColor;
  final Color? closeIconColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;
  final double? blurSigma;

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