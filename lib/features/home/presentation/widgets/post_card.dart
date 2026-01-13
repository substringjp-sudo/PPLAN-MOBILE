
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                // backgroundImage: NetworkImage('...'),
              ),
              const SizedBox(width: 12),
              const Text('User Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('1h ago'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.mutedText)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.moreHorizontal, size: 16, color: AppColors.mutedText),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
            ),
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Post Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 4),
                Text(
                  'This is the post description. It can have a maximum of two lines. This is the post description. It can have a maximum of two lines.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColors.mutedText.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: Icon(LucideIcons.mapPin, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.heart, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 4),
                  const Text('12', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
              const Row(
                children: [
                  Text('Read Story', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, color: AppColors.primary, size: 16),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
