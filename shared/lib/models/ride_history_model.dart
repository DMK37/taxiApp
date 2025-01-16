class HistoryRide {
  final String id;
  final String? driver;
  final String client;
  final String destination;
  final String destinationLocation;
  final String source;
  final String sourceLocation;
  final String cost;
  final String status;


  HistoryRide({
    required this.id,
    required this.driver,
    required this.destination,
    required this.source,
    required this.client,
    required this.cost,
    required this.destinationLocation,
    required this.sourceLocation,
    required this.status,
  });

  factory HistoryRide.fromJson(String id, Map<String, dynamic> json) {
    return HistoryRide(
      id: id,
      driver: json['driver'] ?? '',
      destination: json['destination'] ?? 'Unknown',
      source: json['source'] ?? 'Unknown',
      destinationLocation: json['destinationLocation'] ?? 'Unknown',
      sourceLocation: json['sourceLocation'] ?? 'Unknown',
      cost: json['cost'] ?? '',
      client: json['client'] ?? '',
      status: json['status'] ?? '',
    );
  }
}