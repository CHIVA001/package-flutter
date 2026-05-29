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
  app_toast: ^1.0.0
```

## Usage
```dart
AppToast.show(
  context,
  title: 'Saved successfully',
  type: AppToastType.success,
);

AppToast.show(
  context,
  title: 'Hello',
  description: 'This is a glass toast message.',
  glass: true,
  style: AppToastStyle(blurSigma: 20),
);
```

## Example

See `example/lib/main.dart` for a complete Flutter example showing how to use `AppToast` in a simple app.

## License

MIT License
