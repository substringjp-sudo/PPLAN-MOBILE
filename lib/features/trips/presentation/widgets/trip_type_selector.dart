import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/trips/domain/entities/trip_type.dart';

class TripTypeSelector extends StatelessWidget {
  final TripType selectedType;
  final ValueChanged<TripType> onTypeSelected;

  const TripTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<({TripType id, IconData icon, String label, Color color})>
    types = [
      (
        id: TripType.exploration,
        icon: LucideIcons.compass,
        label: l10n.exploration,
        color: Colors.blue,
      ),
      (
        id: TripType.nature,
        icon: LucideIcons.leaf,
        label: l10n.nature,
        color: Colors.green,
      ),
      (
        id: TripType.relaxation,
        icon: LucideIcons.coffee,
        label: l10n.relaxation,
        color: Colors.amber,
      ),
      (
        id: TripType.activity,
        icon: LucideIcons.dumbbell,
        label: l10n.activity,
        color: Colors.orange,
      ),
      (
        id: TripType.performance,
        icon: LucideIcons.ticket,
        label: l10n.performance,
        color: Colors.purple,
      ),
      (
        id: TripType.package,
        icon: LucideIcons.package,
        label: l10n.package,
        color: Colors.indigo,
      ),
      (
        id: TripType.tour,
        icon: LucideIcons.bus,
        label: l10n.tour,
        color: Colors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = selectedType == type.id;

        return InkWell(
          onTap: () => onTypeSelected(type.id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? type.color.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  color: isSelected ? type.color : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? type.color : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
