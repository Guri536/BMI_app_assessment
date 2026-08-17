import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bmi_utils.dart';

/// Displays the current BMI value with its category badge, color-coded
/// underweight -> normal -> overweight -> obese.
class BmiGauge extends StatelessWidget {
  final double bmi;

  const BmiGauge({super.key, required this.bmi});

  Color _colorFor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return AppColors.underweight;
      case BmiCategory.normal:
        return AppColors.normal;
      case BmiCategory.overweight:
        return AppColors.overweight;
      case BmiCategory.obese:
        return AppColors.obese;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = BmiCalculator.categoryFor(bmi);
    final color = _colorFor(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            BmiCalculator.formatted(bmi),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          const Text('Your BMI', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(
              category.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
