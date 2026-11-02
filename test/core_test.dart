import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder/data/app_state.dart';
import 'package:job_finder/data/jobs.dart';
import 'package:job_finder/features/payments/payment_pages.dart';
import 'package:job_finder/widgets/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('search combines keyword, price, category and type', () {
    final result = findJobs(
      'Business Management',
      filter: const JobFilter(min: 40, max: 50, type: 'Part Time'),
    );
    expect(result.map((j) => j.id), containsAll(['marketing', 'manager']));
    expect(
      result.every(
        (j) => j.rate >= 40 && j.rate <= 50 && j.type == 'Part Time',
      ),
      isTrue,
    );
  });
  test('search has an empty state and rating sorting', () {
    expect(findJobs('no-such-position'), isEmpty);
    final sorted = findJobs('', sort: 'Top');
    for (var i = 1; i < sorted.length; i++) {
      expect(sorted[i - 1].rating >= sorted[i].rating, isTrue);
    }
    expect(findJobs('', filter: const JobFilter(location: 'Remote')), isEmpty);
  });
  test('filters isolate selected categories', () {
    expect(
      findJobs('', filter: const JobFilter(category: 'Design')).single.id,
      'developer',
    );
    expect(findJobs('', filter: const JobFilter(min: 100)), isEmpty);
  });
  test('bookmarks, applications and settings survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    await state.toggleSaved('manager');
    await state.apply('manager');
    await state.apply('manager');
    await state.setDark(true);
    await state.setNotifications(false);
    await state.readNotice(1);
    final restored = await AppState.load();
    expect(restored.saved, {'manager'});
    expect(restored.applied, {'manager'});
    expect(restored.dark, isTrue);
    expect(restored.notifications, isFalse);
    expect(restored.readNotices, {1});
    await restored.toggleSaved('manager');
    expect((await AppState.load()).saved, isEmpty);
    state.dispose();
    restored.dispose();
  });
  test('recent queries are deduplicated and bounded', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    for (final query in [
      'Business',
      'Design',
      'Food',
      'Medical',
      'Management',
      'Engineering',
      'Design',
      '',
    ]) {
      await state.rememberSearch(query);
    }
    expect(state.recent.length, 5);
    expect(state.recent.first, 'Design');
    expect(state.recent.toSet().length, 5);
    state.dispose();
  });
  test('remember me controls restoration and logout clears session', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    await state.signIn(remember: false);
    expect(state.signedIn, isTrue);
    expect((await AppState.load()).signedIn, isFalse);
    await state.signIn(remember: true);
    expect((await AppState.load()).signedIn, isTrue);
    await state.signOut();
    expect((await AppState.load()).signedIn, isFalse);
    state.dispose();
  });
  test('profile and only card suffix are stored', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    await state.updateProfile(
      ' Arthur Dorrance ',
      'arthur@example.com',
      '+1 1234567890',
    );
    await state.addCard('1111');
    final restored = await AppState.load();
    expect(restored.name, 'Arthur Dorrance');
    expect(restored.email, 'arthur@example.com');
    expect(restored.cardLast4, '1111');
    expect(state.preferences.getKeys(), isNot(contains('cvc')));
    expect(state.preferences.getKeys(), isNot(contains('password')));
    state.dispose();
    restored.dispose();
  });
  test('payment validation rejects bad checksums and expired cards', () {
    expect(validCardNumber('4111111111111111'), isTrue);
    expect(validCardNumber('4111111111111112'), isFalse);
    expect(validCardNumber('123'), isFalse);
    expect(expiryValidator('13/30'), isNotNull);
    expect(expiryValidator('01/20'), isNotNull);
    expect(expiryValidator('00/00'), isNotNull);
    expect(expiryValidator('12/40'), isNull);
  });
  test('auth validation rejects malformed input', () {
    expect(emailValidator('bad-address'), isNotNull);
    expect(emailValidator('arthur@example.com'), isNull);
    expect(passwordValidator('short'), isNotNull);
    expect(passwordValidator('Preview123'), isNull);
    expect(requiredText('  '), isNotNull);
  });
}
