import 'package:latlong2/latlong.dart';

class Mosque {
  final String id;
  final String name;
  final String? address;
  final LatLng location;
  final double distance;
  final String? phone;
  final String? website;

  Mosque({
    required this.id,
    required this.name,
    this.address,
    required this.location,
    required this.distance,
    this.phone,
    this.website,
  });

  factory Mosque.fromGeoapifyJson(Map<String, dynamic> json, double userLat, double userLng) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [0.0, 0.0];
    
    final lat = coordinates[1].toDouble();
    final lng = coordinates[0].toDouble();
    final location = LatLng(lat, lng);
    
    // Calculate distance
    final Distance distanceCalculator = Distance();
    final distanceInMeters = distanceCalculator.as(
      LengthUnit.Meter,
      LatLng(userLat, userLng),
      location,
    );
    
    return Mosque(
      id: properties['place_id'] ?? '',
      name: properties['name'] ?? properties['address_line1'] ?? 'Mosque',
      address: properties['formatted'] ?? properties['address_line2'],
      location: location,
      distance: distanceInMeters,
      phone: properties['contact']?['phone'],
      website: properties['contact']?['website'],
    );
  }

  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }
}