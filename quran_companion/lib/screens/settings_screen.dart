import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Display Settings
          _buildSectionHeader(context, 'Display'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeName(settingsProvider.themeMode, l10n)),
            onTap: () => _showThemeDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.arabicFontSize),
            subtitle: Text('${settingsProvider.arabicFontSize.round()}'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settingsProvider.arabicFontSize,
                min: 18,
                max: 40,
                divisions: 11,
                onChanged: (value) {
                  settingsProvider.setArabicFontSize(value);
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(l10n.translationFontSize),
            subtitle: Text('${settingsProvider.translationFontSize.round()}'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settingsProvider.translationFontSize,
                min: 12,
                max: 24,
                divisions: 12,
                onChanged: (value) {
                  settingsProvider.setTranslationFontSize(value);
                },
              ),
            ),
          ),
          
          const Divider(),
          
          // Language Settings
          _buildSectionHeader(context, l10n.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(settingsProvider.locale.languageCode == 'fr' ? 'Français' : 'English'),
            onTap: () => _showLanguageDialog(context),
          ),
          
          const Divider(),
          
          // Translation Settings
          _buildSectionHeader(context, l10n.translation),
          SwitchListTile(
            secondary: const Icon(Icons.translate),
            title: Text(l10n.showTranslation),
            value: settingsProvider.showTranslation,
            onChanged: (value) {
              settingsProvider.setShowTranslation(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: Text(l10n.translation),
            subtitle: Text(_getTranslationName(settingsProvider.selectedTranslation)),
            enabled: settingsProvider.showTranslation,
            onTap: settingsProvider.showTranslation
                ? () => _showTranslationDialog(context)
                : null,
          ),
          
          const Divider(),
          
          // Audio Settings
          _buildSectionHeader(context, l10n.audio),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: Text(l10n.reciter),
            subtitle: Text(_getReciterName(settingsProvider.selectedReciter)),
            onTap: () => _showReciterDialog(context),
          ),
          
          const Divider(),
          
          // Notifications
          _buildSectionHeader(context, l10n.notifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(l10n.dailyReminder),
            subtitle: Text('${settingsProvider.reminderTime.hour}:${settingsProvider.reminderTime.minute.toString().padLeft(2, '0')}'),
            value: settingsProvider.dailyReminder,
            onChanged: (value) {
              settingsProvider.setDailyReminder(value);
              if (value) {
                _showTimePickerDialog(context);
              }
            },
          ),
          
          const Divider(),
          
          // API Settings
          _buildSectionHeader(context, 'API'),
          ListTile(
            leading: const Icon(Icons.key),
            title: Text(l10n.apiKey),
            subtitle: const Text('Geoapify API Key'),
            onTap: () => _showApiKeyDialog(context),
          ),
          
          const Divider(),
          
          // About
          _buildSectionHeader(context, l10n.aboutApp),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.developer),
            subtitle: const Text('Quran Companion Team'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }
  
  String _getTranslationName(String translation) {
    final translations = {
      'fr.hamidullah': 'Français - Hamidullah',
      'en.sahih': 'English - Sahih International',
      'en.yusufali': 'English - Yusuf Ali',
      'ur.maududi': 'اردو - مودودی',
    };
    return translations[translation] ?? translation;
  }
  
  String _getReciterName(String reciter) {
    final reciters = {
      'ar.alafasy': 'Mishary Rashid Alafasy',
      'ar.abdulbasitmurattal': 'Abdul Basit Abdul Samad',
      'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
      'ar.husary': 'Mahmoud Khalil Al-Hussary',
    };
    return reciters[reciter] ?? reciter;
  }
  
  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) => RadioListTile<ThemeMode>(
            title: Text(_getThemeName(mode, l10n)),
            value: mode,
            groupValue: settingsProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setThemeMode(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: settingsProvider.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: settingsProvider.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTranslationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    
    final translations = {
      'fr.hamidullah': 'Français - Hamidullah',
      'en.sahih': 'English - Sahih International',
      'en.yusufali': 'English - Yusuf Ali',
      'ur.maududi': 'اردو - مودودی',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: translations.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: settingsProvider.selectedTranslation,
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setSelectedTranslation(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _showReciterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    
    final reciters = {
      'ar.alafasy': 'Mishary Rashid Alafasy',
      'ar.abdulbasitmurattal': 'Abdul Basit Abdul Samad',
      'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
      'ar.husary': 'Mahmoud Khalil Al-Hussary',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reciter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reciters.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: settingsProvider.selectedReciter,
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setSelectedReciter(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _showTimePickerDialog(BuildContext context) async {
    final settingsProvider = context.read<SettingsProvider>();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settingsProvider.reminderTime,
    );
    
    if (picked != null) {
      settingsProvider.setReminderTime(picked);
    }
  }
  
  void _showApiKeyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final localStorage = LocalStorageService();
    
    // Load existing key if any
    localStorage.getApiKey().then((key) {
      if (key != null) {
        controller.text = key;
      }
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterApiKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get your free API key from:\nhttps://myprojects.geoapify.com/',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter API key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await localStorage.setApiKey(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API key saved')),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}