import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/api_service.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login.dart';
import 'package:frontend/features/auth/domain/usecases/logout.dart';
import 'package:frontend/features/auth/domain/usecases/register.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:frontend/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:frontend/features/notes/domain/repositories/notes_repository.dart';
import 'package:frontend/features/notes/domain/usecases/create_note.dart';
import 'package:frontend/features/notes/domain/usecases/delete_note.dart';
import 'package:frontend/features/notes/domain/usecases/get_notes.dart';
import 'package:frontend/features/notes/domain/usecases/update_note.dart';
import 'package:frontend/features/notes/presentation/bloc/notes_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ──────────────────── Core ────────────────────
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ApiService>(
    () => ApiService(client: sl(), debugCurl: kDebugMode),
  );
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // ──────────────────── Auth ────────────────────
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
      apiService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // BLoC (factory — new instance each time)
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ──────────────────── Notes ────────────────────
  // Data sources
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));

  // BLoC (factory — new instance each time)
  sl.registerFactory(
    () => NotesBloc(
      getNotesUseCase: sl(),
      createNoteUseCase: sl(),
      updateNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    ),
  );
}
