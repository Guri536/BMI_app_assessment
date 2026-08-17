import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class NumericStepInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double step;
  final String? Function(String?)? validator;

  const NumericStepInput({
    super.key,
    required this.controller,
    required this.label,
    this.step = 0.1,
    this.validator,
  });

  void _updateValue(double delta) {
    final current = double.tryParse(controller.text) ?? 0.0;
    final next = (current + delta).clamp(0.0, 999.0);
    controller.text = next.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.add,
              onPressed: () => _updateValue(step),
            ),
            const SizedBox(height: 4),
            _StepButton(
              icon: Icons.remove,
              onPressed: () => _updateValue(-step),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.divider,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 24,
          width: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
