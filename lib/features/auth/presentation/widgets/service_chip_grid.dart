import 'package:flutter/material.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';

/// Grid of selectable predefined services + list of custom services (each as its own chip).
class ServiceChipGrid extends StatefulWidget {
  const ServiceChipGrid({
    super.key,
    required this.selectedServices,
    required this.onSelectionChanged,
    this.customServiceNames = const [],
    this.onCustomServiceNamesChanged,
  });

  final List<String> selectedServices;
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> customServiceNames;
  final ValueChanged<List<String>>? onCustomServiceNamesChanged;

  @override
  State<ServiceChipGrid> createState() => _ServiceChipGridState();
}

class _ServiceChipGridState extends State<ServiceChipGrid> {
  final TextEditingController _customInputController = TextEditingController();

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  void _addCustom() {
    final name = _customInputController.text.trim();
    if (name.isEmpty) return;
    final next = List<String>.from(widget.customServiceNames);
    if (next.contains(name)) return;
    next.add(name);
    _customInputController.clear();
    widget.onCustomServiceNamesChanged?.call(next);
  }

  void _removeCustom(String name) {
    final next = List<String>.from(widget.customServiceNames)..remove(name);
    widget.onCustomServiceNamesChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 3.2,
          children: AuthConstants.serviceOptionsPredefined.map((label) {
            final isSelected = widget.selectedServices.contains(label);
            return _ServiceChip(
              label: label,
              isSelected: isSelected,
              onTap: () {
                final next = List<String>.from(widget.selectedServices);
                if (isSelected) {
                  next.remove(label);
                } else {
                  next.add(label);
                }
                widget.onSelectionChanged(next);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Custom services',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ...widget.customServiceNames.map((name) => _CustomServiceChip(
                  label: name,
                  onRemove: () => _removeCustom(name),
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: _customInputController,
                decoration: InputDecoration(
                  labelText: 'Add custom service',
                  hintText: 'e.g. Bodywork, Detailing',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _addCustom(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: _addCustom,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (label) {
      case 'Oil Change':
        return Icons.oil_barrel;
      case 'Tire Service':
        return Icons.directions_car;
      case 'Brake Repair':
        return Icons.build;
      case 'Engine Diagnostics':
        return Icons.engineering;
      case 'Battery Service':
        return Icons.battery_charging_full;
      case 'AC Repair':
        return Icons.ac_unit;
      default:
        return Icons.build_circle;
    }
  }

  Color get _iconColor {
    if (isSelected) return AppColors.textPrimary;
    switch (label) {
      case 'Oil Change':
        return AppColors.serviceIconRed;
      case 'Tire Service':
        return AppColors.serviceIconGrey;
      case 'Brake Repair':
      case 'Battery Service':
        return AppColors.serviceIconGreen;
      case 'Engine Diagnostics':
      case 'AC Repair':
        return AppColors.serviceIconBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon, size: 20, color: _iconColor),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.primaryButtonText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomServiceChip extends StatelessWidget {
  const _CustomServiceChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.build_circle_outlined, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
