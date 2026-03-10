import 'package:flutter/material.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';

/// Horizontal stepper for create account (1, 2, 3) with completed checkmarks
class RegistrationStepper extends StatelessWidget {
  const RegistrationStepper({super.key, required this.currentStep});

  /// 0-based current step index
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 2,
          width: double.infinity,
          color: AppColors.stepperInactive,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            for (
              int index = 0;
              index < AuthConstants.registrationStepCount;
              index++
            )
              _StepCircle(
                stepNumber: index + 1,
                isActive: index == currentStep,
                isCompleted: index < currentStep,
              ),
          ],
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.isActive,
    required this.isCompleted,
  });

  final int stepNumber;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isFilled = isActive || isCompleted;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.stepperActive : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled ? AppColors.stepperActive : AppColors.stepperInactive,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: AppColors.primaryButtonText,
              size: 18,
            )
          : Text(
              '$stepNumber',
              style: TextStyle(
                color: isFilled
                    ? AppColors.primaryButtonText
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
    );
  }
}
