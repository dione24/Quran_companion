import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'screens/wear_home_screen.dart';
import 'screens/wear_prayer_times_screen.dart';
import 'screens/wear_qibla_screen.dart';
import 'screens/wear_daily_verse_screen.dart';

class WearApp extends StatefulWidget {
  const WearApp({super.key});

  @override
  State<WearApp> createState() => _WearAppState();
}

class _WearAppState extends State<WearApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Companion',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (BuildContext context, WearShape shape, Widget? child) {
        return AmbientMode(
          builder: (BuildContext context, WearMode mode, Widget? child) {
            return mode == WearMode.active
                ? const ActiveWatchFace()
                : const AmbientWatchFace();
          },
        );
      },
    );
  }
}

class ActiveWatchFace extends StatefulWidget {
  const ActiveWatchFace({super.key});

  @override
  State<ActiveWatchFace> createState() => _ActiveWatchFaceState();
}

class _ActiveWatchFaceState extends State<ActiveWatchFace> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const WearHomeScreen(),
    const WearDailyVerseScreen(),
    const WearPrayerTimesScreen(),
    const WearQiblaScreen(),
  ];
  
  final List<IconData> _icons = [
    Icons.home,
    Icons.book,
    Icons.access_time,
    Icons.explore,
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _screens[_selectedIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _icons.length,
                  (index) => IconButton(
                    icon: Icon(
                      _icons[index],
                      size: 20,
                      color: _selectedIndex == index
                          ? Colors.teal
                          : Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AmbientWatchFace extends StatefulWidget {
  const AmbientWatchFace({super.key});

  @override
  State<AmbientWatchFace> createState() => _AmbientWatchFaceState();
}

class _AmbientWatchFaceState extends State<AmbientWatchFace> {
  late Timer _timer;
  DateTime _dateTime = DateTime.now();
  String? _nextPrayer;
  String? _nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadPrayerTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
    });
  }

  Future<void> _loadPrayerTime() async {
    // Load next prayer time from shared preferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nextPrayer = prefs.getString('next_prayer_name');
      _nextPrayerTime = prefs.getString('next_prayer_time');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            if (_nextPrayer != null && _nextPrayerTime != null)
              Text(
                '$_nextPrayer $_nextPrayerTime',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}