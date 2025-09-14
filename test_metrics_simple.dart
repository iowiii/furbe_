import 'dart:io';

void main() {
  print('🚀 Testing FurBe Memory Management');
  
  // Test memory budget
  const double memoryBudgetMB = 700.0;
  print('Memory Budget: ${memoryBudgetMB} MB');
  
  // Check current memory usage
  final currentMemoryMB = ProcessInfo.currentRss / (1024 * 1024);
  print('Current Memory Usage: ${currentMemoryMB.toStringAsFixed(2)} MB');
  
  if (currentMemoryMB > memoryBudgetMB) {
    print('⚠️  Memory usage exceeds budget!');
  } else {
    print('✅ Memory usage within budget');
  }
  
  // Simulate performance metrics calculations
  print('\n📊 Performance Metrics Simulation:');
  
  // FPS calculation simulation
  final List<DateTime> frameTimes = [];
  final now = DateTime.now();
  for (int i = 0; i < 10; i++) {
    frameTimes.add(now.subtract(Duration(milliseconds: i * 33))); // ~30 FPS
  }
  
  if (frameTimes.length >= 2) {
    final first = frameTimes.last;
    final last = frameTimes.first;
    final totalSeconds = last.difference(first).inMicroseconds / 1e6;
    final fps = totalSeconds > 0 ? frameTimes.length / totalSeconds : 0.0;
    print('Calculated FPS: ${fps.toStringAsFixed(1)}');
  }
  
  // Latency calculation simulation
  final List<double> latencies = [45.2, 52.1, 48.7, 51.3, 49.8];
  final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
  print('Average Latency: ${avgLatency.toStringAsFixed(1)}ms');
  
  // Throughput calculation simulation
  final processingCount = 8;
  final timeWindow = 2.0; // seconds
  final throughput = processingCount / timeWindow;
  print('Throughput: ${throughput.toStringAsFixed(1)} TPS');
  
  print('\n✅ Performance metrics test completed successfully!');
}