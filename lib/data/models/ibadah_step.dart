import 'package:flutter/material.dart';

/// Model for umroh worship step/stage
class IbadahStep {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int order;
  final List<StepDetail> details;

  const IbadahStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.order,
    this.details = const [],
  });

  factory IbadahStep.fromJson(Map<String, dynamic> json) {
    return IbadahStep(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: _iconFromString(json['icon'] as String? ?? 'check_circle'),
      order: json['order'] as int? ?? 0,
      details: (json['steps'] as List?)
              ?.map((s) => StepDetail.fromJson(s))
              .toList() ??
          [],
    );
  }

  static IconData _iconFromString(String name) {
    return switch (name) {
      'checkroom' => Icons.checkroom,
      'refresh' => Icons.refresh,
      'directions_walk' => Icons.directions_walk,
      'content_cut' => Icons.content_cut,
      'mosque' => Icons.mosque,
      _ => Icons.check_circle_outline,
    };
  }
}

/// Detail of a single step within an ibadah stage
class StepDetail {
  final int number;
  final String title;
  final String description;
  final String? arabicText;
  final String? translation;

  const StepDetail({
    required this.number,
    required this.title,
    required this.description,
    this.arabicText,
    this.translation,
  });

  factory StepDetail.fromJson(Map<String, dynamic> json) {
    return StepDetail(
      number: json['number'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      arabicText: json['arabic_text'] as String?,
      translation: json['translation'] as String?,
    );
  }
}
