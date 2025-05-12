class GNLocation {
  GNLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Map<String, Object?> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
