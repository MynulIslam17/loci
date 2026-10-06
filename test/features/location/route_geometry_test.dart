import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loci/features/location/utils/route_geometry.dart';

void main() {
  test('matches the middle of a long road segment', () {
    final match = closestPointOnRoute(
      const LatLng(23.001, 90.005),
      const <LatLng>[LatLng(23, 90), LatLng(23, 90.01)],
    );
    expect(match, isNotNull);
    expect(match!.segmentIndex, 0);
    expect(match.point.longitude, closeTo(90.005, 0.00001));
    expect(match.distanceMeters, closeTo(111, 2));
    expect(match.distanceAlongMeters, closeTo(512, 3));
    expect(match.routeLengthMeters, closeTo(1025, 5));
  });

  test('progress along the road increases as the user moves forward', () {
    const road = <LatLng>[
      LatLng(23, 90),
      LatLng(23, 90.005),
      LatLng(23, 90.01),
    ];
    final first = closestPointOnRoute(const LatLng(23, 90.002), road)!;
    final later = closestPointOnRoute(const LatLng(23, 90.008), road)!;

    expect(later.distanceAlongMeters, greaterThan(first.distanceAlongMeters));
    expect(
      later.routeLengthMeters - later.distanceAlongMeters,
      lessThan(first.routeLengthMeters - first.distanceAlongMeters),
    );
  });
}
