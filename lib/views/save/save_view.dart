import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import 'package:intl/intl.dart';

class SaveView extends StatefulWidget {
  const SaveView({super.key});

  @override
  State<SaveView> createState() => _SaveViewState();
}

class _SaveViewState extends State<SaveView> {
  final DataController ctrl = Get.find<DataController>();
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    ctrl.fetchDogSaves().then((_) {
      print("✅ Dog saves loaded: ${ctrl.dogSaves}");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final dog = ctrl.currentDog.value;
    if (dog == null) {
      return const Scaffold(
        body: Center(child: Text('⚠️ No dog selected')),
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
        print("⚠️ Invalid date format: $dateStr");
        continue;
      }

      final dayKey = DateFormat('yyyy-MM-dd').format(date);
      groupedSaves.putIfAbsent(dayKey, () => []).add(save);
    }

    final monthLabel = DateFormat('MMMM yyyy').format(selectedMonth);

    final filteredGroupedSaves = Map<String, List<Map<String, dynamic>>>.from(
      groupedSaves
        ..removeWhere((key, value) {
          final date = DateTime.tryParse(key);
          if (date == null) return true;
          return !(date.year == selectedMonth.year &&
              date.month == selectedMonth.month);
        }),
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Calendar',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      )),
        body: Column(
          children: [
            // Month navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Color(0xFFE15C31),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                      });
                    },
                  ),
                  Text(monthLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height:10),
            // Weekday labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                    .map((day) => Expanded(
                  child: Center(
                      child: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ))
                    .toList(),
              ),
            ),

            // Calendar grid
            Container(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = DateTime(selectedMonth.year, selectedMonth.month, day);
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final hasSave = filteredGroupedSaves.containsKey(dateKey);

                  // 🌈 Mood-based color
                  Color? bgColor;
                  if (hasSave) {
                    final moods = filteredGroupedSaves[dateKey]!
                        .map((e) => e['mood']?.toLowerCase() ?? '')
                        .toSet();
                    if (moods.contains('happy')) bgColor = Colors.green;
                    else if (moods.contains('sad')) bgColor = Colors.blue;
                    else if (moods.contains('angry')) bgColor = Colors.red;
                    else bgColor = Colors.orange;
                  }

                  final isToday = DateTime.now().day == date.day &&
                      DateTime.now().month == date.month &&
                      DateTime.now().year == date.year;

                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.white,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Color(0xFFE15C31), width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: bgColor != null ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            //Title Dialy log
            const Padding(
              padding: EdgeInsets.only(left: 20.0), // just a small indent
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Daily Logs',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 5),
            // Daily Logs
            Expanded(
              child: filteredGroupedSaves.isEmpty
                  ? const Center(child: Text('No saves for this month'))
                  : ListView(
                padding: const EdgeInsets.all(8),
                children: filteredGroupedSaves.entries.map((entry) {
                  final day = entry.key;
                  final dailySaves = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(day)),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...dailySaves.map((save) {
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
                            title: Row(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: moodColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    mood,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: moodColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(time,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(info),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
    );
  }
}
