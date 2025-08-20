import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class WearQiblaScreen extends StatefulWidget {
  const WearQiblaScreen({super.key});

  @override
  State<WearQiblaScreen> createState() => _WearQiblaScreenState();
}

class _WearQiblaScreenState extends State<WearQiblaScreen> {
  double? _qiblaDirection;
  double? _currentDirection;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition();
      
      // Calculate Qibla direction
      final qiblaDirection = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      
      setState(() {
        _qiblaDirection = qiblaDirection;
        _isLoading = false;
      });
      
      // Listen to compass
      FlutterCompass.events?.listen((event) {
        setState(() {
          _currentDirection = event.heading;
        });
      });
      
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;
    
    final double phiK = kaabaLat * math.pi / 180.0;
    final double lambdaK = kaabaLon * math.pi / 180.0;
    final double phi = latitude * math.pi / 180.0;
    final double lambda = longitude * math.pi / 180.0;
    
    final double y = math.sin(lambdaK - lambda);
    final double x = math.cos(phi) * math.tan(phiK) - 
                    math.sin(phi) * math.cos(lambdaK - lambda);
    
    final double qibla = math.atan2(y, x);
    final double qiblaDegrees = qibla * 180.0 / math.pi;
    
    return (qiblaDegrees + 360) % 360;
  }

  double _getRotationAngle() {
    if (_currentDirection == null || _qiblaDirection == null) return 0;
    
    double rotation = _qiblaDirection! - _currentDirection!;
    return rotation * math.pi / 180;
  }

  bool _isPointingToQibla() {
    if (_currentDirection == null || _qiblaDirection == null) return false;
    
    final difference = (_qiblaDirection! - _currentDirection!).abs();
    return difference < 5 || difference > 355;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.teal,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final isPointingToQibla = _isPointingToQibla();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Qibla',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              // Compass circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPointingToQibla ? Colors.green : Colors.white30,
                    width: 2,
                  ),
                ),
              ),
              // Qibla arrow
              Transform.rotate(
                angle: _getRotationAngle(),
                child: Icon(
                  Icons.navigation,
                  size: 60,
                  color: isPointingToQibla ? Colors.green : Colors.teal,
                ),
              ),
              // Center dot
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentDirection != null)
            Text(
              '${_currentDirection!.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          if (isPointingToQibla)
            const Text(
              '✓ Direction correcte',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}