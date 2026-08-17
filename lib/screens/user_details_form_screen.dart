import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/bmi_utils.dart';
import '../core/validators.dart';
import '../providers/providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/numeric_step_input.dart';

class UserDetailsFormScreen extends ConsumerStatefulWidget {
  final String ownerUid;
  final String? initialName;

  const UserDetailsFormScreen({
    super.key,
    required this.ownerUid,
    this.initialName,
  });

  @override
  ConsumerState<UserDetailsFormScreen> createState() =>
      _UserDetailsFormScreenState();
}

class _UserDetailsFormScreenState extends ConsumerState<UserDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initialName ?? '',
  );
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'Male';
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final rawWeight = double.parse(_weightController.text.trim());
      final rawHeight = double.parse(_heightController.text.trim());
      final weightKg = UnitConverter.toKg(rawWeight, _weightUnit);
      final heightCm = UnitConverter.toCm(rawHeight, _heightUnit);

      await ref
          .read(profilesProvider(widget.ownerUid).notifier)
          .addProfile(
            name: _nameController.text.trim(),
            gender: _gender,
            heightCm: heightCm,
            weightKg: weightKg,
            preferredWeightUnit: _weightUnit,
            preferredHeightUnit: _heightUnit,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() => _error = 'Could not save your details. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _unitToggle<T>({
    required T value,
    required T groupValue,
    required String label,
    required VoidCallback onTap,
  }) {
    final selected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightRange = _weightUnit == WeightUnit.kg
        ? const [20.0, 300.0]
        : const [44.0, 660.0];
    final heightRange = _heightUnit == HeightUnit.cm
        ? const [50.0, 250.0]
        : const [20.0, 100.0];

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(title: const Text('Body Data')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: Validators.name,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: _gender,
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() => _gender = v);
                    }
                  },
                  child: Row(
                    children: ['Male', 'Female', 'Other'].map((g) {
                      return Expanded(
                        child: RadioListTile<String>(
                          value: g,
                          contentPadding: EdgeInsets.zero,
                          title: Text(g, style: const TextStyle(fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Weight',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _unitToggle(
                        value: WeightUnit.kg,
                        groupValue: _weightUnit,
                        label: 'KGS',
                        onTap: () =>
                            setState(() => _weightUnit = WeightUnit.kg),
                      ),
                      _unitToggle(
                        value: WeightUnit.lbs,
                        groupValue: _weightUnit,
                        label: 'LBS',
                        onTap: () =>
                            setState(() => _weightUnit = WeightUnit.lbs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                NumericStepInput(
                  controller: _weightController,
                  label: 'Your weight (${_weightUnit.label})',
                  validator: (v) => Validators.numeric(
                    v,
                    min: weightRange[0],
                    max: weightRange[1],
                    label: 'Weight',
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Height',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _unitToggle(
                        value: HeightUnit.cm,
                        groupValue: _heightUnit,
                        label: 'CM',
                        onTap: () =>
                            setState(() => _heightUnit = HeightUnit.cm),
                      ),
                      _unitToggle(
                        value: HeightUnit.inches,
                        groupValue: _heightUnit,
                        label: 'Inches',
                        onTap: () =>
                            setState(() => _heightUnit = HeightUnit.inches),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _heightController,
                  label: 'Your height (${_heightUnit.label})',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => Validators.numeric(
                    v,
                    min: heightRange[0],
                    max: heightRange[1],
                    label: 'Height',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
