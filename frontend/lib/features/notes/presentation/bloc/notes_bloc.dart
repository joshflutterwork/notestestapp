import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/usecases/create_note.dart';
import 'package:frontend/features/notes/domain/usecases/delete_note.dart';
import 'package:frontend/features/notes/domain/usecases/get_notes.dart';
import 'package:frontend/features/notes/domain/usecases/update_note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesBloc({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    final result = await getNotesUseCase(const NoParams());
    result.fold(
      (failure) => emit(NotesError(message: failure.message)),
      (notes) => emit(NotesLoaded(notes: notes)),
    );
  }

  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    final result = await createNoteUseCase(
      CreateNoteParams(title: event.title, content: event.content),
    );
    await result.fold(
      (failure) async {
        emit(NotesError(message: failure.message));
      },
      (_) async {
        // After successful creation, fetch the updated list from server
        final notesResult = await getNotesUseCase(const NoParams());
        notesResult.fold(
          (failure) => emit(NotesError(message: failure.message)),
          (notes) => emit(NotesLoaded(notes: notes)),
        );
      },
    );
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    final result = await updateNoteUseCase(
      UpdateNoteParams(
        id: event.id,
        title: event.title,
        content: event.content,
      ),
    );
    await result.fold(
      (failure) async {
        emit(NotesError(message: failure.message));
      },
      (_) async {
        // After successful update, fetch the updated list from server
        final notesResult = await getNotesUseCase(const NoParams());
        notesResult.fold(
          (failure) => emit(NotesError(message: failure.message)),
          (notes) => emit(NotesLoaded(notes: notes)),
        );
      },
    );
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.id));
    await result.fold(
      (failure) async {
        emit(NotesError(message: failure.message));
      },
      (_) async {
        // After successful deletion, fetch the updated list from server
        final notesResult = await getNotesUseCase(const NoParams());
        notesResult.fold(
          (failure) => emit(NotesError(message: failure.message)),
          (notes) => emit(NotesLoaded(notes: notes)),
        );
      },
    );
  }
}
