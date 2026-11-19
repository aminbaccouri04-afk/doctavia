import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppContent {
  static final Map<String, dynamic> _data = {};
  static bool _isInitialized = false;
  static String currentLocale = 'fr';

  static const List<String> _features = [
    'common',
    'analytics',
    'appointments',
    'auth',
    'billing',
    'board',
    'home',
    'notifications',
    'profile',
    'registry',
    'reminders',
    'search',
    'settings',
    'vault',
    'onboarding',
    'chat',
    'staff',
  ];

  /// Initializes the content by loading all JSON files for the French locale.
  static Future<void> initialize() async {
    currentLocale = 'fr';
    
    // Clear existing data
    _data.clear();

    try {
      for (final feature in _features) {
        final path = 'lib/core/content/$currentLocale/content-$feature.json';
        try {
          final jsonString = await rootBundle.loadString(path);
          _data[feature] = jsonDecode(jsonString);
          debugPrint('Loaded content: $feature');
        } catch (e) {
          debugPrint('Failed to load content for $feature at $path: $e');
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading content for locale $currentLocale: $e');
      _isInitialized = true;
    }
  }

  /// Retrieves a string from the content maps using a dot-separated key.
  /// Example: AppContent.get('auth.login.title')
  static String get(String keyPath) {
    if (!_isInitialized) return keyPath;

    final parts = keyPath.split('.');
    dynamic current = _data;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        debugPrint('Missing content key: $keyPath');
        return keyPath; // Fallback to key itself
      }
    }

    return current?.toString() ?? keyPath;
  }

  /// Retrieves a raw object (Map or List) from the content maps.
  static dynamic getRaw(String keyPath) {
    if (!_isInitialized) return null;

    final parts = keyPath.split('.');
    dynamic current = _data;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  static String translateSpecialty(String specialty) {
    switch (specialty) {
      case 'All': return get('search.specialties.all');
      case 'General': return get('search.specialties.general');
      case 'Cardiology': return get('search.specialties.cardiology');
      case 'Neurology': return get('search.specialties.neurology');
      case 'Pediatrics': return get('search.specialties.pediatrics');
      default: return specialty;
    }
  }

  static String translateRelationship(String rel) {
    switch (rel.toLowerCase()) {
      case 'self': return get('profile.family.rel_self');
      case 'spouse': return get('profile.family.rel_spouse');
      case 'child': return get('profile.family.rel_child');
      case 'parent': return get('profile.family.rel_parent');
      case 'sibling': return get('profile.family.rel_sibling');
      default: return rel;
    }
  }

  static String translateHealthMetric(String type) {
    switch (type) {
      case 'Blood Glucose': return get('vault.metrics.glucose');
      case 'Weight': return get('vault.metrics.weight');
      case 'BP (Sys)': return get('vault.metrics.sys');
      default: return type;
    }
  }
}
