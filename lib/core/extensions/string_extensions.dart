extension StringExtensions on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  String get categoryDisplayName {
    switch (toLowerCase()) {
      case 'recyclable':
        return 'Recyclable';
      case 'organic':
        return 'Organic';
      case 'e_waste':
      case 'ewaste':
        return 'E-Waste';
      case 'hazardous':
        return 'Hazardous';
      default:
        return titleCase;
    }
  }

  String get stateDisplayName {
    switch (toUpperCase()) {
      case 'SUBMITTED':
        return 'Submitted';
      case 'CLASSIFIED':
        return 'Classified';
      case 'VERIFIED':
        return 'Verified';
      case 'REWARDED':
        return 'Rewarded';
      case 'DISPUTED':
        return 'Disputed';
      case 'RESOLVED':
        return 'Resolved';
      case 'REJECTED':
        return 'Rejected';
      case 'FLAGGED_DUPLICATE':
        return 'Flagged Duplicate';
      default:
        return titleCase;
    }
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return regex.hasMatch(this);
  }

  bool get isValidUsername {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');
    return regex.hasMatch(this);
  }
}
