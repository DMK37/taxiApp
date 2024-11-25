enum CarType {
  basic(1),
  comfort(2),
  premium(3);

  final int value;

  const CarType(this.value);

  factory CarType.fromValue(int value) {
    return CarType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid TaxiType value: $value'),
    );
  }
}