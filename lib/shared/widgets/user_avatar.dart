import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String username;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.username,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
        backgroundImage: photoUrl != null
            ? CachedNetworkImageProvider(photoUrl!)
            : null,
        child: photoUrl == null
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }
}
