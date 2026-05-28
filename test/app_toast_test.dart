// test/app_toast_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_app_toast/app_toast.dart';

void main() {
  group('AppToastStyle', () {
    test('default values are null', () {
      const style = AppToastStyle();
      expect(style.borderRadius, isNull);
      expect(style.backgroundColor, isNull);
      expect(style.borderColor, isNull);
      expect(style.borderWidth, isNull);
      expect(style.titleColor, isNull);
      expect(style.descriptionColor, isNull);
      expect(style.iconBackgroundColor, isNull);
      expect(style.closeIconColor, isNull);
      expect(style.iconSize, isNull);
      expect(style.padding, isNull);
      expect(style.boxShadow, isNull);
      expect(style.blurSigma, isNull);
    });

    test('values are set correctly', () {
      const style = AppToastStyle(
        borderRadius: 12,
        backgroundColor: Colors.red,
        borderColor: Colors.blue,
        borderWidth: 2,
        titleColor: Colors.white,
        descriptionColor: Colors.grey,
        iconBackgroundColor: Colors.green,
        closeIconColor: Colors.black,
        iconSize: 24,
        blurSigma: 10,
        padding: EdgeInsets.all(16),
      );

      expect(style.borderRadius, 12);
      expect(style.backgroundColor, Colors.red);
      expect(style.borderColor, Colors.blue);
      expect(style.borderWidth, 2);
      expect(style.titleColor, Colors.white);
      expect(style.descriptionColor, Colors.grey);
      expect(style.iconBackgroundColor, Colors.green);
      expect(style.closeIconColor, Colors.black);
      expect(style.iconSize, 24);
      expect(style.blurSigma, 10);
      expect(style.padding, const EdgeInsets.all(16));
    });
  });

  group('AppToastType', () {
    test('all types exist', () {
      expect(AppToastType.values.length, 4);
      expect(AppToastType.values, contains(AppToastType.info));
      expect(AppToastType.values, contains(AppToastType.success));
      expect(AppToastType.values, contains(AppToastType.error));
      expect(AppToastType.values, contains(AppToastType.warning));
    });
  });

  group('AppToastPosition', () {
    test('all positions exist', () {
      expect(AppToastPosition.values.length, 2);
      expect(AppToastPosition.values, contains(AppToastPosition.top));
      expect(AppToastPosition.values, contains(AppToastPosition.bottom));
    });
  });

  group('AppToast widget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.show(context, title: 'Test Title'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle(); // Waits for entry animation to settle

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('shows description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.show(
                context,
                title: 'Title',
                description: 'Some description',
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Some description'), findsOneWidget);
    });

    testWidgets('dismisses on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.show(context, title: 'Tap to dismiss'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Tap to dismiss'), findsOneWidget);

      // Tap the actual toast to invoke the internal _dismiss flow
      await tester.tap(find.text('Tap to dismiss'));
      await tester
          .pumpAndSettle(); // Completely waits out the exit animation and unmount

      expect(find.text('Tap to dismiss'), findsNothing);
    });

    testWidgets('dismisses after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.show(
                context,
                title: 'Auto dismiss',
                duration: const Duration(seconds: 2),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Auto dismiss'), findsOneWidget);

      // 1. Advance the clock past the internal non-visual Timer delay (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      // 2. Let the subsequent fade-out animation and widget deletion finish settling
      await tester.pumpAndSettle();

      expect(find.text('Auto dismiss'), findsNothing);
    });

    testWidgets('shows all toast types without error', (tester) async {
      for (final type in AppToastType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppToast.show(
                  context,
                  title: 'Type: ${type.name}',
                  type: type,
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Type: ${type.name}'), findsOneWidget);
      }
    });

    testWidgets('shows at bottom position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppToast.show(
                context,
                title: 'Bottom toast',
                position: AppToastPosition.bottom,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Bottom toast'), findsOneWidget);
    });

    testWidgets('new toast replaces old toast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => AppToast.show(context, title: 'First toast'),
                  child: const Text('First'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      AppToast.show(context, title: 'Second toast'),
                  child: const Text('Second'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('First toast'), findsOneWidget);

      await tester.tap(find.text('Second'));
      // AppToast.show calls _current?.remove() instantly on the old overlay,
      // then adds the new one, animating it into place.
      await tester.pumpAndSettle();

      expect(find.text('First toast'), findsNothing);
      expect(find.text('Second toast'), findsOneWidget);
    });
  });
}
