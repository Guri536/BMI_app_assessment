import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../providers/providers.dart';
import 'user_details_form_screen.dart';

class ProfileSwitcherScreen extends ConsumerWidget {
  final String ownerUid;

  const ProfileSwitcherScreen({super.key, required this.ownerUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider(ownerUid));
    final activeIdAsync = ref.watch(activeProfileIdProvider(ownerUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Switch Profile')),
      body: profilesAsync.when(
        data: (profiles) {
          final activeId = activeIdAsync.value;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == profiles.length) {
                return OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailsFormScreen(ownerUid: ownerUid),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Profile'),
                );
              }

              final profile = profiles[index];
              final isActive = profile.id == activeId;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(profile.name),
                  subtitle: Text(
                    '${profile.gender} · ${profile.heightCm.toStringAsFixed(0)} cm',
                  ),
                  trailing: isActive
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete profile?'),
                                content: Text(
                                  'This removes ${profile.name} and their weight history.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref
                                  .read(profilesProvider(ownerUid).notifier)
                                  .deleteProfile(profile.id);
                            }
                          },
                        ),
                  onTap: () async {
                    await ref
                        .read(activeProfileIdProvider(ownerUid).notifier)
                        .setActive(profile.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profiles: $err')),
      ),
    );
  }
}
