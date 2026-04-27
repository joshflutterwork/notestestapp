import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:frontend/features/notes/domain/entities/note.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    final result = await remoteDataSource.getNotes();
    return result.fold(
      (failure) => Either.left(failure),
      (noteModels) =>
          Either.right(noteModels.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, Note>> createNote(String title, String content) async {
    final result = await remoteDataSource.createNote(title, content);
    return result.fold(
      (failure) => Either.left(failure),
      (noteModel) => Either.right(noteModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Note>> updateNote(
    String id,
    String title,
    String content,
  ) async {
    final result = await remoteDataSource.updateNote(id, title, content);
    return result.fold(
      (failure) => Either.left(failure),
      (noteModel) => Either.right(noteModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    return remoteDataSource.deleteNote(id);
  }
}
