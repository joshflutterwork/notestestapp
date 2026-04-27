import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';

class GetNotesUseCase implements UseCase<List<Note>, NoParams> {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) {
    return repository.getNotes();
  }
}
