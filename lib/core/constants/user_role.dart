/// Canonical user roles. Keep the wire values in sync with the `profiles.role`
/// column and any role checks in RLS / edge functions.
enum UserRole {
  citizen('citizen'),
  moderator('moderator'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? raw) {
    switch (raw) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }

  bool get canModerateDisputes =>
      this == UserRole.moderator || this == UserRole.admin;

  bool get isAdmin => this == UserRole.admin;
}
