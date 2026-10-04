import 'dart:async';

import 'package:flutter/material.dart';
import '../../platform/eye_control_platform.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key, EyeControlPlatform? platform}) : _platform = platform;
  final EyeControlPlatform? _platform;

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  late final EyeControlPlatform _platform = widget._platform ?? EyeControlPlatform();

  static const targets = <Offset>[
    Offset(0.10, 0.10), Offset(0.50, 0.10), Offset(0.90, 0.10),
    Offset(0.10, 0.50), Offset(0.50, 0.50), Offset(0.90, 0.50),
    Offset(0.10, 0.90), Offset(0.50, 0.90), Offset(0.90, 0.90),
  ];

  int _index = -1;
  bool _running = false;
  bool _saving = false;
  String? _error;
  Timer? _timer;
  final List<Map<String, double>> _samples = [];
  final List<Map<String, double>> _current = [];
  bool _reading = false;

  Future<void> _start() async {
    setState(() {
      _error = null;
      _samples.clear();
      _index = 0;
      _running = true;
    });

    try {
      await _platform.startCamera();
      await _captureTarget();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _index = -1;
        _error = error.toString();
      });
    }
  }

  Future<void> _captureTarget() async {
    if (!_running || _index < 0 || _index >= targets.length) return;
    _current.clear();
    var ticks = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (_reading) return;
      _reading = true;
      ticks++;
      final gaze = await _platform.latestGaze();
      if (gaze != null && gaze['confidence'] is num && gaze['blinking'] != true) {
        final confidence = (gaze['confidence'] as num).toDouble();
        if (confidence >= 0.35 &&
            gaze['leftIrisX'] is num &&
            gaze['leftIrisY'] is num &&
            gaze['rightIrisX'] is num &&
            gaze['rightIrisY'] is num) {
          _current.add({
            'leftIrisX': (gaze['leftIrisX'] as num).toDouble(),
            'leftIrisY': (gaze['leftIrisY'] as num).toDouble(),
            'rightIrisX': (gaze['rightIrisX'] as num).toDouble(),
            'rightIrisY': (gaze['rightIrisY'] as num).toDouble(),
          });
        }
      }
      _reading = false;

      if (ticks >= 20) {
        timer.cancel();
        final point = targets[_index];
        if (_current.length >= 8) {
          double average(String key) =>
              _current.map((item) => item[key]!).reduce((a, b) => a + b) / _current.length;
          _samples.add({
            'leftIrisX': average('leftIrisX'),
            'leftIrisY': average('leftIrisY'),
            'rightIrisX': average('rightIrisX'),
            'rightIrisY': average('rightIrisY'),
            'targetX': point.dx,
            'targetY': point.dy,
          });
        } else {
          _error = 'لم يتم التقاط نظر ثابت. حاول مرة أخرى.';
        }

        if (!mounted) return;
        if (_samples.length == targets.length) {
          setState(() => _saving = true);
          try {
            await _platform.fitCalibration(_samples);
            if (mounted) {
              setState(() {
                _saving = false;
                _running = false;
                _index = -1;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ المعايرة بنجاح.')),
              );
            }
          } catch (error) {
            if (mounted) {
              setState(() {
                _saving = false;
                _running = false;
                _error = error.toString();
              });
            }
          }
          return;
        }

        if (mounted) {
          setState(() => _index++);
          await _captureTarget();
        }
      }
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _index >= 0 && _index < targets.length;
    return Scaffold(
      appBar: AppBar(title: const Text('معايرة التحكم بالعين')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _running ? 'انظر إلى النقطة دون تحريك الرأس' : 'عاير النظام للحصول على دقة أعلى',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text('سيتم التقاط 9 نقاط ومعالجة البيانات محلياً.', textAlign: TextAlign.center),
                  const Spacer(),
                  if (!_running)
                    FilledButton.icon(
                      onPressed: _saving ? null : _start,
                      icon: const Icon(Icons.tune),
                      label: const Text('بدء المعايرة'),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),
          if (active)
            Align(
              alignment: Alignment(targets[_index].dx * 2 - 1, targets[_index].dy * 2 - 1),
              child: const _CalibrationDot(),
            ),
          if (_saving)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _CalibrationDot extends StatelessWidget {
  const _CalibrationDot();

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 4,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
            ),
          ],
        ),
        child: const Center(
          child: CircleAvatar(radius: 6, backgroundColor: Colors.white),
        ),
      );
}
