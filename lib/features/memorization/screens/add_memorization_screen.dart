import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/quran_service.dart';
import '../../../core/services/memorization_service.dart';
import '../../../core/models/memorization_model.dart';

class AddMemorizationScreen extends ConsumerStatefulWidget {
  const AddMemorizationScreen({super.key});

  @override
  ConsumerState<AddMemorizationScreen> createState() =>
      _AddMemorizationScreenState();
}

class _AddMemorizationScreenState
    extends ConsumerState<AddMemorizationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _surahs = [];
  Map<String, dynamic>? _selectedSurah;
  int _startVerse = 1;
  int _endVerse = 1;
  bool _isLoading = true;
  late QuranService _quranService;
  late MemorizationService _memorizationService;

  @override
  void initState() {
    super.initState();
    _quranService = ref.read(quranServiceProvider);
    _memorizationService = ref.read(memorizationServiceProvider);
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final surahs = await _quranService.getAllSurahs();
    setState(() {
      _surahs = surahs;
      _isLoading = false;
    });
  }

  Future<void> _addVerses() async {
    if (_formKey.currentState!.validate() && _selectedSurah != null) {
      final locale = ref.read(languageProvider);
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        for (int verse = _startVerse; verse <= _endVerse; verse++) {
          final verseData = await _quranService.getVerse(
            _selectedSurah!['number'],
            verse,
          );
          
          final translation = await _quranService.getTranslation(
            _selectedSurah!['number'],
            verse,
            locale,
          );

          final memorizeVerse = MemorizationVerse(
            id: '${_selectedSurah!['number']}_$verse',
            surahNumber: _selectedSurah!['number'],
            surahName: _selectedSurah!['name'],
            verseNumber: verse,
            arabicText: verseData['text'],
            translation: translation,
          );

          await _memorizationService.addVerseToMemorization(memorizeVerse);
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pop(true); // Return to previous screen
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                locale == 'fr'
                    ? 'Versets ajoutés avec succès'
                    : 'Verses added successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                locale == 'fr'
                    ? 'Erreur lors de l\'ajout des versets'
                    : 'Error adding verses',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            locale == 'fr' ? 'Ajouter à la mémorisation' : 'Add to Memorization',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'fr' ? 'Ajouter à la mémorisation' : 'Add to Memorization',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale == 'fr' ? 'Sélectionner la sourate' : 'Select Surah',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedSurah,
                        decoration: InputDecoration(
                          labelText: locale == 'fr' ? 'Sourate' : 'Surah',
                          border: const OutlineInputBorder(),
                        ),
                        items: _surahs.map((surah) {
                          return DropdownMenuItem(
                            value: surah,
                            child: Text(
                              '${surah['number']}. ${surah['name']} (${surah['numberOfAyahs']} ${locale == 'fr' ? 'versets' : 'verses'})',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSurah = value;
                            _startVerse = 1;
                            _endVerse = value?['numberOfAyahs'] ?? 1;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return locale == 'fr'
                                ? 'Veuillez sélectionner une sourate'
                                : 'Please select a surah';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale == 'fr' ? 'Sélectionner les versets' : 'Select Verses',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _startVerse.toString(),
                              decoration: InputDecoration(
                                labelText: locale == 'fr' ? 'Du verset' : 'From verse',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final verse = int.tryParse(value);
                                if (verse != null) {
                                  setState(() {
                                    _startVerse = verse;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale == 'fr' ? 'Requis' : 'Required';
                                }
                                final verse = int.tryParse(value);
                                if (verse == null || verse < 1) {
                                  return locale == 'fr' ? 'Invalide' : 'Invalid';
                                }
                                if (_selectedSurah != null &&
                                    verse > _selectedSurah!['numberOfAyahs']) {
                                  return locale == 'fr'
                                      ? 'Verset trop élevé'
                                      : 'Verse too high';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _endVerse.toString(),
                              decoration: InputDecoration(
                                labelText: locale == 'fr' ? 'Au verset' : 'To verse',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final verse = int.tryParse(value);
                                if (verse != null) {
                                  setState(() {
                                    _endVerse = verse;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale == 'fr' ? 'Requis' : 'Required';
                                }
                                final verse = int.tryParse(value);
                                if (verse == null || verse < 1) {
                                  return locale == 'fr' ? 'Invalide' : 'Invalid';
                                }
                                if (verse < _startVerse) {
                                  return locale == 'fr'
                                      ? 'Doit être ≥ début'
                                      : 'Must be ≥ start';
                                }
                                if (_selectedSurah != null &&
                                    verse > _selectedSurah!['numberOfAyahs']) {
                                  return locale == 'fr'
                                      ? 'Verset trop élevé'
                                      : 'Verse too high';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedSurah != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          locale == 'fr'
                              ? 'Total: ${_endVerse - _startVerse + 1} versets'
                              : 'Total: ${_endVerse - _startVerse + 1} verses',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            locale == 'fr' ? 'Conseils' : 'Tips',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        locale == 'fr'
                            ? '• Commencez avec quelques versets courts\n'
                              '• Révisez régulièrement pour améliorer la rétention\n'
                              '• Utilisez la répétition espacée pour de meilleurs résultats\n'
                              '• Écoutez l\'audio pour améliorer la prononciation'
                            : '• Start with a few short verses\n'
                              '• Review regularly to improve retention\n'
                              '• Use spaced repetition for better results\n'
                              '• Listen to audio to improve pronunciation',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addVerses,
                  icon: const Icon(Icons.add),
                  label: Text(
                    locale == 'fr'
                        ? 'Ajouter à la mémorisation'
                        : 'Add to Memorization',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}