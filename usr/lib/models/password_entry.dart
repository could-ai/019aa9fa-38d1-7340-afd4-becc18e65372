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

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      url: json['url'],
      notes: json['notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      categoryColor: json['category_color'] != null
          ? Color(int.parse(json['category_color'], radix: 16))
          : Colors.blue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'category_color': categoryColor.value.toRadixString(16).padLeft(8, '0'),
    };
  }

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
