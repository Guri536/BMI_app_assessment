import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bmi_utils.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden in main()',
  );
});

// Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Profiles
class ProfilesNotifier extends AsyncNotifier<List<UserProfile>> {
  final String arg;

  ProfilesNotifier(this.arg);

  @override
  Future<List<UserProfile>> build() async {
    return _repo.profilesForUser(arg);
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.profilesForUser(arg));
  }

  Future<UserProfile> addProfile({
    required String name,
    required String gender,
    required double heightCm,
    required double weightKg,
    required WeightUnit preferredWeightUnit,
    required HeightUnit preferredHeightUnit,
  }) async {
    final profile = await _repo.createProfile(
      ownerUid: arg,
      name: name,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      preferredWeightUnit: preferredWeightUnit,
      preferredHeightUnit: preferredHeightUnit,
    );
    await refresh();
    return profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _repo.updateProfile(profile);
    await refresh();
  }

  Future<void> deleteProfile(String id) async {
    await _repo.deleteProfile(id);
    await refresh();
  }
}

final profilesProvider =
    AsyncNotifierProvider.family<ProfilesNotifier, List<UserProfile>, String>(
      (arg) => ProfilesNotifier(arg),
    );

class ActiveProfileIdNotifier extends AsyncNotifier<String?> {
  final String arg; // This is the user's uid
  ActiveProfileIdNotifier(this.arg);

  @override
  Future<String?> build() async {
    return ref.read(profileRepositoryProvider).activeProfileId(arg);
  }

  Future<void> setActive(String profileId) async {
    state = const AsyncValue.loading();
    await ref.read(profileRepositoryProvider).setActiveProfileId(arg, profileId);
    state = AsyncValue.data(profileId);
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    await ref.read(profileRepositoryProvider).clearActiveProfileId(arg);
    state = const AsyncValue.data(null);
  }
}

final activeProfileIdProvider =
    AsyncNotifierProvider.family<ActiveProfileIdNotifier, String?, String>(
      (arg) => ActiveProfileIdNotifier(arg),
    );

// Active Profile (Object)
final activeProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final id = await ref.watch(activeProfileIdProvider(user.uid).future);
  if (id == null) return null;

  final profile = await ref.read(profileRepositoryProvider).profileById(id);
  
  // Security check: ensure profile belongs to logged in user
  if (profile != null && profile.ownerUid == user.uid) {
    return profile;
  }

  return null;
});

final profileByIdProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  id,
) async {
  return ref.read(profileRepositoryProvider).profileById(id);
});

class WeightHistoryNotifier extends AsyncNotifier<List<WeightEntry>> {
  final String arg;

  WeightHistoryNotifier(this.arg);

  @override
  Future<List<WeightEntry>> build() async {
    return _repo.weightHistory(arg);
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.weightHistory(arg));
  }

  Future<void> logWeight(double weightKg) async {
    await _repo.logWeight(profileId: arg, weightKg: weightKg);
    await refresh();
    
    // Invalidate the active profile ID for the current user to trigger a re-fetch of the profile data
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      ref.invalidate(activeProfileIdProvider(user.uid));
    }
  }

  Future<double> loadLastWeight() async {
    final history = state.value ?? await _repo.weightHistory(arg);
    return history.isNotEmpty ? history.last.weightKg : 0.0;
  }
}

final weightHistoryProvider =
    AsyncNotifierProvider.family<
      WeightHistoryNotifier,
      List<WeightEntry>,
      String
    >((arg) => WeightHistoryNotifier(arg));
