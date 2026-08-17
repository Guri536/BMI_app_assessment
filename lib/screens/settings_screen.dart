import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/bmi_utils.dart';
import '../core/validators.dart';
import '../models/user_profile.dart';
import '../providers/providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/numeric_step_input.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String profileId;

  const SettingsScreen({super.key, required this.profileId});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late WeightUnit _weightUnit;
  late HeightUnit _heightUnit;

  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    if (_initialized) {
      _weightController.dispose();
      _heightController.dispose();
    }
    super.dispose();
  }

  void _initFromProfile(UserProfile profile) {
    if (_initialized) return;

    _weightUnit = profile.preferredWeightUnit;
    _heightUnit = profile.preferredHeightUnit;

    final displayWeight = _weightUnit == WeightUnit.kg
        ? profile.weightKg
        : UnitConverter.kgToLbs(profile.weightKg);

    final displayHeight = _heightUnit == HeightUnit.cm
        ? profile.heightCm
        : UnitConverter.cmToInches(profile.heightCm);

    _weightController = TextEditingController(
      text: displayWeight.toStringAsFixed(1),
    );
    _heightController = TextEditingController(
      text: displayHeight.toStringAsFixed(1),
    );

    _initialized = true;
  }

  Future<void> _save(UserProfile profile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final rawWeight = double.parse(_weightController.text.trim());
      final rawHeight = double.parse(_heightController.text.trim());
      final weightKg = UnitConverter.toKg(rawWeight, _weightUnit);
      final heightCm = UnitConverter.toCm(rawHeight, _heightUnit);

      final updated = profile.copyWith(
        weightKg: weightKg,
        heightCm: heightCm,
        preferredWeightUnit: _weightUnit,
        preferredHeightUnit: _heightUnit,
      );

      await ref
          .read(profilesProvider(profile.ownerUid).notifier)
          .updateProfile(updated);
      await ref
          .read(weightHistoryProvider(profile.id).notifier)
          .logWeight(weightKg);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleLogout(String ownerUid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(profileRepositoryProvider).clearActiveProfileId(ownerUid);
      ref.invalidate(activeProfileIdProvider(ownerUid));
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.profileId));

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('Profile not found')));
        }

        _initFromProfile(profile);
        final weightRange = _weightUnit == WeightUnit.kg
            ? const [20.0, 300.0]
            : const [44.0, 660.0];
        final heightRange = _heightUnit == HeightUnit.cm
            ? const [50.0, 250.0]
            : const [20.0, 98.0];

        return Scaffold(
          appBar: AppBar(title: const Text('Update Body Data')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NumericStepInput(
                      controller: _weightController,
                      label: 'Weight (${_weightUnit.label})',
                      validator: (v) => Validators.numeric(
                        v,
                        min: weightRange[0],
                        max: weightRange[1],
                        label: 'Weight',
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _heightController,
                      label: 'Height (${_heightUnit.label})',
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
                    const SizedBox(height: 8),
                    const Text(
                      'Saving updates your BMI immediately and adds a new point to your weight history graph.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saving ? null : () => _save(profile),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _handleLogout(profile.ownerUid),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
