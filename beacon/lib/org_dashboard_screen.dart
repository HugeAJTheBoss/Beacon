// Sources also used in previous files
// Firebase Firestore:         https://firebase.flutter.dev/docs/firestore/usage/
// Firebase Auth:              https://firebase.flutter.dev/docs/auth/usage/
// StatefulWidget/State:       https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
// Navigator/MaterialPageRoute:https://api.flutter.dev/flutter/widgets/Navigator/push.html
// ElevatedButton:             https://api.flutter.dev/flutter/material/ElevatedButton-class.html
// Scaffold/AppBar:            https://api.flutter.dev/flutter/material/Scaffold-class.html
// setState:                   https://api.flutter.dev/flutter/widgets/State/setState.html
// mounted check:              https://api.flutter.dev/flutter/widgets/State/mounted.html

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'preferences_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({super.key});

  @override
  State<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {

  @override
  void initState() {
    // initState - called once when the widget is inserted into the tree
    // Tutorial: https://www.geeksforgeeks.org/flutter-initstate/
    super.initState();
    PreferencesService.setRestoreOrgOnLaunch(true);
  }

  @override
  void dispose() {
    // dispose - called when the widget is permanently removed; used for cleanup
    // Source: https://api.flutter.dev/flutter/widgets/State/dispose.html
    PreferencesService.setRestoreOrgOnLaunch(false);
    super.dispose();
  }

  void _deleteEvent(String id) {
    // showDialog - displays a Material dialog above the current screen
    // Tutorial: https://www.geeksforgeeks.org/flutter-alertdialog-widget/
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().deleteOpportunity(id);
              Navigator.pop(context);
            },
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
        // RoundedRectangleBorder - gives the dialog rounded corners
        // Source: https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html
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
              // Navigator.popUntil - pops routes until the predicate is true
              // r.isFirst checks if we've reached the bottom of the navigation stack
              // Source: https://api.flutter.dev/flutter/widgets/NavigatorState/popUntil.html
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            // ElevatedButton.styleFrom - customises button appearance inline
            // Source: https://api.flutter.dev/flutter/material/ElevatedButton/styleFrom.html
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
    // showModalBottomSheet - slides a panel up from the bottom of the screen
    // Tutorial: https://www.geeksforgeeks.org/flutter-modalBottomSheet/
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows the sheet to take up more than half the screen
      backgroundColor: Colors.transparent, // lets the sheet's own Container handle styling
      builder: (_) => _AddEventSheet(
        onSubmit: (event) async {
          final authService = AuthService();
          final user = authService.currentUser;
          if (user == null) return;

          final orgName = await authService.getCurrentOrgName();
          if (orgName == null) {
            if (!context.mounted) return;
            // ScaffoldMessenger.showSnackBar - displays a brief message at the bottom
            // Tutorial: https://www.geeksforgeeks.org/flutter-snackbar-widget/
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not load organization profile name.'),
              ),
            );
            return;
          }

          await DatabaseService().createOpportunity(
            title: event['title'] as String,
            orgName: orgName,
            location: event['location'] as String,
            date: event['date'] as String,
            link: event['link'] as String,
            description: event['description'] as String,
            category: event['category'] as String,
            type: event['type'] as String,
            ageMin: event['ageMin'] as int,
            ageMax: event['ageMax'] as int,
            orgId: user.uid,
          );
        },
      ),
    );
  }

  void _openEditEventSheet(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(
        existingEvent: event, // passing existing data pre-fills the form fields
        onSubmit: (updatedEvent) async {
          await DatabaseService().updateOpportunity(
            event['id'] as String,
            updatedEvent,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgId = AuthService().currentUser?.uid;

    if (orgId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          // IconButton - a tappable icon that triggers an action
          // Source: https://api.flutter.dev/flutter/material/IconButton-class.html
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => _confirmSignOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      // FloatingActionButton.extended - FAB with both an icon and a text label
      // Tutorial: https://www.geeksforgeeks.org/flutter-floating-action-button/
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
      // StreamBuilder - rebuilds whenever new data arrives from a Stream
      // Tutorial: https://www.geeksforgeeks.org/flutter-streambuilder-widget/
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService().getOrgOpportunities(orgId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;

          if (events.isEmpty) {
            return const Center(
              child: Text(
                'No events yet. Tap + Add Event to get started.',
                style: TextStyle(color: AppColors.subtle, fontSize: 16),
              ),
            );
          }

          // ListView.builder - efficiently builds list items on demand
          // Tutorial: https://www.geeksforgeeks.org/flutter-listview-builder/
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return _OrgEventCard(
                event: event,
                onEdit: () => _openEditEventSheet(event),
                onDelete: () => _deleteEvent(event['id']),
              );
            },
          );
        },
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

  // getter that returns a color based on the event's status string
  // Source: https://dart.dev/language/functions#getters-and-setters
  Color get _statusColor {
    // switch statement - selects a branch based on the value of a variable
    // Source: https://dart.dev/language/branches#switch-statements
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

    // Container with BoxDecoration - used to add rounded corners and a drop shadow
    // Tutorial: https://www.geeksforgeeks.org/flutter-container-widget/
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        // BoxShadow - adds a subtle shadow beneath the card
        // Source: https://api.flutter.dev/flutter/painting/BoxShadow-class.html
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
              _StatusChip(label: event['status'], color: _statusColor),
              const SizedBox(width: 8),
              _StatusChip(
                  label: event['category'],
                  color: const Color(0xFF00BFA5)),
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
            '${event['type']} • ${event['date']}',
            style: const TextStyle(fontSize: 13, color: AppColors.subtle),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$websiteVisits website visits',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtle,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // TextButton.icon - text button with a leading icon
              // Source: https://api.flutter.dev/flutter/material/TextButton-class.html
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
    // withValues(alpha:) - creates a copy of the color with adjusted opacity
    // Source: https://api.flutter.dev/flutter/dart-ui/Color/withValues.html
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

// Bottom sheet used for both creating and editing events.
// Reusing one widget for both modes keeps logic in one place (DRY principle)
// Source: https://dart.dev/effective-dart/design
class _AddEventSheet extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;
  final Future<void> Function(Map<String, dynamic>) onSubmit;

  const _AddEventSheet({this.existingEvent, required this.onSubmit});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  // GlobalKey<FormState> - uniquely identifies the Form and lets us call validate()
  // Tutorial: https://www.geeksforgeeks.org/flutter-forms/
  final _formKey = GlobalKey<FormState>();

  // TextEditingController - reads and writes text in a TextFormField
  // Tutorial: https://www.geeksforgeeks.org/flutter-textfield-widget/
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
  final List<String> _types = ['Event', 'Club', 'Volunteering'];
  final List<String> _statuses = ['Upcoming', 'Draft', 'Past'];

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing an existing event
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
    // Controllers must be disposed to free memory when the widget is removed
    // Source: https://api.flutter.dev/flutter/widgets/TextEditingController/dispose.html
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _capacityController.dispose();
    _linkController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() async {
    // _formKey.currentState!.validate() - runs all validator functions in the Form
    // Source: https://api.flutter.dev/flutter/widgets/FormState/validate.html
    if (!_formKey.currentState!.validate()) return;

    await widget.onSubmit({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'date': _dateController.text,
      'link': _linkController.text,
      'category': _category,
      'type': _type,
      'status': _status,
      'ageMin': _ageMin,
      'ageMax': _ageMax,
      'cost': _costController.text,
      // int.tryParse - converts a String to int, returns null if it fails
      // Source: https://api.dart.dev/dart-core/int/tryParse.html
      'capacity': int.tryParse(_capacityController.text) ?? 0,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEvent != null;

    // DraggableScrollableSheet - a bottom sheet the user can drag to resize
    // Tutorial: https://www.geeksforgeeks.org/draggablescrollablesheet-in-flutter/
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            // BorderRadius.vertical - rounds only the top corners of the sheet
            // Source: https://api.flutter.dev/flutter/painting/BorderRadius/BorderRadius.vertical.html
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // drag handle indicator bar
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
                // SingleChildScrollView - makes content scrollable when it overflows
                // Source: https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  // Form - groups TextFormFields and manages validation together
                  // Tutorial: https://docs.flutter.dev/cookbook/forms/validation
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
                        // DropdownButtonFormField - a dropdown that integrates with Form validation
                        // Tutorial: https://www.geeksforgeeks.org/dropdownbuttonformfield-in-flutter/
                        _DropdownField(
                          label: 'Category',
                          value: _category,
                          items: _categories,
                          onChanged: (val) => setState(() => _category = val!),
                        ),
                        _DropdownField(
                          label: 'Type',
                          value: _type,
                          items: _types,
                          onChanged: (val) => setState(() => _type = val!),
                        ),
                        _DropdownField(
                          label: 'Status',
                          value: _status,
                          items: _statuses,
                          onChanged: (val) => setState(() => _status = val!),
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
                        const SizedBox(height: 8),
                        const Text(
                          'Age Range',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.title),
                        ),
                        const SizedBox(height: 8),
                        // Slider - lets the user pick a value by dragging
                        // Tutorial: https://www.geeksforgeeks.org/flutter-slider-widget/
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
                                    onChanged: (val) =>
                                        setState(() => _ageMin = val.round()),
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
                                    onChanged: (val) =>
                                        setState(() => _ageMax = val.round()),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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

// TextFormField wrapped in a reusable widget to keep the form code tidy
// Tutorial: https://docs.flutter.dev/cookbook/forms/validation
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
        // InputDecoration - controls the label, hint, fill colour, and border style
        // Source: https://api.flutter.dev/flutter/material/InputDecoration-class.html
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.subtle, fontSize: 13),
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

// DropdownButtonFormField wrapped in a reusable widget
// Tutorial: https://www.geeksforgeeks.org/dropdownbuttonformfield-in-flutter/
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
        // .map().toList() converts each string into a DropdownMenuItem
        // Source: https://dart.dev/libraries/dart-core#lists
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}