import 'package:flutter/material.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Heart & Vitals',
    'Hormones & T',
    'Mental Wellness',
    'Cancer Defense',
    'Nutrition & Sleep',
  ];

  final List<Map<String, String>> _articles = [
    {
      'title': 'The Five-Year Male Mortality Gap: Causes and Prevention',
      'category': 'Heart & Vitals',
      'readTime': '4 min read',
      'source': 'CDC / AHA 2024 Synthesis',
      'summary':
          'Men in the US die on average five years earlier than women. Heart disease, unintentional injuries, and delayed screening account for over 65% of this disparity. Proactive annual vitals tracking is the single most effective countermeasure.',
    },
    {
      'title': 'Testosterone Decline After 30: Natural vs Clinical Hypogonadism',
      'category': 'Hormones & T',
      'readTime': '5 min read',
      'source': 'Endocrine Society Guidelines',
      'summary':
          'Total serum testosterone declines at roughly 1% per year starting at age 30. Distinguishing between normal physiological aging and clinical hypogonadism (< 300 ng/dL) requires morning blood draws, ADAM symptom evaluation, and lifestyle optimization.',
    },
    {
      'title': 'Masked Depression in Men: Why It Looks Like Irritability & Fatigue',
      'category': 'Mental Wellness',
      'readTime': '6 min read',
      'source': 'National Institute of Mental Health',
      'summary':
          'Societal stoicism often causes depression in men to manifest not as crying or sadness, but as sudden irritability, risk-taking behavior, somatic headaches, and withdrawal from relationships. Validated scales like PHQ-2 cut through masked symptoms.',
    },
    {
      'title': 'Colorectal Cancer at 45: Why the USPSTF Lowered the Screening Age',
      'category': 'Cancer Defense',
      'readTime': '3 min read',
      'source': 'USPSTF Recommendation Statement',
      'summary':
          'Due to an alarming rise in early-onset colorectal malignancies in men under 50, the national guideline was officially lowered to age 45. A single colonoscopy can remove pre-cancerous adenomatous polyps years before malignant transformation.',
    },
    {
      'title': 'Circadian Anchoring: How Morning Photons Elevate Deep REM Sleep',
      'category': 'Nutrition & Sleep',
      'readTime': '4 min read',
      'source': 'Sleep Medicine Reviews',
      'summary':
          'Viewing 10 minutes of outdoor morning sunlight stimulates retinal ganglion cells, setting an internal 14-hour timer that triggers melatonin release at bedtime, deepening restorative slow-wave sleep and nighttime testosterone synthesis.',
    },
    {
      'title': 'Erectile Dysfunction: The Early Warning System for Coronary Disease',
      'category': 'Heart & Vitals',
      'readTime': '5 min read',
      'source': 'American Urological Association',
      'summary':
          'Because penile arteries (1–2 mm) are much smaller than coronary arteries (3–4 mm), endothelial damage and plaque buildup cause erectile issues 3 to 5 years before heart attacks occur. ED should always trigger a comprehensive cardiovascular review.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _articles
        : _articles.where((a) => a['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Male Health Library',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3B82F6),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          ...filtered.map((art) => Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              art['category']!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            art['readTime']!,
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        art['title']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Source: ${art['source']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        art['summary']!,
                        style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
