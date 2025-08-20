import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsView extends StatelessWidget {
  const TipsView({super.key});

  final List<Map<String, String>> articles = const [
    {
      "title": "How To Take Care of Dogs: A Pet Parent Checklist",
      "subtitle": "petMD",
      "logo":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQqLPZPuqRWs2S6mjJIptbz4nXwQZXIk9zuIb7IXCx2cADmhw2hEDL5F3wXieULE_wt3o&usqp=CAU", // placeholder
      "url":
          "https://www.petmd.com/dog/general-health/how-to-take-care-of-dogs-pet-parent-checklist"
    },
    {
      "title": "Top Ten Tips for Responsible Pet Ownership",
      "subtitle": "National Pet Month",
      "logo":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAlwa3gMM7OSmTFXiyGNfQKs6dkVS2O5alcQ&s", // placeholder
      "url":
          "https://www.nationalpetmonth.org.uk/news/top-ten-tips-for-responsible-pet-ownership"
    },
    {
      "title": "First Time Down Owner Guide",
      "subtitle": "Cesar",
      "logo":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrGI11cGRmUKnCspNHHGPMG4cAiTQjw9Lzgw&s", // placeholder
      "url":
          "https://www.cesar.com.ph/dog-care/health-and-safety/first-time-dog-owner-guide"
    },
    {
      "title": "First aid tips for pet owners",
      "subtitle": "AVMA",
      "logo":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxWWCv6Q7mKGPE4RtrTO0Zx6hCuD0ONY08qQ&s", // placeholder
      "url":
          "https://www.avma.org/resources-tools/pet-owners/emergencycare/first-aid-tips-pet-owners"
    },
  ];

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Tips",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      )),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE15C31), width: 1.5),
            ),
            child: ListTile(
              leading: Image.network(
                article["logo"]!,
                width: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pets, size: 40),
              ),
              title: Text(article["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(article["subtitle"]!),
              onTap: () => _openUrl(article["url"]!),
            ),
          );
        },
      ),
    );
  }
}

//import 'package:flutter/material.dart';
// import 'package:get/get.dart';
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
//
//     if (dog == null) {
//       setState(() => loadingLinks = false);
//       return;
//     }
//
//     // Ensure dog saves are loaded
//     if (!ctrl.dogSaves.containsKey(dog.id)) {
//       await ctrl.fetchDogSaves();
//     }
//
//     final saves = ctrl.dogSaves[dog.id] ?? [];
//     recentMood = analyzeRecentMood(saves);
//
//     // Assign links manually per mood
//     if (recentMood == "happy") {
//       links = [
//         {
//           'title': "Keep your dog happy",
//           'url': "https://www.helpguide.org/wellness/pets/mood-boosting-power-of-dogs"
//         }
//       ];
//     } else if (recentMood == "sad") {
//       links = [
//         {
//           'title': "Comforting a sad dog",
//           'url': "https://petparentsbrand.com/blogs/health/is-your-dog-sad-try-these-strategies-for-how-to-cheer-up-a-sad-dog?srsltid=AfmBOopRtQ8opmP2cPnXeAK9oaywtExCxXwaE59Rm5-lf7lzJnbO6Eav"
//         }
//       ];
//     } else if (recentMood == "angry") {
//       links = [
//         {
//           'title': "Managing an angry dog",
//           'url': "https://www.aspca.org/pet-care/dog-care/common-dog-behavior-issues/aggression"
//         }
//       ];
//     } else if (recentMood == "scared") {
//       links = [
//         {
//           'title': "Helping a scared dog",
//           'url': "https://www.thehumananimalconnection.org/post/smitty-the-pitty-emerges-from-fear"
//         }
//       ];
//     } else {
//       links = [
//         {
//           'title': "General dog care tips",
//           'url': "https://en.wikipedia.org/wiki/Dog"
//         }
//       ];
//     }
//
//     // Add favicon for each link
//     links = links.map((link) {
//       link['favicon'] = getFavicon(link['url'] ?? "");
//       return link;
//     }).toList();
//
//     setState(() => loadingLinks = false);
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
//     return moodCount.entries.isNotEmpty
//         ? moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
//         : "unknown";
//   }
//
//   String getFavicon(String url) {
//     try {
//       Uri uri = Uri.parse(url);
//       return "https://www.google.com/s2/favicons?domain=${uri.host}";
//     } catch (e) {
//       return "";
//     }
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
//
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
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: links.length,
//               itemBuilder: (context, index) {
//                 final link = links[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: ListTile(
//                     leading: link['favicon'] != null && link['favicon']!.isNotEmpty
//                         ? Image.network(
//                             link['favicon']!,
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.contain,
//                           )
//                         : null,
//                     title: Text(
//                       link['title'] ?? 'No title',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(link['url'] ?? ''),
//                     onTap: () {
//                       final url = link['url'];
//                       if (url != null && url.isNotEmpty) _launchURL(url);
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
