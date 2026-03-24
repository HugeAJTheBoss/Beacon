import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'link_opener_stub.dart'
  if (dart.library.html) 'link_opener_web.dart';
import 'main.dart' show AppColors;

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
// use date of brith
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  double _distance = 25;
  double _age = 14;

  final Map<String, bool> _types = {
    'Club': true,
    'Internship': true,
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
      'category': 'Robotics',
      'type': 'Event',
      'ageMin': 12,
      'ageMax': 18,
    },
    {
      'title': 'MassBio High School Internship',
      'org': 'MassBio',
      'location': 'Boston',
      'distance': 45.0,
      'date': 'July 1, 2026',
      'link': 'https://www.massbio.org',
      'category': 'Biology',
      'type': 'Internship',
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

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        content: const Text(
          'You will be returned to the home screen.',
          style: TextStyle(color: AppColors.subtle, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.subtle),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Firebase Auth sign out goes here
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
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
                      ...[
                        'Incorrect information',
                        'Spam or scam',
                        'Inappropriate content',
                        'Duplicate listing',
                        'Other',
                      ].map(
                        (reason) => RadioListTile<String>(
                          value: reason,
                          groupValue: selectedReason,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text(reason),
                          onChanged: (value) {
                            setModalState(() => selectedReason = value);
                          },
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Beacon',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Profile',
          ),
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

      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Icon(
                  Icons.account_circle,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Student',
                  style: TextStyle(color: AppColors.subtle, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Settings & Interests',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: navigate to student profile screen
                  },
                ),
                const Divider(),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),

      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _FilterLabel(
                          title: 'Distance',
                          value: '${_distance.round()} mi',
                        ),
                        Slider(
                          value: _distance,
                          min: 5,
                          max: 100,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _distance = val),
                        ),
                        const SizedBox(height: 8),
                        _FilterLabel(
                          title: 'Your Age',
                          value: '${_age.round()}',
                        ),
                        Slider(
                          value: _age,
                          min: 5,
                          max: 24,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _age = val),
                        ),
                        const SizedBox(height: 8),
                        const _SectionTitle(title: 'Type'),
                        const SizedBox(height: 4),
                        ..._types.keys.map(
                          (type) => CheckboxListTile(
                            title: Text(type),
                            value: _types[type],
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) =>
                                setState(() => _types[type] = val!),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _SectionTitle(title: 'Category'),
                        const SizedBox(height: 4),
                        ..._categories.keys.map(
                          (cat) => CheckboxListTile(
                            title: Text(cat),
                            value: _categories[cat],
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) =>
                                setState(() => _categories[cat] = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                onReport: () => _showReportDialog(_filteredEvents[index]),
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String title;
  final String value;
  const _FilterLabel({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionTitle(title: title),
        Text(value, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onReport;

  const _EventCard({
    required this.event,
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

    return Container(
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