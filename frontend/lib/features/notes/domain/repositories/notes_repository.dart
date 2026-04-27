import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Note>> createNote(String title, String content);
  Future<Either<Failure, Note>> updateNote(
    String id,
    String title,
    String content,
  );
  Future<Either<Failure, void>> deleteNote(String id);
}
