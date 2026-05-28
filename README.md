# app_toast

A fully customizable Flutter toast notification package.

## Features
- ✅ Top & bottom position
- ✅ Glass morphism effect
- ✅ Swipe to dismiss (horizontal)
- ✅ Timer pauses while holding
- ✅ Platform-aware icons (iOS/Android)
- ✅ Custom icon, iconWidget
- ✅ Fully customizable style

## Installation
```yaml
dependencies:
  app_toast: ^0.0.1
```

## Usage
```dart
AppToast.show(
  context,
  title: 'Saved successfully',
  type: AppToastType.success,
);

// Glass
AppToast.show(
  context,
  title: 'Hello',
  glass: true,
  style: AppToastStyle(blurSigma: 20),
);
```