import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/export_service.dart';
import '../widgets/quiz_app_bar.dart';
import '../widgets/quiz_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final audioService = AudioService.instance;
    setState(() {
      _isSoundEnabled = !audioService.isMuted;
      _isMusicEnabled = audioService.isBackgroundMusicEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QuizAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Audio Settings',
            [
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable or disable sound effects'),
                value: _isSoundEnabled,
                onChanged: (value) {
                  setState(() {
                    _isSoundEnabled = value;
                    AudioService.instance.toggleMute();
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Background Music'),
                subtitle: const Text('Enable or disable background music'),
                value: _isMusicEnabled,
                onChanged: (value) {
                  setState(() {
                    _isMusicEnabled = value;
                    AudioService.instance.toggleBackgroundMusic();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Data Management',
            [
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Export Data'),
                subtitle: const Text('Export your quiz history and saved quizzes'),
                onTap: _exportData,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      // TODO: Get actual quiz and score data from your data source
      await ExportService.instance.exportData(
        scores: [],
        quizzes: [],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 