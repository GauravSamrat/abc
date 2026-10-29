import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';

class TtsController extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final Box _box = Hive.box('abcitta_box');

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  double _speechRate = 1.0;
  double _pitch = 1.0;
  double _volume = 1.0;
  String? _voiceName;
  bool _autoPlay = false;

  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String? get voiceName => _voiceName;
  bool get autoPlay => _autoPlay;

  int _startOffset = 0;
  int _endOffset = 0;
  int get startOffset => _startOffset;
  int get endOffset => _endOffset;

  List<Map<String, String>> _availableVoices = [];
  List<Map<String, String>> get availableVoices => _availableVoices;

  bool _voicesLoaded = false;
  bool get voicesLoaded => _voicesLoaded;

  TtsController() {
    _loadSettings();
    _initTts();
  }

  void _loadSettings() {
    // 👈 FIX: Default speed 0.5x kar diya hai (slow & clear)
    _speechRate = (_box.get('tts_rate', defaultValue: 0.5) as num).toDouble();
    _pitch = (_box.get('tts_pitch', defaultValue: 1.0) as num).toDouble();
    _volume = (_box.get('tts_volume', defaultValue: 1.0) as num).toDouble();
    _voiceName = _box.get('tts_voice_name', defaultValue: null) as String?;
    _autoPlay = _box.get('auto_play_tts', defaultValue: false) as bool;
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    _flutterTts.setProgressHandler((text, start, end, word) {
      _startOffset = start;
      _endOffset = end;
      notifyListeners();
    });

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      _startOffset = 0;
      _endOffset = 0;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      _startOffset = 0;
      _endOffset = 0;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    });

    await _loadVoices();
    if (_voiceName != null) {
      try {
        final voice =
            _availableVoices.firstWhere((v) => v['name'] == _voiceName);
        await _flutterTts.setVoice({
          "name": voice['name']!,
          "locale": voice['locale']!,
        });
      } catch (_) {}
    }
  }

  Future<void> _loadVoices() async {
    try {
      final data = await _flutterTts.getVoices;
      if (data is List) {
        _availableVoices = data
            .map((v) => <String, String>{
                  'name': v['name']?.toString() ?? '',
                  'locale': v['locale']?.toString() ?? '',
                })
            .where((v) => v['name']!.isNotEmpty)
            .toList();
        _voicesLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Voice load error: $e");
    }
  }

  Future<void> reloadVoices() => _loadVoices();

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (_isSpeaking || _isPaused) {
      await stop();
    }
    _startOffset = 0;
    _endOffset = 0;
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
    _startOffset = 0;
    _endOffset = 0;
    notifyListeners();
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
      _isPaused = true;
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _box.put('tts_rate', rate);
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setPitch(double p) async {
    _pitch = p;
    await _box.put('tts_pitch', p);
    await _flutterTts.setPitch(p);
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    await _box.put('tts_volume', v);
    await _flutterTts.setVolume(v);
    notifyListeners();
  }

  Future<void> setVoice(String name, String locale) async {
    _voiceName = name;
    await _box.put('tts_voice_name', name);
    await _flutterTts.setVoice({"name": name, "locale": locale});
    notifyListeners();
  }

  Future<void> setAutoPlay(bool val) async {
    _autoPlay = val;
    await _box.put('auto_play_tts', val);
    notifyListeners();
  }
}
