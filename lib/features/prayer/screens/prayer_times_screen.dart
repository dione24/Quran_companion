import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/localization/app_localizations.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
        _locationName = 'Current Location';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_prayerTimes == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64),
              const SizedBox(height: 16),
              Text(locale == 'fr' 
                  ? 'Impossible de charger les heures de prière'
                  : 'Unable to load prayer times'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadPrayerTimes,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

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
      body: RefreshIndicator(
        onRefresh: _loadPrayerTimes,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_locationName != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Text(
                        _locationName!,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildPrayerTimeCard('Fajr', _prayerTimes!.fajr),
            _buildPrayerTimeCard('Sunrise', _prayerTimes!.sunrise),
            _buildPrayerTimeCard('Dhuhr', _prayerTimes!.dhuhr),
            _buildPrayerTimeCard('Asr', _prayerTimes!.asr),
            _buildPrayerTimeCard('Maghrib', _prayerTimes!.maghrib),
            _buildPrayerTimeCard('Isha', _prayerTimes!.isha),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(String name, DateTime time) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isPassed = now.isAfter(time);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: isPassed ? Colors.grey : theme.colorScheme.primary,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.grey : null,
          ),
        ),
        trailing: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.grey : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}