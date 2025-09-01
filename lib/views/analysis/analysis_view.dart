import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  final DataController ctrl = Get.find<DataController>();
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool isTimelineView = false;

  @override
  void initState() {
    super.initState();
    ctrl.fetchDogSaves().then((_) {
      setState(() {});
    });
  }

  Widget _buildLogsView(Map<String, List<Map<String, dynamic>>> groupedSaves) {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
    final dailySaves = groupedSaves[dateKey] ?? [];

    if (dailySaves.isEmpty) {
      return const Center(child: Text('No logs for selected day'));
    }

    if (isTimelineView) {
      return _buildTimelineView(dailySaves);
    } else {
      return _buildListView(dailySaves);
    }
  }

  Widget _buildListView(List<Map<String, dynamic>> dailySaves) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailySaves.length,
      itemBuilder: (context, index) {
        final save = dailySaves[index];
        DateTime? saveDate;
        try {
          saveDate = DateTime.parse(save['dateSave']!);
        } catch (e) {
          return Container();
        }

        final time = DateFormat('h:mm a').format(saveDate);
        final mood = save['mood'] ?? '';
        final info = save['info'] ?? '';
        final moodLower = mood.toLowerCase();

        Color moodColor = Colors.grey;
        if (moodLower == 'happy') moodColor = Colors.green;
        else if (moodLower == 'sad') moodColor = Colors.blue;
        else if (moodLower == 'angry') moodColor = Colors.red;

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

  Widget _buildTimelineView(List<Map<String, dynamic>> dailySaves) {
    dailySaves.sort((a, b) {
      final dateA = DateTime.parse(a['dateSave']!);
      final dateB = DateTime.parse(b['dateSave']!);
      return dateA.compareTo(dateB);
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
          return Container();
        }

        final time = DateFormat('HH:mm').format(saveDate);
        final mood = save['mood'] ?? '';
        final moodLower = mood.toLowerCase();

        Color moodColor = Colors.grey;
        if (moodLower == 'happy') moodColor = Colors.green;
        else if (moodLower == 'sad') moodColor = Colors.blue;
        else if (moodLower == 'angry') moodColor = Colors.red;

        return Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                time,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: moodColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 8),
            if (index < dailySaves.length - 1)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.only(left: 5),
              ),

            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: moodColor.withOpacity(0.3)),
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    color: moodColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dog = ctrl.currentDog.value;
    if (dog == null) {
      return const Scaffold(
        body: Center(child: Text('No dog selected')),
      );
    }

    final saves = ctrl.dogSaves[dog.id] ?? [];

    final Map<String, List<Map<String, dynamic>>> groupedSaves = {};
    for (var save in saves) {
      final dateStr = save['dateSave']?.toString();
      if (dateStr == null || dateStr.isEmpty) continue;

      DateTime? date;
      try {
        date = DateTime.parse(dateStr);
      } catch (e) {
        continue;
      }

      final dayKey = DateFormat('yyyy-MM-dd').format(date);
      groupedSaves.putIfAbsent(dayKey, () => []).add(save);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
              return groupedSaves[dateKey] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
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
          // View toggle and title
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
                    IconButton(
                      icon: Icon(
                        Icons.list,
                        color: !isTimelineView ? const Color(0xFFE15C31) : Colors.grey,
                      ),
                      onPressed: () => setState(() => isTimelineView = false),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.timeline,
                        color: isTimelineView ? const Color(0xFFE15C31) : Colors.grey,
                      ),
                      onPressed: () => setState(() => isTimelineView = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Daily Logs
          Expanded(
            child: _buildLogsView(groupedSaves),
          ),
        ],
      ),
    );
  }
}
