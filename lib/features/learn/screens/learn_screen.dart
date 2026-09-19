import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

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
      'source': 'CDC / AHA Clinical Synthesis',
      'url': 'https://www.cdc.gov/nchs/fastats/mens-health.htm',
      'summary':
          'Men in the US die on average five years earlier than women. Heart disease, unintentional injuries, and delayed screening account for over 65% of this disparity. Proactive annual vitals tracking is the single most effective countermeasure.',
    },
    {
      'title': 'Testosterone Decline After 30: Natural vs Clinical Hypogonadism',
      'category': 'Hormones & T',
      'readTime': '5 min read',
      'source': 'Endocrine Society Guidelines',
      'url': 'https://www.endocrine.org/clinical-guidelines/hypogonadism',
      'summary':
          'Total serum testosterone declines at roughly 1% per year starting at age 30. Distinguishing between normal physiological aging and clinical hypogonadism (< 300 ng/dL) requires morning blood draws, ADAM symptom evaluation, and lifestyle optimization.',
    },
    {
      'title': 'Masked Depression in Men: Why It Looks Like Irritability & Fatigue',
      'category': 'Mental Wellness',
      'readTime': '6 min read',
      'source': 'National Institute of Mental Health',
      'url': 'https://www.nimh.nih.gov/health/publications/men-and-depression',
      'summary':
          'Societal stoicism often causes depression in men to manifest not as crying or sadness, but as sudden irritability, risk-taking behavior, somatic headaches, and withdrawal from relationships. Validated scales like PHQ-2 cut through masked symptoms.',
    },
    {
      'title': 'Colorectal Cancer at 45: Why the USPSTF Lowered the Screening Age',
      'category': 'Cancer Defense',
      'readTime': '3 min read',
      'source': 'USPSTF Recommendation Statement',
      'url': 'https://www.uspreventiveservicestaskforce.org/uspstf/recommendation/colorectal-cancer-screening',
      'summary':
          'Due to an alarming rise in early-onset colorectal malignancies in men under 50, the national guideline was officially lowered to age 45. A single colonoscopy can remove pre-cancerous adenomatous polyps years before malignant transformation.',
    },
    {
      'title': 'Circadian Anchoring: How Morning Photons Elevate Deep REM Sleep',
      'category': 'Nutrition & Sleep',
      'readTime': '4 min read',
      'source': 'Sleep Medicine Reviews',
      'url': 'https://www.sleepfoundation.org/circadian-rhythm',
      'summary':
          'Viewing 10 minutes of outdoor morning sunlight stimulates retinal ganglion cells, setting an internal 14-hour timer that triggers melatonin release at bedtime, deepening restorative slow-wave sleep and nighttime testosterone synthesis.',
    },
    {
      'title': 'Erectile Dysfunction: The Early Warning System for Coronary Disease',
      'category': 'Heart & Vitals',
      'readTime': '5 min read',
      'source': 'American Urological Association',
      'url': 'https://www.auanet.org/guidelines-and-quality/guidelines/erectile-dysfunction',
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
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianBase,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: AppTheme.neonCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'CLINICAL INTELLIGENCE ARCHIVE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.neonCyan.withOpacity(0.18) : AppTheme.obsidianCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.neonCyan : AppTheme.obsidianBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          ...filtered.map((art) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: AppTheme.cyberCardDecoration(
                  borderColor: AppTheme.neonCyan.withOpacity(0.3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.neonCyan.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
                            ),
                            child: Text(
                              art['category']!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            art['readTime']!,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        art['title']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.verified_outlined, size: 12, color: AppTheme.neonEmerald),
                          const SizedBox(width: 4),
                          Text(
                            art['source']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.neonEmerald,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        art['summary']!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.neonCyan,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () => _launchArticleUrl(art['url']),
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text(
                            'Read Clinical Guideline',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchArticleUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open clinical resource: $url')),
        );
      }
    }
  }
}

