import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'link_opener_stub.dart'
  if (dart.library.html) 'link_opener_web.dart';
import 'main.dart' show AppColors;

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});
// use date of brith
  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final double _distance = 25;
  final double _age = 14;

  final Map<String, bool> _types = {
    'Club': true,
    'Event': true,
    'Volunteering': true,
  };

  final Map<String, bool> _categories = {
    'Robotics': true,
    'Biology': true,
    'Math': true,
    'Computer Science': true,
    'Engineering': true,
    'Physics': true,
  };

  final List<Map<String, dynamic>> _allEvents = [
    {
      'title': 'WPI Robotics Summer Camp',
      'org': 'WPI',
      'location': 'Worcester',
      'distance': 2.0,
      'date': 'June 14, 2026',
      'link': 'https://www.wpi.edu',
      'description':
          'Hands-on robotics sessions for middle and high school students with team projects and mentor support.',
      'category': 'Robotics',
      'type': 'Event',
      'ageMin': 12,
      'ageMax': 18,
    },
    {
      'title': 'MassBio Community Lab Volunteers',
      'org': 'MassBio',
      'location': 'Boston',
      'distance': 45.0,
      'date': 'July 1, 2026',
      'link': 'https://www.massbio.org',
        'description':
          'Volunteer in community STEM labs, help younger students, and assist with weekend science activities.',
      'category': 'Biology',
      'type': 'Volunteering',
      'ageMin': 15,
      'ageMax': 18,
    },
    {
      'title': 'Math Olympiad Club',
      'org': 'Worcester Academy',
      'location': 'Worcester',
      'distance': 3.0,
      'date': 'Every Tuesday',
      'link': 'https://www.worcesteracademy.org',
        'description':
          'Weekly math challenge practice with peer-led sessions and competition prep.',
      'category': 'Math',
      'type': 'Club',
      'ageMin': 11,
      'ageMax': 18,
    },
    {
      'title': 'Girls Who Code Chapter',
      'org': 'Girls Who Code',
      'location': 'Worcester',
      'distance': 5.0,
      'date': 'Every Wednesday',
      'link': 'https://girlswhocode.com',
        'description':
          'Build coding projects with mentors and join collaborative workshops focused on real-world skills.',
      'category': 'Computer Science',
      'type': 'Club',
      'ageMin': 13,
      'ageMax': 18,
    },
    {
      'title': 'MIT AI Workshop',
      'org': 'MIT',
      'location': 'Cambridge',
      'distance': 48.0,
      'date': 'August 3, 2026',
      'link': 'https://www.mit.edu',
        'description':
          'One-day AI workshop introducing machine learning concepts, ethics, and interactive demos.',
      'category': 'Computer Science',
      'type': 'Event',
      'ageMin': 14,
      'ageMax': 18,
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    return _allEvents.where((event) {
      if (event['distance'] > _distance) return false;
      if (_age < event['ageMin'] || _age > event['ageMax']) return false;
      if (_types[event['type']] == false) return false;
      if (_categories[event['category']] == false) return false;
      return true;
    }).toList();
  }


  void _showReportDialog(Map<String, dynamic> event) {
    String? selectedReason;
    final TextEditingController detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.subtle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Why are you reporting this?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Incorrect information',
                          'Spam or scam',
                          'Inappropriate content',
                          'Duplicate listing',
                          'Other',
                        ].map(
                          (reason) => ChoiceChip(
                            label: Text(reason),
                            selected: selectedReason == reason,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: selectedReason == reason
                                  ? AppColors.primary
                                  : AppColors.title,
                              fontWeight: selectedReason == reason
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            onSelected: (_) {
                              setModalState(() => selectedReason = reason);
                            },
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add details (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedReason == null
                              ? null
                              : () {
                                  // TODO: send report to backend / Firestore
                                  // Example payload:
                                  // {
                                  //   'eventTitle': event['title'],
                                  //   'reason': selectedReason,
                                  //   'details': detailsController.text.trim(),
                                  //   'reportedAt': DateTime.now().toIso8601String(),
                                  // }

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Report submitted for "${event['title']}"',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Report',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final description = (event['description'] as String?)?.trim().isNotEmpty == true
        ? event['description'] as String
        : 'No description provided yet.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    event['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event['org'],
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Chip(label: event['category'], color: AppColors.primary),
                      const SizedBox(width: 8),
                      _Chip(label: event['type'], color: const Color(0xFF00BFA5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.subtle),
                      const SizedBox(width: 6),
                      Text(
                        event['date'],
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.subtle),
                      const SizedBox(width: 6),
                      Text(
                        '${event['location']} • ${event['distance'].round()} mi',
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.groups_outlined,
                          size: 16, color: AppColors.subtle),
                      const SizedBox(width: 6),
                      Text(
                        'Ages ${event['ageMin']} - ${event['ageMax']}',
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        title: const Text(
          'Guest View',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Filters',
            ),
          ),
        ],
      ),

      body: _filteredEvents.isEmpty
          ? const Center(
              child: Text(
                'No opportunities match your filters.',
                style: TextStyle(color: AppColors.subtle, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) => _EventCard(
                event: _filteredEvents[index],
                onViewDetails: () => _showEventDetails(_filteredEvents[index]),
                onReport: () => _showReportDialog(_filteredEvents[index]),
              ),
            ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onViewDetails;
  final VoidCallback onReport;

  const _EventCard({
    required this.event,
    required this.onViewDetails,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final link = (event['link'] as String?)?.trim() ?? '';

    Future<void> openWebsite() async {
      if (link.isEmpty) return;
      final normalizedLink = link.startsWith('http://') || link.startsWith('https://')
          ? link
          : 'https://$link';
      final uri = Uri.tryParse(normalizedLink);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid website link for this event.')),
        );
        return;
      }

      var opened = await openInBrowserTab(normalizedLink);

      if (!opened) {
        try {
          // Android/iOS/desktop path.
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!opened) {
            opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } on MissingPluginException {
          // If plugin registration is missing, still allow web fallback.
          opened = await openInBrowserTab(normalizedLink);
        }
      }

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website link on this device.')),
        );
      }
    }

    return InkWell(
      onTap: onViewDetails,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Chip(label: event['category'], color: AppColors.primary),
                const SizedBox(width: 8),
                _Chip(label: event['type'], color: const Color(0xFF00BFA5)),
                const Spacer(),
                IconButton(
                  onPressed: onReport,
                  icon: const Icon(
                    Icons.flag_outlined,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Report event',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              event['title'],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event['org'],
              style: const TextStyle(fontSize: 14, color: AppColors.subtle),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppColors.subtle,
                ),
                const SizedBox(width: 4),
                Text(
                  '${event['location']} • ${event['distance'].round()} mi',
                  style: const TextStyle(fontSize: 13, color: AppColors.subtle),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.subtle,
                ),
                const SizedBox(width: 4),
                Text(
                  event['date'],
                  style: const TextStyle(fontSize: 13, color: AppColors.subtle),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap for details',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: link.isEmpty ? null : openWebsite,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Visit Organization Website'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}