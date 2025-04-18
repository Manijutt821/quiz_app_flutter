import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final player = AudioPlayer();
  bool _isMuted = false;
  bool _isBgMusicEnabled = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool('isMuted') ?? false;
    _isBgMusicEnabled = prefs.getBool('isBgMusicEnabled') ?? true;
  }

  Future<void> playButtonClick() async {
    if (_isMuted) return;
    await player.setAsset('assets/audio/click.mp3');
    await player.play();
  }

  Future<void> playCorrectAnswer() async {
    if (_isMuted) return;
    await player.setAsset('assets/audio/correct.mp3');
    await player.play();
  }

  Future<void> playWrongAnswer() async {
    if (_isMuted) return;
    await player.setAsset('assets/audio/wrong.mp3');
    await player.play();
  }

  Future<void> playComplete() async {
    if (_isMuted) return;
    await player.setAsset('assets/audio/complete.mp3');
    await player.play();
  }

  Future<void> startBackgroundMusic() async {
    if (_isMuted || !_isBgMusicEnabled) return;
    await _backgroundMusicPlayer.setAsset('assets/audio/background.mp3');
    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundMusicPlayer.resume();
  }

  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMuted', _isMuted);

    if (_isMuted) {
      await pauseBackgroundMusic();
    } else if (_isBgMusicEnabled) {
      await startBackgroundMusic();
    }
  }

  Future<void> toggleBackgroundMusic() async {
    _isBgMusicEnabled = !_isBgMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBgMusicEnabled', _isBgMusicEnabled);

    if (_isBgMusicEnabled && !_isMuted) {
      await startBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  bool get isMuted => _isMuted;
  bool get isBackgroundMusicEnabled => _isBgMusicEnabled;

  Future<void> dispose() async {
    await player.dispose();
    await _backgroundMusicPlayer.dispose();
  }
} 