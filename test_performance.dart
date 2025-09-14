import 'dart:io';
import 'lib/widgets/performance_metrics_overlay.dart';
import 'package:get/get.dart';

void main() async {
  // Initialize GetX
  Get.testMode = true;
  
  // Create performance controller
  final perf = PerfMetricsController();
  Get.put(perf);
  
  print('🚀 Testing FurBe Performance Metrics');
  print('Memory Budget: ${PerfMetricsController.kMemoryBudgetMB} MB');
  
  // Simulate camera frames
  for (int i = 0; i < 50; i++) {
    perf.onCameraFrame();
    
    // Simulate processing
    perf.onProcessingStart();
    await Future.delayed(Duration(milliseconds: 50 + (i % 20))); // Variable latency
    perf.onProcessingEnd();
    
    if (i % 10 == 0) {
      print('Frame $i: FPS=${perf.fpsText}, Latency=${perf.latencyText}, Throughput=${perf.throughputText}, Memory=${perf.memoryText}');
      
      // Check memory usage
      final currentMemory = ProcessInfo.currentRss / (1024 * 1024);
      if (currentMemory > PerfMetricsController.kMemoryBudgetMB) {
        print('⚠️  Memory usage (${currentMemory.toStringAsFixed(0)} MB) exceeds budget!');
      } else {
        print('✅ Memory usage within budget');
      }
    }
    
    await Future.delayed(Duration(milliseconds: 33)); // ~30 FPS
  }
  
  print('✅ Performance test completed');
  perf.onClose();
}