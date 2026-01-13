import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/features/scrapbook/presentation/providers/scrap_providers.dart';

class ScrapInboxScreen extends ConsumerWidget {
  const ScrapInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrapListAsync = ref.watch(scrapListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrap Inbox'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: scrapListAsync.when(
        data: (scraps) {
          if (scraps.isEmpty) {
            return const Center(
              child: Text(
                'Your inbox is empty.\nShare something to PPLAN!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scraps.length,
            itemBuilder: (context, index) {
              final scrap = scraps[index];
              return ScrapCard(scrap: scrap)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class ScrapCard extends StatelessWidget {
  final Scrap scrap;
  const ScrapCard({super.key, required this.scrap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {}, // Handle detail view or edit
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getIcon(scrap.type),
                  const Gap(8),
                  Text(
                    scrap.type.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(scrap.createdAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const Gap(8),
              Text(
                scrap.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (scrap.isSynced)
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.cloud_done, size: 14, color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIcon(ScrapType type) {
    switch (type) {
      case ScrapType.link:
        return const Icon(Icons.link, size: 16);
      case ScrapType.text:
        return const Icon(Icons.notes, size: 16);
      case ScrapType.image:
        return const Icon(Icons.image, size: 16);
      case ScrapType.place:
        return const Icon(Icons.place, size: 16);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
