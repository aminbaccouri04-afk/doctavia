import 'package:flutter_test/flutter_test.dart';
import 'package:doctavia/core/providers/provider-content.dart';

void main() {
  group('AppContent Tests', () {
    test('get returns key before initialization', () {
      expect(AppContent.get('any.key'), 'any.key');
    });

    test('translateSpecialty returns untranslated key path before init', () {
      expect(AppContent.translateSpecialty('Cardiology'), 'search.specialties.cardiology');
    });

    test('translateRelationship returns untranslated key path before init', () {
      expect(AppContent.translateRelationship('Spouse'), 'profile.family.rel_spouse');
    });
    
    test('translateHealthMetric returns untranslated key path before init', () {
      expect(AppContent.translateHealthMetric('Weight'), 'vault.metrics.weight');
    });
  });
}
