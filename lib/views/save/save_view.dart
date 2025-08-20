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
        'Saves',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedMonth =
                          DateTime(selectedMonth.year, selectedMonth.month - 1);
                    });
                  },
                ),
                Text(monthLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedMonth =
                          DateTime(selectedMonth.year, selectedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: DateUtils.getDaysInMonth(
                  selectedMonth.year, selectedMonth.month),
              itemBuilder: (context, index) {
                final day = index + 1;
                final date =
                    DateTime(selectedMonth.year, selectedMonth.month, day);
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final hasSave = filteredGroupedSaves.containsKey(dateKey);

                return Container(
                  decoration: BoxDecoration(
                    color: hasSave ? Colors.orange.shade300 : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hasSave ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
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
                            DateFormat('EEEE, MMM d, yyyy')
                                .format(DateTime.parse(day)),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...dailySaves.map((save) {
                            DateTime? saveDate;
                            try {
                              saveDate = DateTime.parse(save['dateSave']!);
                            } catch (e) {
                              print(
                                  "⚠️ Invalid save date: ${save['dateSave']}");
                              return Container();
                            }

                            final time = DateFormat('hh:mm a').format(saveDate);
                            final mood = save['mood'] ?? '';
                            final info = save['info'] ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(mood,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('$time\n$info'),
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
