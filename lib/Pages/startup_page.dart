import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartup extends ConsumerWidget {
  final Widget child;
  const AppStartup({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesAsyncProvider);

    return exercisesAsync.when(
      data: (_) => child,
      loading: () => const _SplashScreen(),
      error: (err, stack) => _SplashScreen(error: err),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  final Object? error;
  const _SplashScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: error != null
              ? Text('Failed to load data: $error')
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}