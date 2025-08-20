import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  Prayer? _nextPrayer;
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }
  
  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      _currentPosition = await Geolocator.getCurrentPosition();
      
      // Calculate prayer times
      final coordinates = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayerTimes = PrayerTimes.today(coordinates, params);
      final nextPrayer = prayerTimes.nextPrayer();
      
      setState(() {
        _prayerTimes = prayerTimes;
        _nextPrayer = nextPrayer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrayerTimes,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _prayerTimes != null
                  ? RefreshIndicator(
                      onRefresh: _loadPrayerTimes,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Current location card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Current Location',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lat: ${_currentPosition?.latitude.toStringAsFixed(4)}, '
                                    'Lng: ${_currentPosition?.longitude.toStringAsFixed(4)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Next prayer card
                          if (_nextPrayer != null)
                            Card(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      'Next Prayer',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getPrayerName(_nextPrayer!, l10n),
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(_getPrayerTime(_nextPrayer!)),
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getTimeRemaining(_getPrayerTime(_nextPrayer!)),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Prayer times list
                          _buildPrayerTimeCard(
                            l10n.fajr,
                            _prayerTimes!.fajr,
                            Icons.wb_twilight,
                            _nextPrayer == Prayer.fajr,
                          ),
                          _buildPrayerTimeCard(
                            l10n.sunrise,
                            _prayerTimes!.sunrise,
                            Icons.wb_sunny,
                            _nextPrayer == Prayer.sunrise,
                          ),
                          _buildPrayerTimeCard(
                            l10n.dhuhr,
                            _prayerTimes!.dhuhr,
                            Icons.wb_sunny,
                            _nextPrayer == Prayer.dhuhr,
                          ),
                          _buildPrayerTimeCard(
                            l10n.asr,
                            _prayerTimes!.asr,
                            Icons.wb_cloudy,
                            _nextPrayer == Prayer.asr,
                          ),
                          _buildPrayerTimeCard(
                            l10n.maghrib,
                            _prayerTimes!.maghrib,
                            Icons.wb_twilight,
                            _nextPrayer == Prayer.maghrib,
                          ),
                          _buildPrayerTimeCard(
                            l10n.isha,
                            _prayerTimes!.isha,
                            Icons.nightlight_round,
                            _nextPrayer == Prayer.isha,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
    );
  }
  
  Widget _buildPrayerTimeCard(String name, DateTime time, IconData icon, bool isNext) {
    final isPassed = time.isBefore(DateTime.now()) && !isNext;
    
    return Card(
      elevation: isNext ? 4 : 1,
      color: isNext
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isPassed ? Colors.grey : null,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isPassed ? Colors.grey : null,
          ),
        ),
        trailing: Text(
          _formatTime(time),
          style: TextStyle(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isPassed ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }
  
  String _getTimeRemaining(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.isNegative) {
      // Prayer time has passed, calculate time until tomorrow's prayer
      final tomorrow = time.add(const Duration(days: 1));
      final tomorrowDifference = tomorrow.difference(now);
      final hours = tomorrowDifference.inHours;
      final minutes = tomorrowDifference.inMinutes % 60;
      return 'in $hours hours $minutes minutes (tomorrow)';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return 'in $hours hours $minutes minutes';
    } else {
      return 'in $minutes minutes';
    }
  }
  
  String _getPrayerName(Prayer prayer, AppLocalizations l10n) {
    switch (prayer) {
      case Prayer.fajr:
        return l10n.fajr;
      case Prayer.sunrise:
        return l10n.sunrise;
      case Prayer.dhuhr:
        return l10n.dhuhr;
      case Prayer.asr:
        return l10n.asr;
      case Prayer.maghrib:
        return l10n.maghrib;
      case Prayer.isha:
        return l10n.isha;
      default:
        return '';
    }
  }
  
  DateTime _getPrayerTime(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return _prayerTimes!.fajr;
      case Prayer.sunrise:
        return _prayerTimes!.sunrise;
      case Prayer.dhuhr:
        return _prayerTimes!.dhuhr;
      case Prayer.asr:
        return _prayerTimes!.asr;
      case Prayer.maghrib:
        return _prayerTimes!.maghrib;
      case Prayer.isha:
        return _prayerTimes!.isha;
      default:
        return DateTime.now();
    }
  }
}