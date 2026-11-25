import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Portfolio experience entry synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.id,
    this.category = 'full-time',
    this.organization = '',
    this.logoStaticPath = '',
    this.logoAlt = '',
    this.startYear,
    this.startMonth,
    this.endYear,
    this.endMonth,
    this.isCurrent,
    this.displayOrder = 0,
    this.starCount = 0,
    this.isStarred = false,
    this.logoUrl = '',
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Valid category keys paired with human-readable labels matching Django.
  static const Map<String, String> categoryLabels = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  @JsonKey(defaultValue: 'full-time')
  final String category;

  @JsonKey(defaultValue: '')
  final String organization;

  @JsonKey(defaultValue: '')
  final String logoStaticPath;

  @JsonKey(defaultValue: '')
  final String logoAlt;

  final int? startYear;
  final int? startMonth;
  final int? endYear;
  final int? endMonth;
  final bool? isCurrent;

  @JsonKey(defaultValue: 0)
  final int displayOrder;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String logoUrl;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);

  /// Human-readable category label.
  String get categoryLabel => categoryLabels[category] ?? category;

  /// Human-readable period string (e.g., `Jan 2025 - Present`).
  String get periodLabel {
    final start = _formatYearMonth(startYear, startMonth);
    final end = isCurrent == true
        ? 'Present'
        : _formatYearMonth(endYear, endMonth);
    if (start == null && end == null) {
      return 'Date not specified';
    }
    if (start != null && end != null) {
      return '$start - $end';
    }
    return start ?? end!;
  }

  /// Resolves [logoUrl] into a full URL when the backend returns a relative
  /// static path (e.g., `/static/images/logo.png`).
  String resolvedLogoUrl(String baseUrl) {
    final trimmed = logoUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$normalizedBase$normalizedPath';
  }

  static String? _formatYearMonth(int? year, int? month) {
    if (year == null) return null;
    if (month != null && month >= 1 && month <= 12) {
      return '${_monthNames[month - 1]} $year';
    }
    return '$year';
  }
}
