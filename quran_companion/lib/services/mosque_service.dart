import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/mosque.dart';

class MosqueService {
  static const String baseUrl = 'https://api.geoapify.com/v2/places';
  
  Future<List<Mosque>> getNearbyMosques({
    required double latitude,
    required double longitude,
    int radius = 5000, // 5km default
    int limit = 20,
  }) async {
    try {
      // Use hardcoded API key
      const apiKey = '8ce0d8cf73c448b0b5f4f0c0c548d270';
      
      // Build URL with parameters
      final params = {
        'categories': 'tourism.sights.place_of_worship.mosque',
        'filter': 'circle:$longitude,$latitude,$radius',
        'limit': limit.toString(),
        'apiKey': apiKey,
      };
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        
        return features
            .map((json) => Mosque.fromGeoapifyJson(json, latitude, longitude))
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Geoapify API key.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load mosques');
      }
    } catch (e) {
      throw Exception('Error finding mosques: $e');
    }
  }
  
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }
    
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in settings.');
    }
    
    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}