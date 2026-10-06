/// Address and coordinates returned by the reusable location picker.
class PickedLocation {
  const PickedLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  @override
  String toString() => 'PickedLocation($address, $lat, $lng)';
}
