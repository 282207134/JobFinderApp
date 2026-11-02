import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder/app.dart';
import 'package:job_finder/data/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    await loader.load();
  });
  for (final size in [const Size(320, 640), const Size(414, 896)]) {
    testWidgets('all routes fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final state = (await tester.runAsync(AppState.load))!;
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(JobFinderApp(state: state, navigatorKey: nav));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final route in [
        '/login',
        '/signup',
        '/forgot',
        '/otp',
        '/reset',
        '/phone',
        '/home',
        '/search',
        '/categories',
        '/popular',
        '/saved',
        '/applications',
        '/filter',
        '/job',
        '/map',
        '/profile',
        '/account',
        '/settings',
        '/activity',
        '/notifications',
        '/help',
        '/payments',
        '/card',
      ]) {
        nav.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route at $size');
      }
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
