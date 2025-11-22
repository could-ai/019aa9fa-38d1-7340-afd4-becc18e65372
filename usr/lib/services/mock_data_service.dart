import 'package:flutter/foundation.dart';
import '../models/password_entry.dart';

class MockDataService extends ChangeNotifier {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<PasswordEntry> _entries = [
    PasswordEntry(
      id: '1',
      title: 'Google Account',
      username: 'user@gmail.com',
      password: 'password123',
      url: 'https://google.com',
      notes: 'Main personal email',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PasswordEntry(
      id: '2',
      title: 'Netflix',
      username: 'movie_fan',
      password: 'secure_password_456',
      url: 'https://netflix.com',
      notes: 'Family plan',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PasswordEntry(
      id: '3',
      title: 'GitHub',
      username: 'dev_guru',
      password: 'gh_token_789',
      url: 'https://github.com',
      createdAt: DateTime.now(),
    ),
  ];

  List<PasswordEntry> get entries => List.unmodifiable(_entries);

  void addEntry(PasswordEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void updateEntry(PasswordEntry updatedEntry) {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
    }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
