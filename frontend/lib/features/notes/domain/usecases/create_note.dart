import 'package:equatable/equatable.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';

class CreateNoteParams extends Equatable {
  final String title;
  final String content;

  const CreateNoteParams({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class CreateNoteUseCase implements UseCase<Note, CreateNoteParams> {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, Note>> call(CreateNoteParams params) {
    return repository.createNote(params.title, params.content);
  }
}
