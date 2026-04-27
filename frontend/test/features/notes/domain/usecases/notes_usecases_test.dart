import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';
import 'package:frontend/features/notes/domain/usecases/get_notes.dart';
import 'package:frontend/features/notes/domain/usecases/create_note.dart';
import 'package:frontend/features/notes/domain/usecases/update_note.dart';
import 'package:frontend/features/notes/domain/usecases/delete_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late MockNotesRepository mockRepository;
  final tNow = DateTime.parse('2026-04-27T12:00:00.000Z');

  final tNote = Note(
    id: '1',
    title: 'Test',
    content: 'Content',
    userId: 'user_1',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUp(() {
    mockRepository = MockNotesRepository();
  });

  group('GetNotesUseCase', () {
    late GetNotesUseCase useCase;

    setUp(() {
      useCase = GetNotesUseCase(mockRepository);
    });

    test('should return list of notes on success', () async {
      when(() => mockRepository.getNotes())
          .thenAnswer((_) async => Either.right([tNote]));

      final result = await useCase(const NoParams());

      expect(result.isRight(), true);
      expect(result.right?.length, 1);
      verify(() => mockRepository.getNotes()).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.getNotes()).thenAnswer(
        (_) async => Either.left(const ServerFailure(message: 'Error')),
      );

      final result = await useCase(const NoParams());

      expect(result.isLeft(), true);
    });
  });

  group('CreateNoteUseCase', () {
    late CreateNoteUseCase useCase;

    setUp(() {
      useCase = CreateNoteUseCase(mockRepository);
    });

    test('should call repository.createNote with correct params', () async {
      when(() => mockRepository.createNote(any(), any()))
          .thenAnswer((_) async => Either.right(tNote));

      const params = CreateNoteParams(title: 'Test', content: 'Content');
      await useCase(params);

      verify(() => mockRepository.createNote('Test', 'Content')).called(1);
    });

    test('should return Note on success', () async {
      when(() => mockRepository.createNote(any(), any()))
          .thenAnswer((_) async => Either.right(tNote));

      const params = CreateNoteParams(title: 'Test', content: 'Content');
      final result = await useCase(params);

      expect(result.isRight(), true);
      expect(result.right?.title, 'Test');
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.createNote(any(), any())).thenAnswer(
        (_) async => Either.left(const ServerFailure(message: 'Failed')),
      );

      const params = CreateNoteParams(title: 'X', content: 'Y');
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('UpdateNoteUseCase', () {
    late UpdateNoteUseCase useCase;

    setUp(() {
      useCase = UpdateNoteUseCase(mockRepository);
    });

    test('should call repository.updateNote with correct params', () async {
      when(() => mockRepository.updateNote(any(), any(), any()))
          .thenAnswer((_) async => Either.right(tNote));

      const params = UpdateNoteParams(
        id: '1',
        title: 'Updated',
        content: 'Updated content',
      );
      await useCase(params);

      verify(() => mockRepository.updateNote('1', 'Updated', 'Updated content'))
          .called(1);
    });

    test('should return updated Note on success', () async {
      when(() => mockRepository.updateNote(any(), any(), any()))
          .thenAnswer((_) async => Either.right(tNote));

      const params = UpdateNoteParams(
        id: '1',
        title: 'Updated',
        content: 'Content',
      );
      final result = await useCase(params);

      expect(result.isRight(), true);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.updateNote(any(), any(), any())).thenAnswer(
        (_) async =>
            Either.left(const ServerFailure(message: 'Not found', statusCode: 404)),
      );

      const params = UpdateNoteParams(
        id: '999',
        title: 'X',
        content: 'Y',
      );
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('DeleteNoteUseCase', () {
    late DeleteNoteUseCase useCase;

    setUp(() {
      useCase = DeleteNoteUseCase(mockRepository);
    });

    test('should call repository.deleteNote with correct id', () async {
      when(() => mockRepository.deleteNote(any()))
          .thenAnswer((_) async => Either.right(null));

      const params = DeleteNoteParams(id: '1');
      await useCase(params);

      verify(() => mockRepository.deleteNote('1')).called(1);
    });

    test('should return void on success', () async {
      when(() => mockRepository.deleteNote(any()))
          .thenAnswer((_) async => Either.right(null));

      const params = DeleteNoteParams(id: '1');
      final result = await useCase(params);

      expect(result.isRight(), true);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.deleteNote(any())).thenAnswer(
        (_) async =>
            Either.left(const ServerFailure(message: 'Forbidden', statusCode: 403)),
      );

      const params = DeleteNoteParams(id: '1');
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
