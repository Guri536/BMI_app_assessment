import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/bmi_utils.dart';
import '../providers/providers.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/numeric_step_input.dart';
import '../widgets/weight_chart.dart';
import 'profile_switcher_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String ownerUid;

  const DashboardScreen({super.key, required this.ownerUid});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _logWeightDialog(String profileId, WeightUnit unit) async {
    final lastWeight = await (ref.read(
      weightHistoryProvider(profileId).notifier,
    )).loadLastWeight();
    final initialText = lastWeight > 0 ? lastWeight.toStringAsFixed(1) : "";
    final controller = TextEditingController(text: initialText);

    if (!mounted) return;
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log today\'s weight'),
        content: NumericStepInput(
          controller: controller,
          label: 'Weight (${unit.label})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      final kg = UnitConverter.toKg(result, unit);
      await ref.read(weightHistoryProvider(profileId).notifier).logWeight(kg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight logged successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider(widget.ownerUid));
    final activeProfileAsync = ref.watch(activeProfileProvider);

    return profilesAsync.when(
      data: (profiles) {
        return activeProfileAsync.when(
          data: (activeProfile) {
            final profile = activeProfile ?? profiles.first;
            final historyAsync = ref.watch(weightHistoryProvider(profile.id));
            final bmi = BmiCalculator.calculate(
              weightKg: profile.weightKg,
              heightCm: profile.heightCm,
            );

            return Scaffold(
              appBar: AppBar(
                title: Text('Hi, ${profile.name}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.switch_account_outlined),
                    tooltip: 'Switch profile',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileSwitcherScreen(ownerUid: widget.ownerUid),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(profileId: profile.id),
                      ),
                    ),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(profilesProvider(widget.ownerUid).notifier)
                      .refresh();
                  ref
                      .read(weightHistoryProvider(profile.id).notifier)
                      .refresh();
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    BmiGauge(bmi: bmi),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '7-Day Weight History',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${profile.preferredWeightUnit == WeightUnit.kg ? profile.weightKg.toStringAsFixed(1) : UnitConverter.kgToLbs(profile.weightKg).toStringAsFixed(1)} ${profile.preferredWeightUnit.label}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    historyAsync.when(
                      data: (history) => WeightChart(
                        entries: history,
                        useLbs: profile.preferredWeightUnit == WeightUnit.lbs,
                      ),
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) =>
                          Center(child: Text('Error loading history: $err')),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => _logWeightDialog(
                        profile.id,
                        profile.preferredWeightUnit,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Log today\'s weight'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(
            body: Center(child: Text('Error loading profile: $err')),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          Scaffold(body: Center(child: Text('Error loading profiles: $err'))),
    );
  }
}
