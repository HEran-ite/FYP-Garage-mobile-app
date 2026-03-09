import 'package:flutter/material.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';

/// Grid of selectable service chips; "Other" can show an optional text field
class ServiceChipGrid extends StatelessWidget {
  const ServiceChipGrid({
    super.key,
    required this.selectedServices,
    required this.onSelectionChanged,
    this.otherServicesController,
    this.showOtherField = false,
  });

  final List<String> selectedServices;
  final ValueChanged<List<String>> onSelectionChanged;
  final TextEditingController? otherServicesController;
  final bool showOtherField;

  static const int _crossAxisCount = 2;
  static const double _aspectRatio = 3.2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: _aspectRatio,
          children: AuthConstants.serviceOptions.map((label) {
            final isSelected = selectedServices.contains(label);
            final isOther = label == AuthConstants.otherServiceId;
            return _ServiceChip(
              label: label,
              isSelected: isSelected,
              isOther: isOther,
              onTap: () {
                final next = List<String>.from(selectedServices);
                if (isSelected) {
                  next.remove(label);
                  if (isOther) {
                    otherServicesController?.clear();
                  }
                } else {
                  next.add(label);
                }
                onSelectionChanged(next);
              },
            );
          }).toList(),
        ),
        if (showOtherField) ...[
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: otherServicesController,
            decoration: InputDecoration(
              labelText: 'Specify Other Services',
              hintText: AuthConstants.otherServicesPlaceholder,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
            ),
            maxLength: AuthConstants.maxOtherServicesLength,
          ),
        ],
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.label,
    required this.isSelected,
    required this.isOther,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isOther;
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
      case 'Other':
        return Icons.add;
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
      case 'Other':
        return AppColors.serviceIconGrey;
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
