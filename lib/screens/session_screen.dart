import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/pose_session.dart';
import '../utils/json_loader.dart';

class SessionScreen extends StatefulWidget {
  final int loopCount;

  const SessionScreen({super.key, required this.loopCount});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  PoseSession? _session;
  int _currentSegmentIndex = 0;
  int _currentScriptIndex = 0;
  String? _currentImage;
  AudioPlayer _mainAudioPlayer = AudioPlayer();
  AudioPlayer _bgAudioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _bgMusicOn = false;
  double _bgMusicVolume = 0.1;
  int _remainingLoops = 0;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await JsonLoader.loadSessionFromJson('assets/poses.json');
    setState(() {
      _session = session;
      _remainingLoops = widget.loopCount;
      _currentSegmentIndex = 0;
    });
    _playSegment(_session!.sequence[_currentSegmentIndex]);
  }

  Future<void> _playSegment(SessionSegment segment) async {
    await _mainAudioPlayer.stop();
    _mainAudioPlayer = AudioPlayer();

    if (_bgMusicOn) {
      _bgAudioPlayer.play(AssetSource('audio/bg_music.mp3'), volume: _bgMusicVolume);
    }

    final audioPath = 'audio/${_session!.assets.audio[segment.audioRef]}';

    _positionSubscription?.cancel();
    _positionSubscription = _mainAudioPlayer.onPositionChanged.listen((Duration position) {
      for (int i = 0; i < segment.script.length; i++) {
        final script = segment.script[i];
        if (position.inSeconds >= script.startSec && position.inSeconds < script.endSec) {
          final imagePath = 'assets/images/${_session!.assets.images[script.imageRef]}';
          if (_currentImage != imagePath) {
            setState(() {
              _currentImage = imagePath;
              _currentScriptIndex = i;
            });
          }
          break;
        }
      }
    });

    _mainAudioPlayer.onPlayerComplete.listen((_) {
      _moveToNextSegment();
    });

    await _mainAudioPlayer.play(AssetSource(audioPath));
    setState(() => _isPlaying = true);
  }

  void _moveToNextSegment() {
    final current = _session!.sequence[_currentSegmentIndex];

    if (current.type == 'loop' && _remainingLoops > 1) {
      setState(() => _remainingLoops--);
      _playSegment(current);
      return;
    }

    final nextIndex = _currentSegmentIndex + 1;
    if (nextIndex < _session!.sequence.length) {
      setState(() {
        _currentSegmentIndex = nextIndex;
        if (_session!.sequence[nextIndex].type == 'loop') {
          _remainingLoops = widget.loopCount;
        }
      });
      _playSegment(_session!.sequence[nextIndex]);
    } else {
      setState(() {
        _isPlaying = false;
        _currentImage = null;
      });
      _showSessionEndDialog();
    }
  }

  void _togglePause() {
    if (_isPaused) {
      _mainAudioPlayer.resume();
    } else {
      _mainAudioPlayer.pause();
    }
    setState(() => _isPaused = !_isPaused);
  }

  void _showVolumeSlider() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Background Music Volume', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _bgMusicVolume,
              onChanged: (value) {
                setState(() {
                  _bgMusicVolume = value;
                  _bgAudioPlayer.setVolume(_bgMusicVolume);
                });
              },
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(_bgMusicVolume * 100).round()}%',
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Session Completed"),
        content: const Text("Do you want to repeat the session?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadSession(); // restart session
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // go back to home
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainAudioPlayer.dispose();
    _bgAudioPlayer.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: const Text("Yoga Session"),
        actions: [
          IconButton(
            icon: const Icon(Icons.music_note),
            onPressed: _showVolumeSlider,
          ),
        ],
      ),
      body: _session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_currentImage != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    key: ValueKey(_currentImage),
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _currentImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (_isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: IconButton(
                icon: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 48,
                  color: themeColor,
                ),
                onPressed: _togglePause,
              ),
            ),
        ],
      ),
    );
  }
}
