import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';
import 'link_opener_stub.dart' if (dart.library.html) 'link_opener_web.dart';
import 'app_theme.dart';
import 'preferences_service.dart';
import 'services/database_service.dart';

const double _browseDesktopBreakpoint = 1080;
const double _browseTabletBreakpoint = 760;
const String _eventPlaceholderImageAsset = AppAssets.stemLogoPlaceholder;


Color _typeAccentColor(String type) {
  switch (type) {
    case 'Club':
      return const Color(0xFF2563EB);
    case 'Volunteering':
      return const Color(0xFF9D4EDD);
    case 'Event':
    default:
      return const Color(0xFFD97706);
  }
}

Color _typeTintColor(String type) {
  return _typeAccentColor(type).withValues(alpha: 0.12);
}

String _defaultImageForType(String type) {
  // Keep the hook for type-specific assets while using one shared placeholder.
  return _eventPlaceholderImageAsset;
}

String _resolveEventImageAsset(Map<String, dynamic> eventData) {
  final imageAsset = (eventData['imageAsset'] as String?)?.trim();
  if (imageAsset != null && imageAsset.isNotEmpty) {
    return imageAsset;
  }

  final type = (eventData['type'] as String?) ?? 'Event';
  return _defaultImageForType(type);
}

Future<void> _openOrganizationWebsiteLink({
  required BuildContext context,
  required String websiteLink,
}) async {
  if (websiteLink.isEmpty) return;

  final normalizedLink =
      websiteLink.startsWith('http://') || websiteLink.startsWith('https://')
      ? websiteLink
      : 'https://$websiteLink';
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
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } on MissingPluginException {
      opened = await openInBrowserTab(normalizedLink);
    }
  }

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open website link on this device.'),
      ),
    );
  }
}

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
  final ScrollController _browseScrollController = ScrollController();


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


  List<Map<String, dynamic>> _filterEvents(List<Map<String, dynamic>> all) {
    return all.where((event) {
      if (_age < (event['ageMin'] as num? ?? 0) || _age > (event['ageMax'] as num? ?? 99)) return false;
      if (_types[event['type']] == false) return false;
      if (_categories[event['category']] == false) return false;
      return true;
    }).toList();
  }






  String _formatUsDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }



  @override
  void dispose() {
    _browseScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final savedPreferences = await PreferencesService.getAll();
      if (savedPreferences['setupDone'] == true) {
        setState(() {
          _age = savedPreferences['age'];
          _distance = savedPreferences['distance'];
          _zip = savedPreferences['zip'];
          _dob = savedPreferences['dob'];
          final savedTypes = savedPreferences['types'] as Map<String, bool>;
          final savedCategories =
              savedPreferences['categories'] as Map<String, bool>;
          _types.updateAll((key, _) => savedTypes[key] ?? true);
          _categories.updateAll((key, _) => savedCategories[key] ?? true);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        if (mounted) {
          // Show onboarding setup after first frame so Scaffold context is ready.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showWelcomePopup();
          });
        }
      }
    } catch (error) {
      debugPrint('Error loading preferences: $error');
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
    DateTime? draftBirthDate;
    final zipController = TextEditingController();
    final draftOpportunityTypes = Map<String, bool>.from(_types);
    final draftCategories = Map<String, bool>.from(_categories);

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
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadii.xl),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadii.xs),
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

                          // --- Date of Birth ---
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
                                initialDate:
                                    draftBirthDate ?? DateTime(2010, 1, 1),
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now(),
                                helpText: 'Select date of birth',
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                builder: (context, child) {
                                  final baseTheme = Theme.of(context);
                                  final screenWidth = MediaQuery.sizeOf(
                                    context,
                                  ).width;
                                  final dialogWidth = (screenWidth - 16)
                                      .clamp(320.0, 460.0)
                                      .toDouble();
                                  return Theme(
                                    data: baseTheme.copyWith(
                                      colorScheme: baseTheme.colorScheme
                                          .copyWith(
                                            primary: AppColors.title,
                                            onPrimary: AppColors.onPrimary,
                                            surface: AppColors.card,
                                            onSurface: AppColors.title,
                                          ),
                                      datePickerTheme: DatePickerThemeData(
                                        backgroundColor: AppColors.card,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.lg,
                                          ),
                                        ),
                                        headerBackgroundColor: AppColors.card,
                                        headerForegroundColor: AppColors.title,
                                        headerHelpStyle: const TextStyle(
                                          color: AppColors.subtle,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        weekdayStyle: const TextStyle(
                                          color: AppColors.subtle,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        dayStyle: const TextStyle(
                                          color: AppColors.title,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        dayForegroundColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return AppColors.onPrimary;
                                              }
                                              return AppColors.title;
                                            }),
                                        dayBackgroundColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return AppColors.title;
                                              }
                                              return Colors.transparent;
                                            }),
                                        todayBorder: BorderSide(
                                          color: AppColors.border,
                                        ),
                                        todayForegroundColor:
                                            const WidgetStatePropertyAll(
                                              AppColors.title,
                                            ),
                                        dividerColor: AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: dialogWidth,
                                          maxWidth: dialogWidth,
                                        ),
                                        child: child ?? const SizedBox.shrink(),
                                      ),
                                    ),
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() => draftBirthDate = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.cake_outlined,
                                    color: AppColors.subtle,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      draftBirthDate != null
                                          ? _formatUsDate(draftBirthDate!)
                                          : 'Tap to select your birthday',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: draftBirthDate != null
                                            ? AppColors.title
                                            : AppColors.subtle,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Zip Code ---
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

                          // --- Interests ---
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
                            children: draftCategories.keys.map((category) {
                              final isSelected = draftCategories[category]!;
                              return FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.title,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                onSelected: (isNowSelected) => setModalState(
                                  () =>
                                      draftCategories[category] = isNowSelected,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // --- Types ---
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
                            children: draftOpportunityTypes.keys.map((type) {
                              final isSelected = draftOpportunityTypes[type]!;
                              return FilterChip(
                                label: Text(type),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.title,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                onSelected: (isNowSelected) => setModalState(
                                  () => draftOpportunityTypes[type] =
                                      isNowSelected,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // --- Get Started button ---
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (draftBirthDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select your date of birth.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (zipController.text.trim().length < 5) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid 5-digit zip code.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (!draftOpportunityTypes.values.any(
                                    (value) => value,
                                  ) ||
                                  !draftCategories.values.any(
                                    (value) => value,
                                  )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Select at least one interest and one type.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              // Calculate age from DOB
                              final now = DateTime.now();
                              double calculatedAge =
                                  (now.year - draftBirthDate!.year).toDouble();
                              if (now.month < draftBirthDate!.month ||
                                  (now.month == draftBirthDate!.month &&
                                      now.day < draftBirthDate!.day)) {
                                calculatedAge -= 1;
                              }

                              setState(() {
                                _dob = draftBirthDate;
                                _zip = zipController.text.trim();
                                _age = calculatedAge.clamp(5, 24);
                                _types.updateAll(
                                  (key, _) =>
                                      draftOpportunityTypes[key] ?? true,
                                );
                                _categories.updateAll(
                                  (key, _) => draftCategories[key] ?? true,
                                );
                              });

                              _saveFilters();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  void _showReportDialog(Map<String, dynamic> eventData) {
    String? selectedReportReason;
    final TextEditingController reportDetailsController =
        TextEditingController();

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
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
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
                        eventData['title'],
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
                        children:
                            [
                                  'Incorrect information',
                                  'Spam or scam',
                                  'Inappropriate content',
                                  'Duplicate listing',
                                  'Other',
                                ]
                                .map(
                                  (reason) => ChoiceChip(
                                    label: Text(reason),
                                    selected: selectedReportReason == reason,
                                    selectedColor: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    labelStyle: TextStyle(
                                      color: selectedReportReason == reason
                                          ? AppColors.primary
                                          : AppColors.title,
                                      fontWeight: selectedReportReason == reason
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    onSelected: (_) {
                                      setModalState(
                                        () => selectedReportReason = reason,
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reportDetailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add details (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedReportReason == null
                              ? null
                              : () {
                                  // TODO: send report to backend / Firestore
                                  // Example payload:
                                  // {
                                  //   'eventTitle': eventData['title'],
                                  //   'reason': selectedReportReason,
                                  //   'details': reportDetailsController.text.trim(),
                                  //   'reportedAt': DateTime.now().toIso8601String(),
                                  // }

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Report submitted for "${eventData['title']}"',
                                      ),
                                    ),
                                  );
                                },
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

  void _showEventDetails(Map<String, dynamic> eventData) {
    final organizationWebsite = (eventData['link'] as String?)?.trim() ?? '';
    final eventDescription =
        (eventData['description'] as String?)?.trim().isNotEmpty == true
        ? eventData['description'] as String
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
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    eventData['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    eventData['org'],
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Chip(
                        label: eventData['category'],
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label: eventData['type'],
                        color: _typeAccentColor(eventData['type']),
                        isTypeLabel: true,
                      ),
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
                    eventDescription,
                    style: const TextStyle(
                      color: AppColors.subtle,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.subtle,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        eventData['date'],
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.subtle,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        eventData['distance'] != null
                            ? '${eventData['location']} • ${(eventData['distance'] as num).round()} mi'
                            : '${eventData['location']}',
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 16,
                        color: AppColors.subtle,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ages ${eventData['ageMin']} - ${eventData['ageMax']}',
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.language_outlined,
                        size: 16,
                        color: AppColors.subtle,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: organizationWebsite.isEmpty
                                ? null
                                : () => _openOrganizationWebsiteLink(
                                    context: context,
                                    websiteLink: organizationWebsite,
                                  ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                            ),
                            icon: const Icon(Icons.open_in_new, size: 14),
                            label: Text(
                              organizationWebsite.isEmpty
                                  ? 'No organization website provided'
                                  : 'Visit organization website',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
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

  int _gridColumnsForWidth(double width) {
    if (width >= _browseDesktopBreakpoint) return 3;
    if (width >= _browseTabletBreakpoint) return 2;
    return 1;
  }

  double _gridCardHeightForWidth(double width) {
    return (width * 0.58).clamp(340.0, 376.0);
  }

  Widget _buildBrowseOverview(bool isDesktop, List<Map<String, dynamic>> filteredEvents) {
    final heading = Text(
      'Discover STEM\nopportunities near you',
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontSize: isDesktop ? 44 : 34),
    );

    final description = Text(
      'Navigate opportunities and events near you by scrolling the list, refining filters, and opening each card for details.',
      style: TextStyle(
        color: AppColors.subtle,
        fontSize: isDesktop ? 18 : 16,
        height: 1.45,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: 16),
        description,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.ink,
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
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
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
                          activeColor: AppColors.title,
                          inactiveColor: AppColors.border,
                          onChanged: (value) {
                            setState(() => _distance = value);
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
                          activeColor: AppColors.title,
                          inactiveColor: AppColors.border,
                          onChanged: (value) => setState(() => _age = value),
                        ),
                        const SizedBox(height: 8),
                        const _SectionTitle(title: 'Type'),
                        const SizedBox(height: 4),
                        ..._types.keys.map(
                          (type) => CheckboxListTile(
                            title: Text(type),
                            value: _types[type],
                            activeColor: AppColors.title,
                            checkColor: AppColors.onPrimary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (isChecked) =>
                                setState(() => _types[type] = isChecked!),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _SectionTitle(title: 'Category'),
                        const SizedBox(height: 4),
                        ..._categories.keys.map(
                          (cat) => CheckboxListTile(
                            title: Text(cat),
                            value: _categories[cat],
                            activeColor: AppColors.title,
                            checkColor: AppColors.onPrimary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (isChecked) =>
                                setState(() => _categories[cat] = isChecked!),
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
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isDesktop = width >= _browseDesktopBreakpoint;
                final columns = _gridColumnsForWidth(width);
                final cardHeight = _gridCardHeightForWidth(width);

                return SingleChildScrollView(
                  controller: _browseScrollController,
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 56 : 20,
                    24,
                    isDesktop ? 56 : 20,
                    28,
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: DatabaseService().getOpportunities(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final filteredEvents = _filterEvents(snapshot.data!);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrowseOverview(isDesktop, filteredEvents),
                          const SizedBox(height: 18),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Text(
                            'Browse local STEM events',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: isDesktop ? 34 : 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (filteredEvents.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No opportunities match your filters.',
                                  style: TextStyle(
                                    color: AppColors.subtle,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: cardHeight,
                                  ),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final eventData = filteredEvents[index];
                                return _EventCard(
                                  eventData: eventData,
                                  onViewDetails: () =>
                                      _showEventDetails(eventData),
                                  onReport: () => _showReportDialog(eventData),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
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
        Text(value, style: const TextStyle(color: AppColors.subtle)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onViewDetails;
  final VoidCallback onReport;

  const _EventCard({
    required this.eventData,
    required this.onViewDetails,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final type = (eventData['type'] as String?) ?? 'Event';
    final typeColor = _typeAccentColor(type);
    final typeTint = _typeTintColor(type);
    final organizationWebsite = (eventData['link'] as String?)?.trim() ?? '';
    final imageAsset = _resolveEventImageAsset(eventData);
    final imageUrl = (eventData['imageUrl'] as String?)?.trim();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadii.lg),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 7.5,
                      child: _EventImage(
                        imageAsset: imageAsset,
                        imageUrl: imageUrl,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Chip(
                      label: type,
                      color: typeColor,
                      isTypeLabel: true,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: IconButton(
                      onPressed: onReport,
                      icon: const Icon(
                        Icons.flag_outlined,
                        color: AppColors.onPrimary,
                        size: 18,
                      ),
                      splashRadius: 18,
                      tooltip: 'Report event',
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: typeTint,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: typeColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                eventData['distance'] != null
                                    ? '${eventData['location']} • ${(eventData['distance'] as num).round()} mi'
                                    : '${eventData['location']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eventData['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eventData['org'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.subtle,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.subtle,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              eventData['date'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subtle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Tap for details',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (organizationWebsite.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _openOrganizationWebsiteLink(
                                context: context,
                                websiteLink: organizationWebsite,
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.open_in_new, size: 13),
                              label: const Text(
                                'Website',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final String imageAsset;
  final String? imageUrl;

  const _EventImage({required this.imageAsset, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasNetworkImage) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Image.asset(imageAsset, fit: BoxFit.cover);
        },
      );
    }

    return Image.asset(imageAsset, fit: BoxFit.cover);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isTypeLabel;

  const _Chip({
    required this.label,
    required this.color,
    this.isTypeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTypeLabel
            ? AppColors.card
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: isTypeLabel
            ? Border.all(
                color: color.withValues(alpha: 0.55),
              )
            : null,
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
