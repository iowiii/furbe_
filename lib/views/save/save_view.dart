import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/data_controller.dart';
import '../../widgets/mood_analysis.dart';

class SaveView extends StatefulWidget {
  const SaveView({super.key});

  @override
  State<SaveView> createState() => _SaveViewState();
}

class _SaveViewState extends State<SaveView> {
  final DataController ctrl = Get.find<DataController>();
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  int selectedIconIndex = 0; // 0 for logs, 1 for scatter plot

  @override
  void initState() {
    super.initState();
    ctrl.fetchDogSaves().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final dog = ctrl.currentDog.value;
    if (dog == null) {
      return const Scaffold(
        body: Center(child: Text('No dog selected')),
      );
    }

    // All saves for the active dog
    final saves = ctrl.dogSaves[dog.id] ?? [];

    // Group to speed up calendar event lookup and daily render
    final groupedSaves = groupSavesByDay(saves);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar<Map<String, dynamic>>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: (day) {
              final dateKey = DateFormat('yyyy-MM-dd').format(day);
              return groupedSaves[dateKey] ?? const [];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markerDecoration: const BoxDecoration(
                color: Color(0xFFE15C31),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFE15C31),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange.shade300,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 12),

          // Date heading with icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(selectedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedIconIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIconIndex == 0 ? const Color(0xFFE15C31) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.list,
                          color: selectedIconIndex == 0 ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => selectedIconIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIconIndex == 1 ? const Color(0xFFE15C31) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.scatter_plot,
                          color: selectedIconIndex == 1 ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content based on selected icon
          Expanded(
            child: selectedIconIndex == 0
                ? _buildLogsView(groupedSaves)
                : _DailyScatterSection(groupedSaves: groupedSaves, selectedDay: selectedDay),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsView(Map<String, List<Map<String, dynamic>>> groupedSaves) {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
    final dailySaves = List<Map<String, dynamic>>.from(groupedSaves[dateKey] ?? const []);
    
    if (dailySaves.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE15C31),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text('No logs for selected day'),
        ],
      );
    }
    
