
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/home/presentation/widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.bookmark,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PPLAN',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '다음 여행을 위한 멋진 장소를 발견해보세요',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 24),
          const PostCard(),
          const PostCard(),
          const PostCard(),
        ],
      ),
    );
  }
}
