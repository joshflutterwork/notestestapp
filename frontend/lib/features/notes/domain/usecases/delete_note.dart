import 'package:equatable/equatable.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';

class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteNoteUseCase implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) {
    return repository.deleteNote(params.id);
  }
}
