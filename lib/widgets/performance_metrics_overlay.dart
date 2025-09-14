import 'dart:async';
import 'dart:collection';
import 'dart:io' show ProcessInfo;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerfMetricsController extends GetxController {
  static const Duration _fpsWindow = Duration(seconds: 2);
  static const double kMemoryBudgetMB = 700.0; // Reduced to 700MB
  static const double _memoryResumeMB = kMemoryBudgetMB * 0.90;
  static const Duration _tick = Duration(milliseconds: 500);
  static const int _minSkipModulo = 1;
  static const int _maxSkipModulo = 8; // Increased for better memory control

  final RxDouble cameraFps = 0.0.obs;
  final RxDouble memoryMB = 0.0.obs;
  final RxDouble latencyMs = 0.0.obs;
  final RxDouble throughputFps = 0.0.obs;

  VoidCallback? onMemoryPressure;
  VoidCallback? onMemoryPressureEnd;

  final Queue<DateTime> _frameTimes = DoubleLinkedQueue<DateTime>();
  final Queue<DateTime> _processingTimes = DoubleLinkedQueue<DateTime>();
  final Queue<double> _latencyHistory = DoubleLinkedQueue<double>();
  
  Timer? _ticker;
  bool _underPressure = false;
  int _frameSeq = 0;
  int _skipModulo = _minSkipModulo;
  DateTime? _lastProcessStart;
  int _processedFrames = 0;

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(_tick, (_) {
      _updateMetrics();
      _checkMemory();
      _forceGarbageCollection();
    });
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  void onCameraFrame() {
    _frameSeq++;
    if ((_frameSeq % _skipModulo) != 0) return;
    final now = DateTime.now();
    _frameTimes.addLast(now);
    final cutoff = now.subtract(_fpsWindow);
    while (_frameTimes.isNotEmpty && _frameTimes.first.isBefore(cutoff)) {
      _frameTimes.removeFirst();
    }
  }

  void onProcessingStart() {
    _lastProcessStart = DateTime.now();
  }

  void onProcessingEnd() {
    if (_lastProcessStart != null) {
      final now = DateTime.now();
      final latency = now.difference(_lastProcessStart!).inMicroseconds / 1000.0;
      _latencyHistory.addLast(latency);
      _processingTimes.addLast(now);
      _processedFrames++;
      
      final cutoff = now.subtract(_fpsWindow);
      while (_latencyHistory.length > 20) _latencyHistory.removeFirst();
      while (_processingTimes.isNotEmpty && _processingTimes.first.isBefore(cutoff)) {
        _processingTimes.removeFirst();
      }
    }
  }

  void _updateMetrics() {
    _updateFps();
    _updateLatency();
    _updateThroughput();
  }

  void _updateFps() {
    if (_frameTimes.length < 2) {
      cameraFps.value = 0.0;
      return;
    }
    final first = _frameTimes.first;
    final last = _frameTimes.last;
    final totalSeconds = last.difference(first).inMicroseconds / 1e6;
    cameraFps.value = totalSeconds > 0 ? _frameTimes.length / totalSeconds : 0.0;
  }

  void _updateLatency() {
    if (_latencyHistory.isEmpty) {
      latencyMs.value = 0.0;
      return;
    }
    final sum = _latencyHistory.reduce((a, b) => a + b);
    latencyMs.value = sum / _latencyHistory.length;
  }

  void _updateThroughput() {
    if (_processingTimes.length < 2) {
      throughputFps.value = 0.0;
      return;
    }
    final first = _processingTimes.first;
    final last = _processingTimes.last;
    final totalSeconds = last.difference(first).inMicroseconds / 1e6;
    throughputFps.value = totalSeconds > 0 ? _processingTimes.length / totalSeconds : 0.0;
  }

  void _checkMemory() {
    final rssMB = ProcessInfo.currentRss / (1024 * 1024);
    memoryMB.value = rssMB;
    
    if (!_underPressure && rssMB > kMemoryBudgetMB) {
      _underPressure = true;
      _increaseDrop();
      _aggressiveCleanup();
      onMemoryPressure?.call();
    } else if (_underPressure && rssMB < _memoryResumeMB) {
      _underPressure = false;
      _decreaseDrop();
      onMemoryPressureEnd?.call();
    } else if (_underPressure && rssMB > kMemoryBudgetMB * 1.05) {
      _increaseDrop();
      _aggressiveCleanup();
    }
  }

  void _increaseDrop() {
    if (_skipModulo < _maxSkipModulo) _skipModulo++;
  }

  void _decreaseDrop() {
    if (_skipModulo > _minSkipModulo) _skipModulo--;
  }

  void _forceGarbageCollection() {
    if (_frameSeq % 100 == 0) {
      _cleanupQueues();
    }
  }

  void _aggressiveCleanup() {
    _cleanupQueues();
    _skipModulo = (_skipModulo * 1.5).clamp(_minSkipModulo, _maxSkipModulo).toInt();
  }

  void _cleanupQueues() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(seconds: 5));
    
    while (_frameTimes.isNotEmpty && _frameTimes.first.isBefore(cutoff)) {
      _frameTimes.removeFirst();
    }
    while (_processingTimes.isNotEmpty && _processingTimes.first.isBefore(cutoff)) {
      _processingTimes.removeFirst();
    }
    if (_latencyHistory.length > 10) {
      while (_latencyHistory.length > 10) _latencyHistory.removeFirst();
    }
  }

  String get fpsText => "${cameraFps.value.toStringAsFixed(1)}";
  String get memoryText => "${memoryMB.value.toStringAsFixed(0)}";
  String get latencyText => "${latencyMs.value.toStringAsFixed(0)}ms";
  String get throughputText => "${throughputFps.value.toStringAsFixed(1)} TPS";
  
  bool get isMemoryPressure => _underPressure;
}

class PerformanceMetricsOverlay extends StatelessWidget {
  final EdgeInsets padding;
  final Color bgColor;
  final double borderRadius;
  final double elevation;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  PerformanceMetricsOverlay({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.bgColor = const Color(0xAA000000),
    this.borderRadius = 8,
    this.elevation = 0,
    this.labelStyle,
    this.valueStyle,
  });

  final PerfMetricsController perf = Get.find<PerfMetricsController>();

  @override
  Widget build(BuildContext context) {
    final ls = labelStyle ?? const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500);
    final vs = valueStyle ?? const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: perf.isMemoryPressure ? Colors.red.withOpacity(0.6) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _metric("FPS", perf.fpsText, ls, vs),
                  const SizedBox(width: 8),
                  _metric("Latency", perf.latencyText, ls, vs),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _metric("Throughput", perf.throughputText, ls, vs),
                  const SizedBox(width: 8),
                  _metric(
                    "Memory", 
                    perf.memoryText, 
                    ls, 
                    vs.copyWith(
                      color: perf.isMemoryPressure ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _metric(String label, String value, TextStyle ls, TextStyle vs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: ls),
        Text(value, style: vs),
      ],
    );
  }
}
