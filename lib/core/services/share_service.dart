import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

class ShareService {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  Future<void> shareVerse({
    required String arabicText,
    required String translation,
    required String surahName,
    required int verseNumber,
    required String language,
  }) async {
    final String shareText = '''
$arabicText

$translation

📖 $surahName - ${language == 'fr' ? 'Verset' : 'Verse'} $verseNumber
${language == 'fr' ? 'Partagé depuis Compagnon du Coran' : 'Shared from Quran Companion'}
    ''';
    
    await shareText(shareText, subject: '$surahName - ${language == 'fr' ? 'Verset' : 'Verse'} $verseNumber');
  }

  Future<void> shareProgress({
    required int readingStreak,
    required double completionPercentage,
    required int versesMemorized,
    required String language,
  }) async {
    final String shareText = language == 'fr' 
        ? '''
🌟 Mon progrès dans le Coran 🌟

📚 Série de lecture: $readingStreak jours
📊 Progression: ${completionPercentage.toStringAsFixed(1)}% complété
🧠 Versets mémorisés: $versesMemorized

Partagé depuis Compagnon du Coran
#Coran #Islam #Lecture
        '''
        : '''
🌟 My Quran Progress 🌟

📚 Reading Streak: $readingStreak days
📊 Progress: ${completionPercentage.toStringAsFixed(1)}% complete
🧠 Verses Memorized: $versesMemorized

Shared from Quran Companion
#Quran #Islam #Reading
        ''';
    
    await shareText(shareText);
  }

  Future<void> shareProgressCard({
    required BuildContext context,
    required int readingStreak,
    required double completionPercentage,
    required int versesMemorized,
    required String language,
  }) async {
    final widget = _buildProgressCard(
      readingStreak: readingStreak,
      completionPercentage: completionPercentage,
      versesMemorized: versesMemorized,
      language: language,
    );
    
    await _shareWidget(widget, 'progress_card.png');
  }

  Future<void> shareVerseCard({
    required BuildContext context,
    required String arabicText,
    required String translation,
    required String surahName,
    required int verseNumber,
    required String language,
  }) async {
    final widget = _buildVerseCard(
      arabicText: arabicText,
      translation: translation,
      surahName: surahName,
      verseNumber: verseNumber,
      language: language,
    );
    
    await _shareWidget(widget, 'verse_card.png');
  }

  Widget _buildProgressCard({
    required int readingStreak,
    required double completionPercentage,
    required int versesMemorized,
    required String language,
  }) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language == 'fr' ? '🌟 Mon Progrès 🌟' : '🌟 My Progress 🌟',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatRow(
            icon: Icons.local_fire_department,
            label: language == 'fr' ? 'Série' : 'Streak',
            value: '$readingStreak ${language == 'fr' ? 'jours' : 'days'}',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.pie_chart,
            label: language == 'fr' ? 'Progression' : 'Progress',
            value: '${completionPercentage.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.psychology,
            label: language == 'fr' ? 'Mémorisés' : 'Memorized',
            value: '$versesMemorized ${language == 'fr' ? 'versets' : 'verses'}',
          ),
          const SizedBox(height: 24),
          Text(
            language == 'fr' ? 'Compagnon du Coran' : 'Quran Companion',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard({
    required String arabicText,
    required String translation,
    required String surahName,
    required int verseNumber,
    required String language,
  }) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              arabicText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Amiri',
                height: 1.8,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            '$surahName - ${language == 'fr' ? 'Verset' : 'Verse'} $verseNumber',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language == 'fr' ? 'Compagnon du Coran' : 'Quran Companion',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareWidget(Widget widget, String fileName) async {
    try {
      final Uint8List? image = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );
      
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '',
        );
      }
    } catch (e) {
      print('Error sharing widget: $e');
    }
  }

  Future<void> shareToWhatsApp(String text) async {
    final String whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
    await shareText(text);
  }

  Future<void> shareToTwitter(String text) async {
    final String twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}';
    await shareText(text);
  }
}