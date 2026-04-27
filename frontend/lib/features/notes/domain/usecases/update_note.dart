import 'package:equatable/equatable.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteParams extends Equatable {
  final String id;
  final String title;
  final String content;

  const UpdateNoteParams({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class UpdateNoteUseCase implements UseCase<Note, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, Note>> call(UpdateNoteParams params) {
    return repository.updateNote(params.id, params.title, params.content);
  }
}
