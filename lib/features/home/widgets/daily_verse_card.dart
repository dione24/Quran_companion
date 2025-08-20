import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/widget_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/theme/app_theme.dart';

class DailyVerseCard extends ConsumerStatefulWidget {
  const DailyVerseCard({super.key});

  @override
  ConsumerState<DailyVerseCard> createState() => _DailyVerseCardState();
}

class _DailyVerseCardState extends ConsumerState<DailyVerseCard> {
  Map<String, String> _verseData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    final data = await WidgetService.getDailyVerse();
    if (mounted) {
      setState(() {
        _verseData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to full verse view
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.teal.shade800, Colors.teal.shade900]
                  : [Colors.teal.shade50, Colors.teal.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'fr' ? 'Verset du jour' : 'Daily Verse',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        color: isDark ? Colors.white70 : Colors.black54,
                        onPressed: () async {
                          final shareService = ref.read(shareServiceProvider);
                          await shareService.shareVerse(
                            arabicText: _verseData['arabic'] ?? '',
                            translation: _verseData['translation'] ?? '',
                            surahName: _verseData['reference']?.split(' ').first ?? '',
                            verseNumber: int.tryParse(
                              _verseData['reference']?.split(' ').last ?? '1'
                            ) ?? 1,
                            language: locale,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 20),
                        color: isDark ? Colors.white70 : Colors.black54,
                        onPressed: () {
                          // Add to bookmarks
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _verseData['arabic'] ?? '',
                  style: AppTheme.arabicTextStyle(
                    fontSize: 22,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _verseData['translation'] ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _verseData['reference'] ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}