
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: AppColors.primary), // Placeholder
              const SizedBox(width: 8),
              Text('Username', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('1h ago', style: textTheme.bodySmall?.copyWith(fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(width: 8),
              Icon(LucideIcons.ellipsis, size: 16, color: textTheme.bodySmall?.color),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text('Post Title', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'This is the post description. It can be a few lines long, but we will truncate it for this example.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),

          // Attached Link
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Google Maps Link to a Location',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              const Icon(LucideIcons.heart, size: 20, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text('12', style: textTheme.bodyMedium),
              const Spacer(),
              Text('Read Story', style: textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.primary),
            ],
          )
        ],
      ),
    );
  }
}
