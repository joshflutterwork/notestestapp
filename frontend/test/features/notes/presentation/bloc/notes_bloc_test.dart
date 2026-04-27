import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/usecases/create_note.dart';
import 'package:frontend/features/notes/domain/usecases/delete_note.dart';
import 'package:frontend/features/notes/domain/usecases/get_notes.dart';
import 'package:frontend/features/notes/domain/usecases/update_note.dart';
import 'package:frontend/features/notes/presentation/bloc/notes_bloc.dart';

// Mocks
class MockGetNotesUseCase extends Mock implements GetNotesUseCase {}

class MockCreateNoteUseCase extends Mock implements CreateNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

// Fakes
class FakeNoParams extends Fake implements NoParams {}

class FakeCreateNoteParams extends Fake implements CreateNoteParams {}

class FakeUpdateNoteParams extends Fake implements UpdateNoteParams {}

class FakeDeleteNoteParams extends Fake implements DeleteNoteParams {}

void main() {
  late NotesBloc notesBloc;
  late MockGetNotesUseCase mockGetNotes;
  late MockCreateNoteUseCase mockCreateNote;
  late MockUpdateNoteUseCase mockUpdateNote;
  late MockDeleteNoteUseCase mockDeleteNote;

  final tNow = DateTime.parse('2026-04-27T12:00:00.000Z');
  final tNotes = [
    Note(
      id: '1',
      title: 'Note 1',
      content: 'Content 1',
      userId: 'user_1',
      createdAt: tNow,
      updatedAt: tNow,
    ),
    Note(
      id: '2',
      title: 'Note 2',
      content: 'Content 2',
      userId: 'user_1',
      createdAt: tNow,
      updatedAt: tNow,
    ),
  ];

  final tNewNote = Note(
    id: '3',
    title: 'New Note',
    content: 'New Content',
    userId: 'user_1',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeCreateNoteParams());
    registerFallbackValue(FakeUpdateNoteParams());
    registerFallbackValue(FakeDeleteNoteParams());
  });

  setUp(() {
    mockGetNotes = MockGetNotesUseCase();
    mockCreateNote = MockCreateNoteUseCase();
    mockUpdateNote = MockUpdateNoteUseCase();
    mockDeleteNote = MockDeleteNoteUseCase();
    notesBloc = NotesBloc(
      getNotesUseCase: mockGetNotes,
      createNoteUseCase: mockCreateNote,
      updateNoteUseCase: mockUpdateNote,
      deleteNoteUseCase: mockDeleteNote,
    );
  });

  tearDown(() => notesBloc.close());

  test('initial state should be NotesInitial', () {
    expect(notesBloc.state, isA<NotesInitial>());
  });

  group('LoadNotesEvent', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when loading succeeds',
      build: () {
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Either.right(tNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNotesEvent()),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoaded>().having(
          (s) => s.notes.length,
          'notes count',
          2,
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when loading fails',
      build: () {
        when(() => mockGetNotes(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Server error', statusCode: 500),
          ),
        );
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNotesEvent()),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesError>().having(
          (s) => s.message,
          'error message',
          'Server error',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] with empty list when no notes',
      build: () {
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Either.right([]));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNotesEvent()),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoaded>().having(
          (s) => s.notes.isEmpty,
          'notes empty',
          true,
        ),
      ],
    );
  });

  group('CreateNoteEvent', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when create succeeds and refetch works',
      build: () {
        when(() => mockCreateNote(any()))
            .thenAnswer((_) async => Either.right(tNewNote));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Either.right([...tNotes, tNewNote]));
        return notesBloc;
      },
      act: (bloc) => bloc.add(
        const CreateNoteEvent(title: 'New Note', content: 'New Content'),
      ),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoaded>().having(
          (s) => s.notes.length,
          'notes count',
          3,
        ),
      ],
      verify: (_) {
        verify(() => mockCreateNote(any())).called(1);
        verify(() => mockGetNotes(any())).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when create fails',
      build: () {
        when(() => mockCreateNote(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Failed to create', statusCode: 400),
          ),
        );
        return notesBloc;
      },
      act: (bloc) => bloc.add(
        const CreateNoteEvent(title: 'X', content: 'Y'),
      ),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesError>().having(
          (s) => s.message,
          'error message',
          'Failed to create',
        ),
      ],
    );
  });

  group('UpdateNoteEvent', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when update succeeds',
      build: () {
        final updatedNote = Note(
          id: '1',
          title: 'Updated',
          content: 'Updated content',
          userId: 'user_1',
          createdAt: tNow,
          updatedAt: tNow,
        );
        when(() => mockUpdateNote(any()))
            .thenAnswer((_) async => Either.right(updatedNote));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Either.right([updatedNote, tNotes[1]]));
        return notesBloc;
      },
      act: (bloc) => bloc.add(
        const UpdateNoteEvent(
          id: '1',
          title: 'Updated',
          content: 'Updated content',
        ),
      ),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoaded>().having(
          (s) => s.notes[0].title,
          'updated title',
          'Updated',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when update fails',
      build: () {
        when(() => mockUpdateNote(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Not found', statusCode: 404),
          ),
        );
        return notesBloc;
      },
      act: (bloc) => bloc.add(
        const UpdateNoteEvent(id: '999', title: 'X', content: 'Y'),
      ),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesError>().having(
          (s) => s.message,
          'error message',
          'Not found',
        ),
      ],
    );
  });

  group('DeleteNoteEvent', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when delete succeeds',
      build: () {
        when(() => mockDeleteNote(any()))
            .thenAnswer((_) async => Either.right(null));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Either.right([tNotes[1]]));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const DeleteNoteEvent(id: '1')),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoaded>().having(
          (s) => s.notes.length,
          'notes count',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteNote(any())).called(1);
        verify(() => mockGetNotes(any())).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when delete fails',
      build: () {
        when(() => mockDeleteNote(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Forbidden', statusCode: 403),
          ),
        );
        return notesBloc;
      },
      act: (bloc) => bloc.add(const DeleteNoteEvent(id: '1')),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesError>().having(
          (s) => s.message,
          'error message',
          'Forbidden',
        ),
      ],
    );
  });
}
