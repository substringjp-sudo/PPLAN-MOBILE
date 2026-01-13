
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary, // Or use a placeholder
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User Name',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                '1H AGO',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.moreHorizontal, size: 16, color: textTheme.bodySmall?.color),
            ],
          ),
          const SizedBox(height: 16),

          // Main Content with accent border
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Title',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.5), // Slightly larger for emphasis
                ),
                const SizedBox(height: 4),
                Text(
                  'This is the post description. It can have a maximum of two lines. It will truncate with an ellipsis if it is too long.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attached Map Link
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: const Center(
              child: Icon(LucideIcons.mapPin, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(height: 16),

          // Card Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.heart, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 6),
                  Text('12', style: textTheme.bodySmall),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Read Story', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
