import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;

abstract class UsecaseWithParams<T, P> {
  const UsecaseWithParams();
  ResultFuture<T> call(P params);
}

abstract class UsecaseWithoutParams<T> {
  const UsecaseWithoutParams();
  ResultFuture<T> call();
}
