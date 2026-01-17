import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/models/experiment_user.dart';

void main() {
  group('ExperimentUser', () {
    test('toMap encodes complex fields as JSON', () {
      final user = ExperimentUser(
        userId: 'user-123',
        userProperties: {'prop1': 'value1'},
        groups: {
          'group1': ['member1', 'member2'],
        },
        groupProperties: {
          'group1': {'role': 'admin'},
        },
      );

      final map = user.toMap();

      expect(map['userId'], 'user-123');
      expect(map['userProperties'], isA<String>()); // JSON encoded
      expect(map['groups'], isA<String>()); // JSON encoded
    });

    test('fromMap decodes JSON strings from native', () {
      final map = {
        'userId': 'user-123',
        'userProperties': '{"prop1":"value1"}',
        'groups': '{"group1":["member1"]}',
      };

      final user = ExperimentUser.fromMap(map);

      expect(user.userId, 'user-123');
      expect(user.userProperties, {'prop1': 'value1'});
      expect(user.groups, {
        'group1': ['member1'],
      });
    });

    test('fromMap handles native Map format', () {
      final map = {
        'userId': 'user-123',
        'userProperties': {'prop1': 'value1'}, // Already a Map
        'groups': {
          'group1': ['member1'],
        }, // Already a Map
      };

      final user = ExperimentUser.fromMap(map);

      expect(user.userId, 'user-123');
      expect(user.userProperties, {'prop1': 'value1'});
      expect(user.groups, {
        'group1': ['member1'],
      });
    });
  });
}
