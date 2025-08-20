import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class WearPrayerTimesScreen extends StatefulWidget {
  const WearPrayerTimesScreen({super.key});

  @override
  State<WearPrayerTimesScreen> createState() => _WearPrayerTimesScreenState();
}

class _WearPrayerTimesScreenState extends State<WearPrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  Prayer? _nextPrayer;
  Duration? _timeUntilNext;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_prayerTimes != null) {
        _updateNextPrayer();
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get cached location
      double? latitude = prefs.getDouble('latitude');
      double? longitude = prefs.getDouble('longitude');
      
      if (latitude == null || longitude == null) {
        // Get current location
        final position = await Geolocator.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
        
        // Cache location
        await prefs.setDouble('latitude', latitude);
        await prefs.setDouble('longitude', longitude);
      }
      
      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
      });
      
      _updateNextPrayer();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateNextPrayer() {
    if (_prayerTimes == null) return;
    
    final now = DateTime.now();
    Prayer? nextPrayer;
    DateTime? nextPrayerTime;
    
    if (now.isBefore(_prayerTimes!.fajr)) {
      nextPrayer = Prayer.fajr;
      nextPrayerTime = _prayerTimes!.fajr;
    } else if (now.isBefore(_prayerTimes!.dhuhr)) {
      nextPrayer = Prayer.dhuhr;
      nextPrayerTime = _prayerTimes!.dhuhr;
    } else if (now.isBefore(_prayerTimes!.asr)) {
      nextPrayer = Prayer.asr;
      nextPrayerTime = _prayerTimes!.asr;
    } else if (now.isBefore(_prayerTimes!.maghrib)) {
      nextPrayer = Prayer.maghrib;
      nextPrayerTime = _prayerTimes!.maghrib;
    } else if (now.isBefore(_prayerTimes!.isha)) {
      nextPrayer = Prayer.isha;
      nextPrayerTime = _prayerTimes!.isha;
    } else {
      // Next day Fajr
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final coordinates = Coordinates(
        _prayerTimes!.coordinates.latitude,
        _prayerTimes!.coordinates.longitude,
      );
      final params = CalculationMethod.muslim_world_league.getParameters();
      final tomorrowTimes = PrayerTimes(coordinates, DateComponents.from(tomorrow), params);
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowTimes.fajr;
    }
    
    setState(() {
      _nextPrayer = nextPrayer;
      if (nextPrayerTime != null) {
        _timeUntilNext = nextPrayerTime.difference(now);
      }
    });
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Lever du soleil';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
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

    if (_prayerTimes == null) {
      return const Center(
        child: Text(
          'Impossible de charger\nles heures de prière',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          if (_nextPrayer != null && _timeUntilNext != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _getPrayerName(_nextPrayer!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    _formatDuration(_timeUntilNext!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          _buildPrayerTime('Fajr', _prayerTimes!.fajr),
          _buildPrayerTime('Dhuhr', _prayerTimes!.dhuhr),
          _buildPrayerTime('Asr', _prayerTimes!.asr),
          _buildPrayerTime('Maghrib', _prayerTimes!.maghrib),
          _buildPrayerTime('Isha', _prayerTimes!.isha),
        ],
      ),
    );
  }

  Widget _buildPrayerTime(String name, DateTime time) {
    final isPassed = DateTime.now().isAfter(time);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isPassed ? Colors.white30 : Colors.white70,
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPassed ? Colors.white30 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}