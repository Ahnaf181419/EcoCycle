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

  Widget _buildInitialLetter() {
    return Text(
      username.isNotEmpty ? username[0].toUpperCase() : '?',
      style: TextStyle(
        color: AppColors.primary,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
        child: photoUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: photoUrl!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SizedBox(
                    width: radius,
                    height: radius,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => _buildInitialLetter(),
                ),
              )
            : _buildInitialLetter(),
      ),
    );
  }
}
