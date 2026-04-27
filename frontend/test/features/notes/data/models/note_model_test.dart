import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notes/data/models/note_model.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';

void main() {
  final tCreatedAt = DateTime.parse('2026-04-27T12:00:00.000Z');
  final tUpdatedAt = DateTime.parse('2026-04-27T13:00:00.000Z');

  final tJson = {
    'id': 'note_1',
    'title': 'Test Note',
    'content': 'Test Content',
    'userId': 'user_1',
    'createdAt': '2026-04-27T12:00:00.000Z',
    'updatedAt': '2026-04-27T13:00:00.000Z',
  };

  group('NoteModel', () {
    group('fromJson', () {
      test('should return a valid NoteModel from JSON', () {
        final model = NoteModel.fromJson(tJson);

        expect(model.id, 'note_1');
        expect(model.title, 'Test Note');
        expect(model.content, 'Test Content');
        expect(model.userId, 'user_1');
        expect(model.createdAt, tCreatedAt);
        expect(model.updatedAt, tUpdatedAt);
      });

      test('should throw when JSON has invalid date format', () {
        final badJson = {...tJson, 'createdAt': 'not-a-date'};

        expect(
          () => NoteModel.fromJson(badJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw when JSON is missing required fields', () {
        expect(
          () => NoteModel.fromJson({'id': 'x'}),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should produce correct JSON map', () {
        final model = NoteModel.fromJson(tJson);
        final json = model.toJson();

        expect(json['id'], 'note_1');
        expect(json['title'], 'Test Note');
        expect(json['content'], 'Test Content');
        expect(json['userId'], 'user_1');
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
      });

      test('toJson and fromJson should be symmetrical', () {
        final model = NoteModel.fromJson(tJson);
        final json = model.toJson();
        final restored = NoteModel.fromJson(json);

        expect(restored.id, model.id);
        expect(restored.title, model.title);
        expect(restored.content, model.content);
        expect(restored.userId, model.userId);
        expect(restored.createdAt, model.createdAt);
        expect(restored.updatedAt, model.updatedAt);
      });
    });

    group('toEntity', () {
      test('should return a Note entity', () {
        final model = NoteModel.fromJson(tJson);
        final entity = model.toEntity();

        expect(entity, isA<Note>());
        expect(entity.id, model.id);
        expect(entity.title, model.title);
        expect(entity.content, model.content);
        expect(entity.userId, model.userId);
        expect(entity.createdAt, model.createdAt);
        expect(entity.updatedAt, model.updatedAt);
      });
    });
  });
}
