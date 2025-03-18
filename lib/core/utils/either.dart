typedef Unit = Object;

typedef Either<L, R> = ({L? left, R? right});

extension EitherX<L, R> on Either<L, R> {
  static Either<L, R> left<L, R>(L left) => (
        left: left,
        right: null,
      );

  static Either<L, R> right<L, R>(R right) => (
        left: null,
        right: right,
      );

  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) {
    if (this.left != null) return onLeft(this.left as L);

    if (this.right != null) return onRight(this.right as R);

    throw 'Unknown type';
  }
}
