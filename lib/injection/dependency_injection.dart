import 'package:get_it/get_it.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/note_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/note_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/note_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';

final sl = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> initDependencies() async {
  // ========================
  // Data Sources
  // ========================
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<NoteRemoteDataSource>(() => NoteRemoteDataSource());

  // ========================
  // Repositories
  // ========================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(sl<NoteRemoteDataSource>()),
  );

  // ========================
  // BLoCs
  // ========================
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
}
