import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A loading indicator that adapts to the current platform.
/// On iOS, it shows a CupertinoActivityIndicator.
/// On Android and other platforms, it shows a CircularProgressIndicator.
class PlatformLoadingIndicator extends StatelessWidget {
  /// The color of the loading indicator.
  /// Note: This only affects the CircularProgressIndicator on Android.
  /// CupertinoActivityIndicator uses the system's default color.
  final Color? color;
  
  /// The size of the loading indicator.
  final double size;
  
  /// The value of the progress indicator. If null, the indicator is indeterminate.
  final double? value;
  
  /// The stroke width of the loading indicator.
  /// Default is 2.0 for iOS and 4.0 for Android.
  final double? strokeWidth;

  const PlatformLoadingIndicator({
    super.key,
    this.color,
    this.size = 20.0,
    this.value,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Use iOS style on iOS devices
    if (Platform.isIOS) {
      return SizedBox(
        width: size,
        height: size,
        child: CupertinoActivityIndicator(
          radius: size / 2,
          color: color,
        ),
      );
    }
    
    // Use Material Design style on Android and other platforms
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth ?? 4.0,
        color: color ?? theme.colorScheme.primary,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}