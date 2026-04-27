import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
