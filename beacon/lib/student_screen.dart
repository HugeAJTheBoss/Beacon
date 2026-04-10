import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'link_opener_stub.dart'
  if (dart.library.html) 'link_opener_web.dart';
import 'app_theme.dart';
import 'preferences_service.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  double _distance = 25;
  double _age = 14;
  String _zip = '';
  DateTime? _dob;
  bool _loading = true;

  final Map<String, bool> _types = {
    'Club': false,
    'Event': false,
    'Volunteering': false,
  };

  final Map<String, bool> _categories = {
    'Robotics': false,
    'Biology': false,
    'Math': false,
    'Computer Science': false,
    'Engineering': false,
    'Physics': false,
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

  @override
  void initState() {
    super.initState();
    PreferencesService.setRestoreStudentOnLaunch(true);
    _loadPreferences();
  }

  @override
  void dispose() {
    PreferencesService.setRestoreStudentOnLaunch(false);
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await PreferencesService.getAll();
      if (prefs['setupDone'] == true) {
        setState(() {
          _age = prefs['age'];
          _distance = prefs['distance'];
          _zip = prefs['zip'];
          _dob = prefs['dob'];
          final savedTypes = prefs['types'] as Map<String, bool>;
          final savedCats = prefs['categories'] as Map<String, bool>;
          _types.updateAll((key, _) => savedTypes[key] ?? true);
          _categories.updateAll((key, _) => savedCats[key] ?? true);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showWelcomePopup();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveFilters() async {
    if (_dob != null) {
      await PreferencesService.saveAll(
        dob: _dob!,
        zip: _zip,
        distance: _distance,
        types: _types,
        categories: _categories,
      );
    }
  }

  void _showWelcomePopup() {
    DateTime? tempDob;
    final zipController = TextEditingController();
    final tempTypes = Map<String, bool>.from(_types);
    final tempCategories = Map<String, bool>.from(_categories);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.92,
              minChildSize: 0.92,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Welcome to Beacon!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.title,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tell us a bit about yourself so we can show you the best opportunities.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.subtle,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          const SizedBox(height: 16),

                          const Text(
                            'Date of Birth',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempDob ?? DateTime(2010, 1, 1),
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now(),
                                helpText: 'SELECT YOUR DATE OF BIRTH',
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                              );
                              if (picked != null) {
                                setModalState(() => tempDob = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cake_outlined,
                                      color: AppColors.subtle, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    tempDob != null
                                        ? '${tempDob!.month}/${tempDob!.day}/${tempDob!.year}'
                                        : 'Tap to select your birthday',
                                    style: TextStyle(
                                      color: tempDob != null
                                          ? AppColors.title
                                          : AppColors.subtle,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Zip Code',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: zipController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 01609',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'What are you interested in?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tempCategories.keys.map((cat) {
                              final selected = tempCategories[cat]!;
                              return FilterChip(
                                label: Text(cat),
                                selected: selected,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.title,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                onSelected: (val) => setModalState(
                                    () => tempCategories[cat] = val),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'What type of opportunities?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tempTypes.keys.map((type) {
                              final selected = tempTypes[type]!;
                              return FilterChip(
                                label: Text(type),
                                selected: selected,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.title,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                onSelected: (val) =>
                                    setModalState(() => tempTypes[type] = val),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (tempDob == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please select your date of birth.'),
                                  ),
                                );
                                return;
                              }
                              if (zipController.text.trim().length < 5) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a valid 5-digit zip code.'),
                                  ),
                                );
                                return;
                              }
                              if (!tempTypes.values.any((v) => v) ||
                                  !tempCategories.values.any((v) => v)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Select at least one interest and one type.'),
                                  ),
                                );
                                return;
                              }

                              // Derive age from DOB so filters match age-limited events.
                              final now = DateTime.now();
                              double age = (now.year - tempDob!.year).toDouble();
                              if (now.month < tempDob!.month ||
                                  (now.month == tempDob!.month &&
                                      now.day < tempDob!.day)) {
                                age -= 1;
                              }

                              setState(() {
                                _dob = tempDob;
                                _zip = zipController.text.trim();
                                _age = age.clamp(5, 24);
                                _types.updateAll(
                                    (key, _) => tempTypes[key] ?? true);
                                _categories.updateAll(
                                    (key, _) => tempCategories[key] ?? true);
                              });

                              _saveFilters();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                                  // TODO: Save report to backend (Firestore/API).

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
        elevation: 0,
        title: const Text(
          'Beacon',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
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
                          onChanged: (val) {
                            setState(() => _distance = val);
                            _saveFilters();
                          },
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
              ],
            ),
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filteredEvents.isEmpty
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
          // On mobile/desktop, fall back to url_launcher.
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!opened) {
            opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } on MissingPluginException {
          // Plugin may not be available in some builds; retry web path.
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
