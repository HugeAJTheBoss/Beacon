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
  static const double _pagePadding = AppSpacing.lg;
  static const double _sectionSpacing = AppSpacing.md;
  static const double _cardRadius = AppRadii.panel;
  static const double _cardShadowAlpha = 0.04;
  static const double _cardShadowBlur = 6;
  static const Duration _microDuration = Duration(milliseconds: 170);

  static const List<String> _statusFilters = [
    'All',
    'Upcoming',
    'Draft',
    'Past',
  ];

  String _activeStatusFilter = 'All';

  // getter that returns a color based on the event's status string
  // Source: https://dart.dev/language/functions#getters-and-setters
  Color _statusColorForFilter(String status) {
    // switch statement - selects a branch based on the value of a variable
    // Source: https://dart.dev/language/branches#switch-statements
    switch (status) {
      case 'Upcoming':
        return AppColors.primary;
      case 'Draft':
        return AppColors.warning;
      case 'Past':
        return AppColors.subtle;
      default:
        return AppColors.primary;
    }
  }

  void _deleteEvent(Map<String, dynamic> eventData) {
    // showDialog - displays a Material dialog above the current screen
    // Tutorial: https://www.geeksforgeeks.org/flutter-alertdialog-widget/
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // RoundedRectangleBorder - gives the dialog rounded corners
        // Source: https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: const Text(
          'Delete Event?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.title),
        ),
        content: Text(
          'Are you sure you want to delete "${eventData['title']}"? This cannot be undone.',
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
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService().deleteOpportunity(eventData['id'] as String);
            },
            // ElevatedButton.styleFrom - customises button appearance inline
            // Source: https://api.flutter.dev/flutter/material/ElevatedButton/styleFrom.html
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
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
        onSubmit: (eventData) async {
          final authService = AuthService();
          final user = authService.currentUser;
          if (user == null) return;
          final orgName = await authService.getCurrentOrgName();
          if (orgName == null) {
            if (!mounted) return;
            // ScaffoldMessenger.showSnackBar - displays a brief message at the bottom
            // Tutorial: https://www.geeksforgeeks.org/flutter-snackbar-widget/
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not load organization name.')),
            );
            return;
          }
          await DatabaseService().createOpportunity(
            title: eventData['title'] as String,
            orgName: orgName,
            location: eventData['location'] as String,
            date: eventData['date'] as String,
            link: eventData['link'] as String,
            description: eventData['description'] as String,
            category: eventData['category'] as String,
            type: eventData['type'] as String,
            ageMin: eventData['ageMin'] as int,
            ageMax: eventData['ageMax'] as int,
            orgId: user.uid,
          );
        },
      ),
    );
  }

  void _openEditEventSheet(Map<String, dynamic> eventData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(
        existingEvent: eventData, // passing existing data pre-fills the form fields
        onSubmit: (updatedEventData) async {
          await DatabaseService().updateOpportunity(
            eventData['id'] as String,
            updatedEventData,
          );
        },
      ),
    );
  }

  // FloatingActionButton.extended - FAB with both an icon and a text label
  // Tutorial: https://www.geeksforgeeks.org/flutter-floating-action-button/
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _openAddEventSheet,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text(
        'Add Event',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }


  Widget _buildStatusFilterChips() {
    return SizedBox(
      height: 34,
      // ListView.separated - efficient horizontal list with separators between items
      // Source: https://api.flutter.dev/flutter/widgets/ListView/ListView.separated.html
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = status == _activeStatusFilter;
          final statusColor = _statusColorForFilter(status);

          // AnimatedScale - smoothly scales its child between values
          // Source: https://api.flutter.dev/flutter/widgets/AnimatedScale-class.html
          return AnimatedScale(
            scale: isSelected ? 1 : 0.97,
            duration: _microDuration,
            curve: Curves.easeOutCubic,
            // ChoiceChip - chip widget that holds a single boolean selected state
            // Tutorial: https://www.geeksforgeeks.org/chip-widgets-in-flutter/
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _activeStatusFilter = status);
              },
              backgroundColor: AppColors.card,
              selectedColor: statusColor.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected ? statusColor : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: isSelected ? statusColor : AppColors.title,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContentSection(List<Map<String, dynamic>> allEvents) {
    final visibleEvents = _activeStatusFilter == 'All'
        ? allEvents
        : allEvents.where((e) => e['status'] == _activeStatusFilter).toList();

    if (allEvents.isEmpty) {
      return const _DashboardEmptyState(
        title: 'No events yet',
        message: 'Tap + Add Event to publish your first listing.',
      );
    }

    if (visibleEvents.isEmpty) {
      return _DashboardEmptyState(
        title: 'No $_activeStatusFilter events',
        message: 'Try another status or show all events to continue.',
        actionLabel: 'Show all',
        onActionPressed: () {
          setState(() => _activeStatusFilter = 'All');
        },
      );
    }

    // ListView.builder - efficiently builds list items on demand
    // Tutorial: https://www.geeksforgeeks.org/flutter-listview-builder/
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        _pagePadding,
        0,
        _pagePadding,
        84 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: visibleEvents.length,
      itemBuilder: (context, index) {
        final eventData = visibleEvents[index];
        return _OrgEventCard(
          eventData: eventData,
          onEdit: () => _openEditEventSheet(eventData),
          onDelete: () => _deleteEvent(eventData),
        );
      },
    );
  }

  Widget _buildMetricsSectionWithData({
    required int total,
    required int upcoming,
    required int draft,
  }) {
    // LayoutBuilder - rebuilds based on the parent's constraints (used for responsive layouts)
    // Source: https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          final compactCardWidth = (constraints.maxWidth - 8) / 2;
          // Wrap - flowing layout that wraps to next line when out of space
          // Source: https://api.flutter.dev/flutter/widgets/Wrap-class.html
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(width: compactCardWidth, child: _MetricCard(label: 'Total Events', value: '$total')),
              SizedBox(width: compactCardWidth, child: _MetricCard(label: 'Upcoming', value: '$upcoming')),
              SizedBox(width: compactCardWidth, child: _MetricCard(label: 'Draft', value: '$draft')),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _MetricCard(label: 'Total Events', value: '$total')),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(label: 'Upcoming', value: '$upcoming')),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(label: 'Draft', value: '$draft')),
          ],
        );
      },
    );
  }

  Widget _buildDashboardHeaderSectionWithData({
    required int total,
    required int upcoming,
    required int draft,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_pagePadding, _sectionSpacing, _pagePadding, 8),
      // Container with BoxDecoration - used to add rounded corners and a drop shadow
      // Tutorial: https://www.geeksforgeeks.org/flutter-container-widget/
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.border),
          // BoxShadow - adds a subtle shadow beneath the card
          // Source: https://api.flutter.dev/flutter/painting/BoxShadow-class.html
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: _cardShadowAlpha),
              blurRadius: _cardShadowBlur,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMetricsSectionWithData(total: total, upcoming: upcoming, draft: draft),
            const SizedBox(height: _sectionSpacing),
            _buildStatusFilterChips(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgId = AuthService().currentUser?.uid;
    if (orgId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Scaffold - provides the basic Material Design page structure (appbar, body, etc.)
    // Tutorial: https://www.geeksforgeeks.org/flutter-scaffold-widget/
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.ink,
        automaticallyImplyLeading: false,
        // IconButton - a tappable icon that triggers an action
        // Source: https://api.flutter.dev/flutter/material/IconButton-class.html
        leading: IconButton(
          icon: const Icon(Icons.logout, size: 20),
          onPressed: () => _confirmSignOut(context),
          tooltip: 'Sign Out',
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: _buildFab(),
      // StreamBuilder - rebuilds whenever new data arrives from a Stream
      // Tutorial: https://www.geeksforgeeks.org/flutter-streambuilder-widget/
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService().getOrgOpportunities(orgId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allEvents = snapshot.data!;
          final total = allEvents.length;
          final upcoming = allEvents.where((e) => e['status'] == 'Upcoming').length;
          final draft = allEvents.where((e) => e['status'] == 'Draft').length;
          final visibleCount = _activeStatusFilter == 'All'
              ? total
              : allEvents.where((e) => e['status'] == _activeStatusFilter).length;

          return Column(
            children: [
              _buildDashboardHeaderSectionWithData(total: total, upcoming: upcoming, draft: draft),
              Expanded(
                // AnimatedSwitcher - smoothly transitions between widgets when its child changes
                // Source: https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html
                child: AnimatedSwitcher(
                  duration: _microDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOut,
                  child: KeyedSubtree(
                    key: ValueKey(
                      'dashboard_content:$_activeStatusFilter:$total:$visibleCount',
                    ),
                    child: _buildDashboardContentSection(allEvents),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtle,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.title,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _DashboardEmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtle, fontSize: 14),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 14),
              // OutlinedButton - border-only button used for secondary actions
              // Source: https://api.flutter.dev/flutter/material/OutlinedButton-class.html
              OutlinedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrgEventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrgEventCard({
    required this.eventData,
    required this.onEdit,
    required this.onDelete,
  });

  // getter that returns a color based on the event's status string
  // Source: https://dart.dev/language/functions#getters-and-setters
  Color get _statusColor {
    // switch statement - selects a branch based on the value of a variable
    // Source: https://dart.dev/language/branches#switch-statements
    switch (eventData['status']) {
      case 'Upcoming':
        return AppColors.primary;
      case 'Past':
        return AppColors.subtle;
      case 'Draft':
        return AppColors.warning;
      default:
        return AppColors.subtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventType = (eventData['type'] as String?) ?? 'Event';
    final eventDate = (eventData['date'] as String?) ?? 'Date TBD';
    final eventLocation =
        (eventData['location'] as String?)?.trim().isNotEmpty == true
        ? eventData['location'] as String
        : 'Location not set';

    // Container with BoxDecoration - rounded corners and a soft drop shadow
    // Tutorial: https://www.geeksforgeeks.org/flutter-container-widget/
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.border),
        // BoxShadow - adds a subtle shadow beneath the card
        // Source: https://api.flutter.dev/flutter/painting/BoxShadow-class.html
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 6,
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
              _StatusChip(label: eventData['status'], color: _statusColor),
              const SizedBox(width: 6),
              _StatusChip(
                label: eventData['category'],
                color: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // title
          Text(
            eventData['title'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                child: Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eventType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.subtle),
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eventDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.subtle),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                child: Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eventLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.subtle),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // edit + delete buttons
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
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
  final ValueChanged<Map<String, dynamic>> onSubmit;

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
  String _optionalImagePath = '';

  final List<String> _categories = [
    'Robotics',
    'Biology',
    'Math',
    'Computer Science',
    'Engineering',
    'Physics',
  ];
  final List<String> _types = ['Event', 'Club', 'Volunteering'];
  final List<String> _statuses = ['Upcoming', 'Draft', 'Past'];

  @override
  void initState() {
    // initState - called once when the widget is inserted into the tree
    // Tutorial: https://www.geeksforgeeks.org/flutter-initstate/
    super.initState();
    final existingEventData = widget.existingEvent;
    if (existingEventData != null) {
      _populateFromExistingEvent(existingEventData);
    }
  }

  // Pre-fill fields when editing an existing event
  void _populateFromExistingEvent(Map<String, dynamic> existingEventData) {
    _titleController.text = existingEventData['title'] ?? '';
    _descriptionController.text = existingEventData['description'] ?? '';
    _locationController.text = existingEventData['location'] ?? '';
    _costController.text = existingEventData['cost'] ?? '';
    _capacityController.text = existingEventData['capacity']?.toString() ?? '';
    _linkController.text = existingEventData['link'] ?? '';
    _dateController.text = existingEventData['date'] ?? '';
    _category = existingEventData['category'] ?? 'Robotics';
    _type = existingEventData['type'] ?? 'Event';
    _status = existingEventData['status'] ?? 'Upcoming';
    _ageMin = existingEventData['ageMin'] ?? 10;
    _ageMax = existingEventData['ageMax'] ?? 24;
    _optionalImagePath = existingEventData['imageUrl'] ?? '';
  }

  void _handleOptionalImageTap() {
    // image upload needs to be implemented.
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

  void _submitEventForm() {
    // _formKey.currentState!.validate() - runs all validator functions in the Form
    // Source: https://api.flutter.dev/flutter/widgets/FormState/validate.html
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _category,
      'type': _type,
      'date': _dateController.text.trim(),
      'location': _locationController.text.trim(),
      'ageMin': _ageMin,
      'ageMax': _ageMax,
      'cost': _costController.text.trim(),
      // int.tryParse - converts a String to int, returns null if it fails
      // Source: https://api.dart.dev/dart-core/int/tryParse.html
      'capacity': int.tryParse(_capacityController.text.trim()) ?? 0,
      'link': _linkController.text.trim(),
      'imageUrl': _optionalImagePath,
      'status': _status,
    });
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
            color: AppColors.card,
            // BorderRadius.vertical - rounds only the top corners of the sheet
            // Source: https://api.flutter.dev/flutter/painting/BorderRadius/BorderRadius.vertical.html
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
          ),
          child: Column(
            children: [
              // drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadii.xs),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _FormSectionHeader('Event Details'),
                        _SheetField(
                          controller: _titleController,
                          label: 'Event Title *',
                          hint: 'e.g. Summer Robotics Camp',
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Title is required'
                              : null,
                        ),

                        _SheetField(
                          controller: _descriptionController,
                          label: 'Description *',
                          hint: 'What is this event about?',
                          maxLines: 3,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Description is required'
                              : null,
                        ),

                        const _FormSectionHeader('Classification'),
                        // DropdownButtonFormField - a dropdown that integrates with Form validation
                        // Tutorial: https://www.geeksforgeeks.org/dropdownbuttonformfield-in-flutter/
                        _DropdownField(
                          label: 'Category *',
                          value: _category,
                          items: _categories,
                          onChanged: (value) =>
                              setState(() => _category = value!),
                        ),

                        _DropdownField(
                          label: 'Type *',
                          value: _type,
                          items: _types,
                          onChanged: (value) => setState(() => _type = value!),
                        ),

                        _DropdownField(
                          label: 'Status *',
                          value: _status,
                          items: _statuses,
                          onChanged: (value) =>
                              setState(() => _status = value!),
                        ),

                        const _FormSectionHeader('Logistics'),

                        _SheetField(
                          controller: _dateController,
                          label: 'Date *',
                          hint: 'e.g. June 14, 2026 or Every Tuesday',
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Date is required'
                              : null,
                        ),

                        _SheetField(
                          controller: _locationController,
                          label: 'Location / Address *',
                          hint: 'e.g. 100 Institute Rd, Worcester',
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Location is required'
                              : null,
                        ),

                        // age range row
                        const SizedBox(height: 8),
                        const Text(
                          'Age Range',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Allowed range: 5-24 years',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtle,
                          ),
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
                                  Text(
                                    'Min: $_ageMin',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Slider(
                                    value: _ageMin.toDouble(),
                                    min: 5,
                                    max: 24,
                                    divisions: 19,
                                    activeColor: AppColors.primary,
                                    onChanged: (value) =>
                                        setState(() => _ageMin = value.round()),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Max: $_ageMax',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Slider(
                                    value: _ageMax.toDouble(),
                                    min: 5,
                                    max: 24,
                                    divisions: 19,
                                    activeColor: AppColors.primary,
                                    onChanged: (value) =>
                                        setState(() => _ageMax = value.round()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const _FormSectionHeader('Listing Details'),

                        _SheetField(
                          controller: _costController,
                          label: 'Cost *',
                          hint: 'e.g. Free, \$50, Varies',
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Cost is required'
                              : null,
                        ),

                        _SheetField(
                          controller: _linkController,
                          label: 'Organization Website Link *',
                          hint: 'https://',
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            final trimmedValue = value?.trim() ?? '';
                            if (trimmedValue.isEmpty) return 'Link is required';

                            final normalizedValue =
                                trimmedValue.startsWith('http://') ||
                                    trimmedValue.startsWith('https://')
                                ? trimmedValue
                                : 'https://$trimmedValue';
                            final uri = Uri.tryParse(normalizedValue);
                            if (uri == null || uri.host.isEmpty) {
                              return 'Enter a valid website link';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          'Optional Image',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // OutlinedButton.icon - outlined button with a leading icon
                        // Tutorial: https://www.geeksforgeeks.org/flutter-outlinedbutton-widget/
                        OutlinedButton.icon(
                          onPressed: _handleOptionalImageTap,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            _optionalImagePath.isEmpty
                                ? 'Add Optional Image'
                                : 'Image Added',
                          ),
                        ),
                        const SizedBox(height: 6),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: _submitEventForm,
                          child: Text(
                            isEditing ? 'Save Changes' : 'Submit Event',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

class _FormSectionHeader extends StatelessWidget {
  final String title;

  const _FormSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.title,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
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
    final resolvedKeyboardType = maxLines > 1
        ? TextInputType.multiline
        : keyboardType;
    final resolvedTextInputAction = maxLines > 1
        ? TextInputAction.newline
        : TextInputAction.next;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // InputDecoration - controls the label, hint, fill colour, and border style
      // Source: https://api.flutter.dev/flutter/material/InputDecoration-class.html
      child: TextFormField(
        controller: controller,
        keyboardType: resolvedKeyboardType,
        maxLines: maxLines,
        textInputAction: resolvedTextInputAction,
        decoration: InputDecoration(labelText: label, hintText: hint),
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
        isDense: false,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        ),
        // .map().toList() converts each string into a DropdownMenuItem
        // Source: https://dart.dev/libraries/dart-core#lists
        items: items
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
