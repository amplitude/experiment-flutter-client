import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/models/variant.dart';

void main() {
  group('Variant', () {
    test('toMap includes all non-null fields', () {
      final variant = Variant(
        key: 'test-key',
        value: 'test-value',
        payload: {'nested': 'data'},
        expKey: 'exp-123',
        metadata: {'meta': 'info'},
      );

      final map = variant.toMap();

      expect(map['key'], 'test-key');
      expect(map['value'], 'test-value');
      expect(map['expKey'], 'exp-123');
      expect(map['payload'], isA<String>()); // JSON encoded
      expect(map['metadata'], isA<String>()); // JSON encoded
    });

    test('toMap excludes null fields', () {
      final variant = Variant();
      final map = variant.toMap();

      expect(map.containsKey('key'), false);
      expect(map.containsKey('value'), false);
    });

    test('fromMap decodes JSON strings correctly', () {
      final map = {
        'key': 'test-key',
        'value': 'test-value',
        'payload': '{"nested":"data"}',
        'metadata': '{"meta":"info"}',
      };

      final variant = Variant.fromMap(map);

      expect(variant.key, 'test-key');
      expect(variant.value, 'test-value');
      expect(variant.payload, {'nested': 'data'});
      expect(variant.metadata, {'meta': 'info'});
    });
    test('fromMap decodes string payloads correctly', () {
      final map = {
        'key': 'test-key',
        'value': 'test-value',
        'payload': '"test-string-payload"',
        'metadata': '{"meta":"info"}',
      };

      final variant = Variant.fromMap(map);

      expect(variant.key, 'test-key');
      expect(variant.value, 'test-value');
      expect(variant.payload, 'test-string-payload');
      expect(variant.metadata, {'meta': 'info'});
    });

    test('fromMap handles string payloads correctly', () {
      final map = {'payload': 'string payload'};

      final variant = Variant.fromMap(map);

      expect(variant.payload, 'string payload');
    });
  });
}
