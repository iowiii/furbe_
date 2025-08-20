import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/data_controller.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  final DataController ctrl = Get.find<DataController>();
  bool loadingLinks = true;
  List<Map<String, String>> links = [];
  String recentMood = "unknown";

  @override
  void initState() {
    super.initState();
    fetchTipsFromController();
  }

  Future<void> fetchTipsFromController() async {
    final dog = ctrl.currentDog.value;

    if (dog == null) {
      setState(() => loadingLinks = false);
      return;
    }

    if (!ctrl.dogSaves.containsKey(dog.id)) {
      await ctrl.fetchDogSaves();
    }

    final saves = ctrl.dogSaves[dog.id] ?? [];
    recentMood = analyzeRecentMood(saves);

    if (recentMood == "happy") {
      links = [
        {
          'title': "Keep your dog happy",
          'url': "https://www.helpguide.org/wellness/pets/mood-boosting-power-of-dogs"
        }
      ];
    } else if (recentMood == "sad") {
      links = [
        {
          'title': "Comforting a sad dog",
          'url': "https://petparentsbrand.com/blogs/health/is-your-dog-sad-try-these-strategies-for-how-to-cheer-up-a-sad-dog?srsltid=AfmBOopRtQ8opmP2cPnXeAK9oaywtExCxXwaE59Rm5-lf7lzJnbO6Eav"
        }
      ];
    } else if (recentMood == "angry") {
      links = [
        {
          'title': "Managing an angry dog",
          'url': "https://www.aspca.org/pet-care/dog-care/common-dog-behavior-issues/aggression"
        }
      ];
    } else if (recentMood == "scared") {
      links = [
        {
          'title': "Helping a scared dog",
          'url': "https://www.thehumananimalconnection.org/post/smitty-the-pitty-emerges-from-fear"
        }
      ];
    } else {
      links = [
        {
          'title': "General dog care tips",
          'url': "https://en.wikipedia.org/wiki/Dog"
        }
      ];
    }

    links = links.map((link) {
      link['favicon'] = getFavicon(link['url'] ?? "");
      return link;
    }).toList();

    setState(() => loadingLinks = false);
  }

  String analyzeRecentMood(List<Map<String, dynamic>> saves) {
    if (saves.isEmpty) return "unknown";

    saves.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['dateSave'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB = DateTime.tryParse(b['dateSave'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    final recent = saves.length <= 5 ? saves : saves.sublist(0, 5);
    final Map<String, int> moodCount = {};
    for (var s in recent) {
      final mood = (s['mood'] ?? "unknown").toLowerCase();
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    }

    return moodCount.entries.isNotEmpty
        ? moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : "unknown";
  }

  String getFavicon(String url) {
    try {
      Uri uri = Uri.parse(url);
      return "https://www.google.com/s2/favicons?domain=${uri.host}";
    } catch (e) {
      return "";
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dog = ctrl.currentDog.value;

    if (dog == null) {
      return const Scaffold(
        body: Center(child: Text("⚠️ No dog selected.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tips")),
      body: loadingLinks
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: link['favicon'] != null && link['favicon']!.isNotEmpty
                  ? Image.network(
                link['favicon']!,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              )
                  : null,
              title: Text(
                link['title'] ?? 'No title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(link['url'] ?? ''),
              onTap: () {
                final url = link['url'];
                if (url != null && url.isNotEmpty) _launchURL(url);
              },
            ),
          );
        },
      ),
    );
  }
}


//import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
// import '../../controllers/data_controller.dart';
//
// class TipsView extends StatefulWidget {
//   const TipsView({super.key});
//
//   @override
//   State<TipsView> createState() => _TipsViewState();
// }
//
// class _TipsViewState extends State<TipsView> {
//   final DataController ctrl = Get.find<DataController>();
//   bool loadingLinks = true;
//   List<Map<String, String>> links = [];
//   String recentMood = "unknown";
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTipsFromController();
//   }
//
//   Future<void> fetchTipsFromController() async {
//     final dog = ctrl.currentDog.value;
//     final phone = ctrl.currentPhone;
//
//     if (dog == null || phone == null) {
//       setState(() => loadingLinks = false);
//       return;
//     }
//
//     if (!ctrl.dogSaves.containsKey(dog.id)) {
//       await ctrl.fetchDogSaves();
//     }
//
//     final saves = ctrl.dogSaves[dog.id] ?? [];
//     recentMood = analyzeRecentMood(saves);
//
//     String query = recentMood != "unknown" && recentMood.isNotEmpty
//         ? "How to take care of a dog when it is $recentMood"
//         : "How to take care of a dog";
//
//     await fetchWikipediaLinks(query);
//   }
//
//   Future<void> fetchWikipediaLinks(String query) async {
//     setState(() => loadingLinks = true);
//     links = [];
//
//     try {
//       final searchUrl = Uri.parse(
//           'https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=${Uri.encodeComponent(query)}&utf8=');
//       final response = await http.get(searchUrl);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final searchResults = data['query']['search'] as List<dynamic>;
//
//         links = searchResults.map((item) {
//           final title = item['title'] as String;
//           final pageId = item['pageid'].toString();
//           final url = 'https://en.wikipedia.org/?curid=$pageId';
//           return {'title': title, 'url': url};
//         }).toList();
//       }
//     } catch (e) {
//       print("❌ Wikipedia fetch failed: $e");
//     } finally {
//       setState(() => loadingLinks = false);
//     }
//   }
//
//   String analyzeRecentMood(List<Map<String, dynamic>> saves) {
//     if (saves.isEmpty) return "unknown";
//
//     saves.sort((a, b) {
//       DateTime dateA = DateTime.tryParse(a['dateSave'] ?? '') ??
//           DateTime.fromMillisecondsSinceEpoch(0);
//       DateTime dateB = DateTime.tryParse(b['dateSave'] ?? '') ??
//           DateTime.fromMillisecondsSinceEpoch(0);
//       return dateB.compareTo(dateA);
//     });
//
//     final recent = saves.length <= 5 ? saves : saves.sublist(0, 5);
//     final Map<String, int> moodCount = {};
//     for (var s in recent) {
//       final mood = (s['mood'] ?? "unknown").toLowerCase();
//       moodCount[mood] = (moodCount[mood] ?? 0) + 1;
//     }
//
//     final mostRecentMood = moodCount.entries.isNotEmpty
//         ? moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
//         : "unknown";
//
//     return mostRecentMood;
//   }
//
//   Future<void> _launchURL(String url) async {
//     final uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Could not open link')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dog = ctrl.currentDog.value;
//     if (dog == null) {
//       return const Scaffold(
//         body: Center(child: Text("⚠️ No dog selected.")),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Tips")),
//       body: loadingLinks
//           ? const Center(child: CircularProgressIndicator())
//           : links.isEmpty
//           ? Center(
//           child: Text(
//             "No tips found for recent mood: $recentMood",
//             style: const TextStyle(fontSize: 16),
//           ))
//           : ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: links.length,
//         itemBuilder: (context, index) {
//           final link = links[index];
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               title: Text(
//                 link['title'] ?? 'No title',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(link['url'] ?? ''),
//               onTap: () {
//                 final url = link['url'];
//                 if (url != null && url.isNotEmpty) {
//                   _launchURL(url);
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }