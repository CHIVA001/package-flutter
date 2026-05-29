import 'package:app_toast/app_toast.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppToast Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppToast Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AppToast.show(
              context,
              title: 'Saved successfully',
              description: 'Your changes were saved.',
              type: AppToastType.success,
              glass: true,
            );
          },
          child: const Text('Show Toast'),
        ),
      ),
    );
  }
}
