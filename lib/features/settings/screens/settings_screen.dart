import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final tajweedEnabled = ref.watch(tajweedEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Language Section
          _buildSection(
            title: l10n.language,
            children: [
              RadioListTile<String>(
                title: Text(l10n.french),
                value: 'fr',
                groupValue: locale,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.english),
                value: 'en',
                groupValue: locale,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                },
              ),
            ],
          ),
          const Divider(),
          
          // Theme Section
          _buildSection(
            title: l10n.theme,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.light),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value!);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.dark),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value!);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.system),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value!);
                },
              ),
            ],
          ),
          const Divider(),
          
          // Reading Settings
          _buildSection(
            title: locale == 'fr' ? 'Lecture' : 'Reading',
            children: [
              SwitchListTile(
                title: Text(l10n.tajweedRules),
                subtitle: Text(
                  tajweedEnabled ? l10n.enableTajweed : l10n.disableTajweed,
                ),
                value: tajweedEnabled,
                onChanged: (value) {
                  ref.read(tajweedEnabledProvider.notifier).toggle();
                },
              ),
            ],
          ),
          const Divider(),
          
          // About Section
          _buildSection(
            title: l10n.about,
            children: [
              ListTile(
                title: Text(l10n.version),
                trailing: const Text('2.0.0'),
              ),
              ListTile(
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open privacy policy
                },
              ),
              ListTile(
                title: Text(l10n.termsOfService),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open terms of service
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}