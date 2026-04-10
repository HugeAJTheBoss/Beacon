import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'preferences_service.dart';
import 'services/auth_service.dart';

class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({super.key});

  @override
  State<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {

  @override
  void initState() {
    super.initState();
    PreferencesService.setRestoreOrgOnLaunch(true);
  }

  @override
  void dispose() {
    PreferencesService.setRestoreOrgOnLaunch(false);
    super.dispose();
  }

  // Dummy events — replace with Firestore later
  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Intro to Robotics Workshop',
      'category': 'Robotics',
      'type': 'Event',
      'date': 'June 14, 2026',
      'status': 'Upcoming',
      'websiteVisits': 12,
      'capacity': 30,
    },
    {
      'title': 'Summer Coding Club',
      'category': 'Computer Science',
      'type': 'Club',
      'date': 'Every Monday',
      'status': 'Upcoming',
      'websiteVisits': 8,
      'capacity': 20,
    },
  ];

  void _deleteEvent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Event?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.title),
        ),
        content: Text(
          'Are you sure you want to delete "${_events[index]['title']}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.subtle, height: 1.5),
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
              Navigator.pop(context);
              setState(() => _events.removeAt(index));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.title),
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
            onPressed: () async {
              await PreferencesService.setRestoreOrgOnLaunch(false);
              await AuthService().signOut();
              if (!context.mounted) return;
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

  void _openAddEventSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets the sheet expand to full height
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(
        onSubmit: (event) {
          setState(() => _events.add(event));
        },
      ),
    );
  }

  void _openEditEventSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(
        existingEvent: _events[index],
        onSubmit: (event) {
          setState(() => _events[index] = event);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              PreferencesService.setRestoreOrgOnLaunch(false);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            tooltip: 'Go Back',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => _confirmSignOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEventSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _events.isEmpty
                ? const Center(
                    child: Text(
                      'No events yet. Tap + Add Event to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtle, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return _OrgEventCard(
                        event: event,
                        onEdit: () => _openEditEventSheet(index),
                        onDelete: () => _deleteEvent(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrgEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrgEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (event['status']) {
      case 'Upcoming':
        return const Color(0xFF2979FF);
      case 'Past':
        return AppColors.subtle;
      case 'Draft':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.subtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final websiteVisits = (event['websiteVisits'] ?? event['signups'] ?? 0) as int;
    final capacity = event['capacity'] as int;
    final fillPercent = capacity > 0 ? websiteVisits / capacity : 0.0;

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

          // status + category chips
          Row(
            children: [
              _StatusChip(label: event['status'], color: _statusColor),
              const SizedBox(width: 8),
              _StatusChip(
                  label: event['category'],
                  color: const Color(0xFF00BFA5)),
            ],
          ),

          const SizedBox(height: 10),

          // title
          Text(
            event['title'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),

          const SizedBox(height: 4),

          // type + date
          Text(
            '${event['type']} • ${event['date']}',
            style: const TextStyle(fontSize: 13, color: AppColors.subtle),
          ),

          const SizedBox(height: 12),

          // website traffic progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$websiteVisits / $capacity website visits',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtle,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '${(fillPercent * 100).round()}%',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillPercent,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // edit + delete buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

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

// bottom sheet form for adding or editing an event
class _AddEventSheet extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;
  final Function(Map<String, dynamic>) onSubmit;

  const _AddEventSheet({this.existingEvent, required this.onSubmit});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _capacityController = TextEditingController();
  final _linkController = TextEditingController();
  final _dateController = TextEditingController();

  String _category = 'Robotics';
  String _type = 'Event';
  String _status = 'Upcoming';
  int _ageMin = 10;
  int _ageMax = 24;

  final List<String> _categories = [
    'Robotics', 'Biology', 'Math',
    'Computer Science', 'Engineering', 'Physics'
  ];
  final List<String> _types = [
    'Event', 'Club', 'Volunteering'
  ];
  final List<String> _statuses = ['Upcoming', 'Draft', 'Past'];

  @override
  void initState() {
    super.initState();
    // pre-fill fields if editing an existing event
    if (widget.existingEvent != null) {
      final e = widget.existingEvent!;
      _titleController.text = e['title'] ?? '';
      _descriptionController.text = e['description'] ?? '';
      _locationController.text = e['location'] ?? '';
      _costController.text = e['cost'] ?? '';
      _capacityController.text = e['capacity']?.toString() ?? '';
      _linkController.text = e['link'] ?? '';
      _dateController.text = e['date'] ?? '';
      _category = e['category'] ?? 'Robotics';
      _type = e['type'] ?? 'Event';
      _status = e['status'] ?? 'Upcoming';
      _ageMin = e['ageMin'] ?? 10;
      _ageMax = e['ageMax'] ?? 24;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _capacityController.dispose();
    _linkController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _category,
      'type': _type,
      'date': _dateController.text,
      'location': _locationController.text,
      'ageMin': _ageMin,
      'ageMax': _ageMax,
      'cost': _costController.text,
      'capacity': int.tryParse(_capacityController.text) ?? 0,
      'link': _linkController.text,
      'status': _status,
      'websiteVisits': widget.existingEvent?['websiteVisits'] ?? widget.existingEvent?['signups'] ?? 0,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEvent != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [

              // drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Event' : 'New Event',
                      style: const TextStyle(
                        fontSize: 20,
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
              ),

              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        _SheetField(
                          controller: _titleController,
                          label: 'Event Title',
                          hint: 'e.g. Summer Robotics Camp',
                          validator: (val) =>
                              val!.isEmpty ? 'Title is required' : null,
                        ),

                        _SheetField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'What is this event about?',
                          maxLines: 3,
                          validator: (val) =>
                              val!.isEmpty ? 'Description is required' : null,
                        ),

                        // category dropdown
                        _DropdownField(
                          label: 'Category',
                          value: _category,
                          items: _categories,
                          onChanged: (val) =>
                              setState(() => _category = val!),
                        ),

                        // type dropdown
                        _DropdownField(
                          label: 'Type',
                          value: _type,
                          items: _types,
                          onChanged: (val) => setState(() => _type = val!),
                        ),

                        // status dropdown
                        _DropdownField(
                          label: 'Status',
                          value: _status,
                          items: _statuses,
                          onChanged: (val) =>
                              setState(() => _status = val!),
                        ),

                        _SheetField(
                          controller: _dateController,
                          label: 'Date',
                          hint: 'e.g. June 14, 2026 or Every Tuesday',
                          validator: (val) =>
                              val!.isEmpty ? 'Date is required' : null,
                        ),

                        _SheetField(
                          controller: _locationController,
                          label: 'Location / Address',
                          hint: 'e.g. 100 Institute Rd, Worcester',
                          validator: (val) =>
                              val!.isEmpty ? 'Location is required' : null,
                        ),

                        // age range row
                        const SizedBox(height: 8),
                        const Text(
                          'Age Range',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.title),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Min: $_ageMin',
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13)),
                                  Slider(
                                    value: _ageMin.toDouble(),
                                    min: 5,
                                    max: 24,
                                    divisions: 19,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(
                                        () => _ageMin = val.round()),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Max: $_ageMax',
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13)),
                                  Slider(
                                    value: _ageMax.toDouble(),
                                    min: 5,
                                    max: 24,
                                    divisions: 19,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(
                                        () => _ageMax = val.round()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        _SheetField(
                          controller: _costController,
                          label: 'Cost',
                          hint: 'e.g. Free, \$50, Varies',
                          validator: (val) =>
                              val!.isEmpty ? 'Cost is required' : null,
                        ),
                        
                        _SheetField(
                          controller: _linkController,
                          label: 'Organization Website Link',
                          hint: 'https://',
                          keyboardType: TextInputType.url,
                          validator: (val) =>
                              val!.isEmpty ? 'Link is required' : null,
                        ),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEditing ? 'Save Changes' : 'Submit Event',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.subtle, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((item) =>
                DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
