enum TransportType { plane, train, bus, car, walk, bike, other }

class Transport {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final TransportType type;
  final double? price;
  final int timeZoneOffset; // Hours offset change, e.g., +1, -2

  const Transport({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.type,
    this.price,
    this.timeZoneOffset = 0,
  });

  Transport copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
    TransportType? type,
    double? price,
    int? timeZoneOffset,
  }) {
    return Transport(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      timeZoneOffset: timeZoneOffset ?? this.timeZoneOffset,
    );
  }
}
