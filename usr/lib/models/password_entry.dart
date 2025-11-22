import 'package:flutter/material.dart';

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final Color categoryColor;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    required this.createdAt,
    Color? categoryColor,
  }) : categoryColor = categoryColor ?? Colors.blue;

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    DateTime? createdAt,
    Color? categoryColor,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}
