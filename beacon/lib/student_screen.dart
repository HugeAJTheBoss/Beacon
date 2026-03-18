import 'package:flutter/material.dart';
import 'main.dart' show AppColors;

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

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

  // Dummy data — replace with Firestore later
  final List<Map<String, dynamic>> _allEvents = [
    {
      'title': 'WPI Robotics Summer Camp',
      'org': 'WPI',
      'location': 'Worcester',
      'distance': 2.0,
      'date': 'June 14, 2026',
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
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => Scaffold.of(context).openDrawer(),
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
                        ..._types.keys.map((type) => CheckboxListTile(
                              title: Text(type),
                              value: _types[type],
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) =>
                                  setState(() => _types[type] = val!),
                            )),

                        const SizedBox(height: 8),
                        const _SectionTitle(title: 'Category'),
                        const SizedBox(height: 4),
                        ..._categories.keys.map((cat) => CheckboxListTile(
                              title: Text(cat),
                              value: _categories[cat],
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) =>
                                  setState(() => _categories[cat] = val!),
                            )),
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
              itemBuilder: (context, index) =>
                  _EventCard(event: _filteredEvents[index]),
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
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
          const SizedBox(height: 10),
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
              const Icon(Icons.location_on_outlined,
                  size: 15, color: AppColors.subtle),
              const SizedBox(width: 4),
              Text(
                '${event['location']} • ${event['distance'].round()} mi',
                style: const TextStyle(fontSize: 13, color: AppColors.subtle),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.subtle),
              const SizedBox(width: 4),
              Text(
                event['date'],
                style: const TextStyle(fontSize: 13, color: AppColors.subtle),
              ),
            ],
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