typedef Unit = Object;

sealed class Either<L, R> {
  const Either();

  factory Either.left(L left) = Left<L, R>;

  factory Either.right(R right) = Right<L, R>;

  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) => switch (this) {
    Left<L, R>(:final L left) => onLeft(left),
    Right<L, R>(:final R right) => onRight(right),
  };
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.left);

  final L left;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.right);

  final R right;
}
