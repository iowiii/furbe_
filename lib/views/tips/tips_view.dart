import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsView extends StatelessWidget {
  const TipsView({super.key});

  final List<Map<String, String>> articles = const [
    {
      "title": "How To Take Care of Dogs: A Pet Parent Checklist",
      "subtitle": "petMD",
      "logo": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQqLPZPuqRWs2S6mjJIptbz4nXwQZXIk9zuIb7IXCx2cADmhw2hEDL5F3wXieULE_wt3o&usqp=CAU", // placeholder
      "url": "https://www.petmd.com/dog/general-health/how-to-take-care-of-dogs-pet-parent-checklist"
    },
    {
      "title": "Top Ten Tips for Responsible Pet Ownership",
      "subtitle": "National Pet Month",
      "logo": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAlwa3gMM7OSmTFXiyGNfQKs6dkVS2O5alcQ&s", // placeholder
      "url": "https://www.nationalpetmonth.org.uk/news/top-ten-tips-for-responsible-pet-ownership"
    },
    {
      "title": "First Time Down Owner Guide",
      "subtitle": "Cesar",
      "logo": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrGI11cGRmUKnCspNHHGPMG4cAiTQjw9Lzgw&s", // placeholder
      "url": "https://www.cesar.com.ph/dog-care/health-and-safety/first-time-dog-owner-guide"
    },
    {
      "title": "First aid tips for pet owners",
      "subtitle": "AVMA",
      "logo": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxWWCv6Q7mKGPE4RtrTO0Zx6hCuD0ONY08qQ&s", // placeholder
      "url": "https://www.avma.org/resources-tools/pet-owners/emergencycare/first-aid-tips-pet-owners"
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
      appBar: AppBar(title: const Text("Tips", style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),)),
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
