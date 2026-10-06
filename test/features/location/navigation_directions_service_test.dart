import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loci/features/location/data/services/navigation_directions_service.dart';

void main() {
  test('decodes a valid road polyline and rejects malformed geometry', () {
    final points = RouteDirectionService.decodePolyline(
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    );
    expect(points.length, 3);
    expect(points.first.latitude, closeTo(38.5, 0.00001));
    expect(points.last.longitude, closeTo(-126.453, 0.00001));
    expect(
      () => RouteDirectionService.decodePolyline('invalid'),
      throwsFormatException,
    );
  });

  test('uses Google road geometry and motorcycle travel mode', () async {
    final service = RouteDirectionService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.url.host, 'routes.googleapis.com');
        expect(request.headers['X-Goog-Api-Key'], 'test-key');
        expect(jsonDecode(request.body)['travelMode'], 'TWO_WHEELER');
        expect(jsonDecode(request.body)['polylineQuality'], 'HIGH_QUALITY');
        return http.Response(
          jsonEncode({
            'routes': [
              {
                'distanceMeters': 1200,
                'duration': '180s',
                'polyline': {'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
                'legs': [
                  {
                    'steps': [
                      {
                        'distanceMeters': 500,
                        'startLocation': {
                          'latLng': {'latitude': 38.5, 'longitude': -120.2},
                        },
                        'navigationInstruction': {
                          'instructions': 'Turn right',
                          'maneuver': 'TURN_RIGHT',
                        },
                      },
                    ],
                  },
                ],
              },
            ],
          }),
          200,
        );
      }),
    );

    final result = await service.getDirections(
      originLat: 38.5,
      originLng: -120.2,
      destLat: 43.252,
      destLng: -126.453,
      mode: 'twoWheeler',
    );
    expect(result.polylinePoints.length, 3);
    expect(result.durationText, '3 min');
    expect(result.steps.single.instruction, 'Turn right');
  });

  test('does not invent a straight route when Google has no route', () async {
    final service = RouteDirectionService(
      apiKey: 'test-key',
      client: MockClient((_) async => http.Response('{"routes":[]}', 200)),
    );
    expect(
      service.getDirections(
        originLat: 23.8,
        originLng: 90.4,
        destLat: 23.9,
        destLng: 90.5,
      ),
      throwsA(isA<RouteDirectionException>()),
    );
  });

  test('walk and ride send distinct travel modes', () async {
    final requestedModes = <String>[];
    final service = RouteDirectionService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        requestedModes.add(jsonDecode(request.body)['travelMode'] as String);
        return http.Response('{"routes":[]}', 200);
      }),
    );

    for (final mode in ['walking', 'twoWheeler']) {
      await expectLater(
        service.getDirections(
          originLat: 23.8,
          originLng: 90.4,
          destLat: 23.81,
          destLng: 90.42,
          mode: mode,
        ),
        throwsA(isA<RouteDirectionException>()),
      );
    }
    expect(requestedModes, ['WALK', 'TWO_WHEELER']);
  });
}
