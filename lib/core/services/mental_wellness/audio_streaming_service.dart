import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioStreamingService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  // Stream controllers for state updates
  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  // Public streams
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  // Current state
  PlayerState? _currentState;
  Duration? _currentPosition;
  Duration? _currentDuration;
  String? _currentUrl;

  PlayerState? get currentState => _currentState;
  Duration? get currentPosition => _currentPosition;
  Duration? get currentDuration => _currentDuration;
  bool get isPlaying => _currentState == PlayerState.playing;
  bool get isPaused => _currentState == PlayerState.paused;
  bool get isStopped => _currentState == PlayerState.stopped;
  bool get isComplete => _currentState == PlayerState.completed;

  AudioStreamingService() {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      _currentState = state;
      _playerStateController.add(state);
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _positionController.add(position);
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _currentDuration = duration;
      _durationController.add(duration);
    });
  }

  // Play audio from URL
  Future<bool> play(String url, {double volume = 1.0}) async {
    try {
      _currentUrl = url;
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(UrlSource(url));
      return true;
    } catch (e) {
      debugPrint('Error playing audio: $e');
      return false;
    }
  }

  // Play audio from asset
  Future<bool> playAsset(String assetPath, {double volume = 1.0}) async {
    try {
      _currentUrl = assetPath;
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource(assetPath));
      return true;
    } catch (e) {
      debugPrint('Error playing asset: $e');
      return false;
    }
  }

  // Pause audio
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume audio
  Future<void> resume() async {
    if (_currentState == PlayerState.paused) {
      await _audioPlayer.resume();
    }
  }

  // Stop audio
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPosition = Duration.zero;
    _positionController.add(Duration.zero);
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else if (isPaused || isStopped) {
      await resume();
    }
  }

  // Get current position as formatted string
  String getFormattedPosition() {
    if (_currentPosition == null) return '0:00';
    final minutes = _currentPosition!.inMinutes;
    final seconds = _currentPosition!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Get duration as formatted string
  String getFormattedDuration() {
    if (_currentDuration == null) return '0:00';
    final minutes = _currentDuration!.inMinutes;
    final seconds = _currentDuration!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Get progress as percentage (0.0 - 1.0)
  double getProgress() {
    if (_currentPosition == null || _currentDuration == null || _currentDuration!.inMilliseconds == 0) {
      return 0.0;
    }
    return _currentPosition!.inMilliseconds / _currentDuration!.inMilliseconds;
  }

  // Check if audio is complete (within 1 second of end)
  bool isAudioComplete() {
    if (_currentPosition == null || _currentDuration == null) return false;
    final remaining = _currentDuration! - _currentPosition!;
    return remaining.inSeconds <= 1 && _currentPosition!.inSeconds > 0;
  }

  // Dispose resources
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
    _audioPlayer.dispose();
  }
}