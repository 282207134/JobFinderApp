import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive demo state only. Passwords, OTPs and CVCs are never persisted.
class AppState extends ChangeNotifier {
  AppState(this.preferences) {
    saved.addAll(preferences.getStringList('saved') ?? []);
    applied.addAll(preferences.getStringList('applied') ?? []);
    recent.addAll(preferences.getStringList('recent') ?? []);
    onboarded = preferences.getBool('onboarded') ?? false;
    signedIn = preferences.getBool('signedIn') ?? false;
    dark = preferences.getBool('dark') ?? false;
    notifications = preferences.getBool('notifications') ?? true;
    name = preferences.getString('name') ?? 'Arthur Dorrance';
    email = preferences.getString('email') ?? 'arthurdorrance@gmail.com';
    phone = preferences.getString('phone') ?? '';
    cardLast4 = preferences.getString('cardLast4');
    final raw = preferences.getString('readNotices');
    if (raw != null) readNotices.addAll((jsonDecode(raw) as List).cast<int>());
  }
  static Future<AppState> load() async =>
      AppState(await SharedPreferences.getInstance());
  final SharedPreferences preferences;
  final Set<String> saved = {}, applied = {};
  final Set<int> readNotices = {};
  final List<String> recent = [];
  late bool onboarded, signedIn, dark, notifications;
  late String name, email, phone;
  String? cardLast4;
  Future<void> toggleSaved(String id) async {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    notifyListeners();
    await preferences.setStringList('saved', saved.toList());
  }

  Future<void> apply(String id) async {
    applied.add(id);
    notifyListeners();
    await preferences.setStringList('applied', applied.toList());
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await preferences.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> signIn({
    String? userName,
    String? userEmail,
    bool remember = true,
  }) async {
    signedIn = true;
    if (userName != null && userName.trim().isNotEmpty) name = userName.trim();
    if (userEmail != null) email = userEmail.trim();
    await preferences.setString('name', name);
    await preferences.setString('email', email);
    await preferences.setBool('signedIn', remember);
    notifyListeners();
  }

  Future<void> signOut() async {
    signedIn = false;
    await preferences.setBool('signedIn', false);
    notifyListeners();
  }

  Future<void> updateProfile(
    String newName,
    String newEmail,
    String newPhone,
  ) async {
    name = newName.trim();
    email = newEmail.trim();
    phone = newPhone.trim();
    await preferences.setString('name', name);
    await preferences.setString('email', email);
    await preferences.setString('phone', phone);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
    await preferences.setBool('dark', value);
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;
    notifyListeners();
    await preferences.setBool('notifications', value);
  }

  Future<void> rememberSearch(String query) async {
    if (query.trim().isEmpty) return;
    recent.remove(query.trim());
    recent.insert(0, query.trim());
    if (recent.length > 5) recent.removeLast();
    notifyListeners();
    await preferences.setStringList('recent', recent);
  }

  Future<void> readNotice(int index) async {
    readNotices.add(index);
    notifyListeners();
    await preferences.setString(
      'readNotices',
      jsonEncode(readNotices.toList()),
    );
  }

  Future<void> addCard(String last4) async {
    cardLast4 = last4;
    notifyListeners();
    await preferences.setString('cardLast4', last4);
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
