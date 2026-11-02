import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder/app.dart';
import 'package:job_finder/data/app_state.dart';
import 'package:job_finder/data/jobs.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Pixso screens and complete discovery flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    final navigator = GlobalKey<NavigatorState>();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await tester.pumpWidget(
      JobFinderApp(state: state, navigatorKey: navigator),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    Future<void> hideKeyboard() async {
      FocusManager.instance.primaryFocus?.unfocus();
      binding.focusedEditable = null;
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await tester.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      await hideKeyboard();
      ScaffoldMessenger.of(navigator.currentContext!).removeCurrentSnackBar();
      binding.scheduleFrame();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: name);
      await binding.takeScreenshot(name);
    }

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> fill(String label, String value) async {
      final finder = find.byKey(ValueKey('field-$label'));
      await tester.ensureVisible(finder);
      await tester.enterText(finder, value);
      await tester.pumpAndSettle();
    }

    Future<void> route(String name, {Object? args}) async {
      await hideKeyboard();
      ScaffoldMessenger.of(navigator.currentContext!).removeCurrentSnackBar();
      navigator.currentState!.pushNamedAndRemoveUntil(
        name,
        (_) => false,
        arguments: args,
      );
      await tester.pumpAndSettle();
    }

    Future<void> top() async {
      final scroll = find.byType(SingleChildScrollView);
      if (scroll.evaluate().isNotEmpty) {
        await tester.drag(scroll.first, const Offset(0, 1500));
        await tester.pumpAndSettle();
      }
    }

    await shot('01-onboarding-dream');
    await tap(find.byKey(const ValueKey('onboarding-next')));
    await shot('02-onboarding-application');
    await tap(find.byKey(const ValueKey('onboarding-next')));
    await shot('03-onboarding-career');
    await tap(find.byKey(const ValueKey('onboarding-next')));
    await shot('04-login-empty');
    await fill('Email', 'arthurdorrance@gmail.com');
    await fill('Password', 'Preview123');
    await hideKeyboard();
    await tap(find.byType(Checkbox));
    await shot('05-login-filled');
    await tap(find.widgetWithText(FilledButton, 'Log In'));
    expect(find.text('Recommended'), findsOneWidget);
    expect(state.signedIn, isTrue);
    await shot('12-home');

    await route('/signup');
    await shot('06-signup-empty');
    await fill('Username', 'Arthur Dorrance');
    await fill('Email', 'arthurdorrance@gmail.com');
    await fill('Password', 'Preview123');
    await fill('Confirm Password', 'Preview123');
    await hideKeyboard();
    await tap(find.byType(Checkbox));
    await top();
    await shot('07-signup-filled');
    await tap(find.widgetWithText(FilledButton, 'Sign Up'));
    expect(find.text('Add Number'), findsOneWidget);
    await fill('Phone Number', '+1 15096581538');
    await shot('11-phone-number');
    await tap(find.widgetWithText(FilledButton, 'Continue'));
    expect(state.phone, '+1 15096581538');

    await route('/forgot');
    await fill('Email', 'arthurdorrance@gmail.com');
    await shot('08-forgot-password');
    await tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.enterText(find.byKey(const ValueKey('otp-0')), '7');
    await tester.enterText(find.byKey(const ValueKey('otp-1')), '9');
    ScaffoldMessenger.of(navigator.currentContext!).clearSnackBars();
    await shot('09-otp-verification');
    await tester.enterText(find.byKey(const ValueKey('otp-2')), '0');
    await tester.enterText(find.byKey(const ValueKey('otp-3')), '0');
    await tap(find.widgetWithText(FilledButton, 'Continue'));
    await fill('Password', 'NewPreview123');
    await fill('Confirm Password', 'NewPreview123');
    await shot('10-reset-password');
    await tap(find.widgetWithText(FilledButton, 'Continue'));
    expect(find.text('Welcome Back'), findsOneWidget);

    await route('/search');
    await shot('13-search-recent');
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'Business Management',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await shot('14-search-results');
    expect(find.text('Search Result'), findsOneWidget);
    await tap(find.byKey(const ValueKey('filter-button')));
    await shot('21-filter-empty');
    await tap(find.byKey(const ValueKey('filter-Category-null')));
    await tap(find.text('Business Management').last);
    await tap(find.byKey(const ValueKey('filter-Location-null')));
    await tap(find.text('New York, NY 10003').last);
    final slider = find.byType(RangeSlider);
    await tester.ensureVisible(slider);
    final rect = tester.getRect(slider);
    await tester.dragFrom(
      Offset(rect.right - 24, rect.center.dy),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();
    await tap(find.text('Part Time'));
    await shot('22-filter-filled');
    await tap(find.widgetWithText(FilledButton, 'Apply Filter'));
    expect(find.text('Search Result'), findsOneWidget);
    expect(find.text('Web Developer'), findsNothing);
    expect(find.text('Marketing Manager'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'no-such-position',
    );
    final search = tester.widget<TextField>(
      find.byKey(const ValueKey('search-field')),
    );
    expect(search.controller!.text, 'no-such-position');
    await shot('35-search-empty');
    expect(find.text('No jobs found'), findsOneWidget);

    await route('/categories');
    await shot('15-categories');
    await tap(find.widgetWithText(FilledButton, 'Show All'));
    await shot('16-categories-all');
    await tap(find.byKey(const ValueKey('category-Design')));
    expect(find.text('Web Developer'), findsOneWidget);
    await route('/popular');
    await shot('17-popular-jobs');
    await route('/job', args: jobs[8]);
    await shot('18-job-description');
    await tap(find.byKey(const ValueKey('job-tab-1')));
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await shot('19-job-map');
    await tap(find.byKey(const ValueKey('job-tab-2')));
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await shot('20-job-review');
    await tap(find.byKey(const ValueKey('save-job')));
    expect(state.saved, contains('manager'));
    await tap(find.widgetWithText(FilledButton, 'Apply'));
    await shot('32-application-confirm');
    await tap(find.widgetWithText(FilledButton, 'Confirm Application'));
    expect(state.applied, contains('manager'));
    await route('/saved');
    await shot('31-saved-jobs');
    await route('/applications');
    await shot('33-my-applications');
    await route('/notifications');
    await shot('29-notifications');
    await tap(find.text('Good News'));
    expect(state.readNotices, contains(0));
    await tap(find.text('Close'));
    await route('/profile');
    await shot('24-profile');
    await tap(find.text('My Account'));
    await shot('34-my-account');
    await route('/settings');
    await shot('25-settings');
    await tap(find.byKey(const ValueKey('dark-switch')));
    expect(state.dark, isTrue);
    await shot('36-settings-dark');
    await tap(find.byKey(const ValueKey('dark-switch')));
    await tap(find.byKey(const ValueKey('notification-switch')));
    expect(state.notifications, isFalse);
    await route('/activity');
    await shot('23-activity');
    await route('/payments');
    await shot('26-payment-methods');
    await tap(find.byTooltip('Add card'));
    await shot('27-add-card-empty');
    await fill('Cardholder Name', 'Arthur Dorrance');
    await fill('Card No', '4111111111111111');
    await fill('Expire Date', '12/30');
    await fill('CVC', '768');
    await hideKeyboard();
    final cardList = find.byType(ListView);
    await tester.drag(cardList, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await shot('28-add-card-filled');
    await tap(find.widgetWithText(FilledButton, 'Add Now'));
    expect(state.cardLast4, '1111');
    await route('/map');
    await shot('30-map');
    await tap(find.byTooltip('Zoom in'));
    await tap(find.byTooltip('Recenter map'));
    await route('/help');
    await shot('37-help');
    await route('/home');
    await state.setDark(true);
    await tester.pumpAndSettle();
    await shot('38-home-dark');
    await state.setDark(false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 8)));
}