    return _buildListView(dailySaves);
  }

  Widget _buildListView(List<Map<String, dynamic>> dailySaves) {
    // ✅ Sort ascending by timestamp
    dailySaves.sort((a, b) {
      final dateA = DateTime.tryParse(a['dateSave'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['dateSave'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateA.compareTo(dateB); // ascending (earliest first)
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailySaves.length,
      itemBuilder: (context, index) {
        final save = dailySaves[index];
        DateTime? saveDate;
        try {
          saveDate = DateTime.parse(save['dateSave']!);
        } catch (e) {
          return const SizedBox.shrink();
        }

        final time = DateFormat('h:mm a').format(saveDate);
        final mood = save['mood'] ?? '';
        final info = save['info'] ?? '';
        final moodLower = mood.toLowerCase();

        Color moodColor = Colors.grey;
        if (moodLower == 'happy') {
          moodColor = Colors.green;
        } else if (moodLower == 'sad') {
          moodColor = Colors.blue;
        } else if (moodLower == 'angry') {
          moodColor = Colors.red;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mood,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: info.isNotEmpty ? Text(info) : null,
          ),
        );
      },
    );
  }
}

class _DailyScatterSection extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> groupedSaves;
  final DateTime selectedDay;

  // 👇 tweak this to control horizontal zoom (px per hour)
  static const double pixelsPerHour = 80; // 80px * 24h = 1920px total width

  const _DailyScatterSection({
    required this.groupedSaves,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
    final dailySaves = List<Map<String, dynamic>>.from(groupedSaves[dateKey] ?? const []);

    // Sort by time ascending for painter convenience
    dailySaves.sort((a, b) {
      final aDt = DateTime.tryParse('${a['dateSave']}') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDt = DateTime.tryParse('${b['dateSave']}') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDt.compareTo(bDt);
    });

    if (dailySaves.isEmpty) {
      return const Center(child: Text('No logs for selected day'));
    }

    final stats = computeDailyStats(dailySaves);

    // 👇 total drawing width for a whole day
    final double chartWidth = pixelsPerHour * 24;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ====== SCATTER PLOT (HORIZONTAL SCROLL) ======
          SizedBox(
            height: 260,
            child: ScrollConfiguration(
              behavior: const _NoGlowBehavior(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CustomPaint(
                  painter: ScatterPlotPainter(dailySaves),
                  // 👇 give the painter a wide canvas so we can scroll
                  size: Size(chartWidth, 260),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DailySummary(stats: stats),
        ],
      ),
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _DailySummary extends StatelessWidget {
  final DailyMoodStats stats;
  const _DailySummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    final dom = stats.dominantMood.isEmpty ? '—' : stats.dominantMood;
    final titleDom = dom.isNotEmpty ? (dom[0].toUpperCase() + dom.substring(1)) : '—';

    Widget chip(String mood) {
      final pct = stats.percentages[mood] ?? 0.0;
      final color = kMoodColors[mood] ?? Colors.grey;
      return Chip(
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
        label: Text(
          '${mood[0].toUpperCase()}${mood.substring(1)}: ${pct.toStringAsFixed(0)}%',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Mood Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Dominant mood: $titleDom', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip('happy'),
                chip('sad'),
                chip('angry'),
                chip('scared'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScatterPlotPainter extends CustomPainter {
  final List<Map<String, dynamic>> saves;
  ScatterPlotPainter(this.saves);

  // Fixed Y positions for categorical moods (top to bottom order)
  final List<String> moodRows = const ['happy', 'scared', 'sad', 'angry'];

  @override
  void paint(Canvas canvas, Size size) {
    if (saves.isEmpty) return;

    final paddingLeft = 56.0;
    final paddingRight = 20.0;
    final paddingTop = 12.0;
    final paddingBottom = 40.0;

    final plotWidth = size.width - paddingLeft - paddingRight;
    final plotHeight = size.height - paddingTop - paddingBottom;

    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // X axis line (time axis)
    canvas.drawLine(
      Offset(paddingLeft, size.height - paddingBottom),
      Offset(size.width - paddingRight, size.height - paddingBottom),
      axisPaint,
    );

    // Y categorical grid lines + labels
    final rowCount = moodRows.length;
    for (int i = 0; i < rowCount; i++) {
      final y = paddingTop + (plotHeight / (rowCount - 1)) * i;

      // grid line
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        axisPaint,
      );

      // label
      final label = moodRows[i];
      final tp = TextPainter(
        text: TextSpan(
          text: label[0].toUpperCase() + label.substring(1),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: paddingLeft - 8);
      tp.paint(canvas, Offset(paddingLeft - tp.width - 8, y - tp.height / 2));
    }

    // X ticks (every 2 hours)
    for (int hour = 0; hour <= 24; hour += 2) {
      final x = paddingLeft + plotWidth * (hour / 24.0);

      // tick
      canvas.drawLine(
        Offset(x, size.height - paddingBottom),
        Offset(x, size.height - paddingBottom + 6),
        axisPaint,
      );

      // label
      final hourTime = DateTime(2024, 1, 1, hour);
      final tp = TextPainter(
        text: TextSpan(
          text: DateFormat('ha').format(hourTime).toLowerCase(),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - paddingBottom + 8));
    }

    // Plot points with labels
    final pointPaint = Paint()..style = PaintingStyle.fill;

    for (final save in saves) {
      final dateStr = save['dateSave']?.toString();
      if (dateStr == null || dateStr.isEmpty) continue;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) continue;

      final mood = normalizeMood(save['mood']?.toString());
      if (!moodRows.contains(mood)) continue;

      // X by hour of day
      final hourOfDay = dt.hour + dt.minute / 60.0;
      final x = paddingLeft + plotWidth * (hourOfDay / 24.0);

      // Y by mood row
      final idx = moodRows.indexOf(mood);
      final y = paddingTop + (plotHeight / (rowCount - 1)) * idx;

      // point color
      final color = kMoodColors[mood] ?? Colors.grey;
      pointPaint.color = color;

      // point
      canvas.drawCircle(Offset(x, y), 6, pointPaint);

      // label near point
      final tp = TextPainter(
        text: TextSpan(
          text: mood[0].toUpperCase() + mood.substring(1),
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
