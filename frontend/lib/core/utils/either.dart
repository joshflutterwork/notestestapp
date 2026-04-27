class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isRight;

  Either.left(this._left)
      : _right = null,
        _isRight = false;

  Either.right(this._right)
      : _left = null,
        _isRight = true;

  bool isLeft() => !_isRight;
  bool isRight() => _isRight;

  L? get left => _left;
  R? get right => _right;

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    if (isLeft()) {
      return onLeft(_left as L);
    } else {
      return onRight(_right as R);
    }
  }
}
