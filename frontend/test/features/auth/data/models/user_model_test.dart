import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';

void main() {
  const tJson = {
    'access_token': 'test_token_123',
    'user': {
      'id': 'user_1',
      'email': 'test@example.com',
    },
  };

  group('UserModel', () {
    group('fromJson', () {
      test('should return a valid UserModel from JSON', () {
        final model = UserModel.fromJson(tJson);

        expect(model.id, 'user_1');
        expect(model.email, 'test@example.com');
        expect(model.accessToken, 'test_token_123');
      });

      test('should throw when JSON is missing required fields', () {
        expect(
          () => UserModel.fromJson({'user': {}, 'access_token': 'token'}),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should produce correct JSON map', () {
        final model = UserModel.fromJson(tJson);
        final json = model.toJson();

        expect(json['access_token'], 'test_token_123');
        expect(json['user']['id'], 'user_1');
        expect(json['user']['email'], 'test@example.com');
      });

      test('toJson and fromJson should be symmetrical', () {
        final model = UserModel.fromJson(tJson);
        final json = model.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.id, model.id);
        expect(restored.email, model.email);
        expect(restored.accessToken, model.accessToken);
      });
    });

    group('toEntity', () {
      test('should return a User entity', () {
        final model = UserModel.fromJson(tJson);
        final entity = model.toEntity();

        expect(entity, isA<User>());
        expect(entity.id, model.id);
        expect(entity.email, model.email);
        expect(entity.accessToken, model.accessToken);
      });
    });
  });
}
