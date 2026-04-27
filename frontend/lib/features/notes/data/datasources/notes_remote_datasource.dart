import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/utils/api_service.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/notes/data/models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<Either<Failure, List<NoteModel>>> getNotes();
  Future<Either<Failure, NoteModel>> createNote(String title, String content);
  Future<Either<Failure, NoteModel>> updateNote(
    String id,
    String title,
    String content,
  );
  Future<Either<Failure, void>> deleteNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiService apiService;

  NotesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Either<Failure, List<NoteModel>>> getNotes() {
    return apiService.get(
      ApiConstants.notes,
      (data) => (data as List).map((e) => NoteModel.fromJson(e)).toList(),
      requiresAuth: true,
    );
  }

  @override
  Future<Either<Failure, NoteModel>> createNote(String title, String content) {
    return apiService.post(
      ApiConstants.notes,
      {'title': title, 'content': content},
      (data) => NoteModel.fromJson(data),
      requiresAuth: true,
    );
  }

  @override
  Future<Either<Failure, NoteModel>> updateNote(
    String id,
    String title,
    String content,
  ) {
    return apiService.put(
      ApiConstants.noteById(id),
      {'title': title, 'content': content},
      (data) => NoteModel.fromJson(data),
      requiresAuth: true,
    );
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) {
    return apiService.delete(
      ApiConstants.noteById(id),
      (_) {},
      requiresAuth: true,
    );
  }
}
