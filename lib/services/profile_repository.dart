import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/bmi_utils.dart';
import '../models/user_profile.dart' as domain;
import '../models/weight_entry.dart' as domain;
import 'database.dart';

class ProfileRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProfileRepository(this._db);

  Future<void> init() async {}

  // Mapper
  domain.UserProfile _mapProfile(Profile p) {
    return domain.UserProfile(
      id: p.id,
      ownerUid: p.ownerUid,
      name: p.name,
      gender: p.gender,
      heightCm: p.heightCm,
      weightKg: p.weightKg,
      preferredWeightUnit: p.preferredWeightUnit,
      preferredHeightUnit: p.preferredHeightUnit,
      createdAt: p.createdAt,
    );
  }

  domain.WeightEntry _mapWeight(WeightEntry p) {
    return domain.WeightEntry(
      id: p.id,
      profileId: p.profileId,
      weightKg: p.weightKg,
      date: p.date,
    );
  }

  Future<List<domain.UserProfile>> profilesForUser(String ownerUid) async {
    final query = _db.select(_db.profiles)
      ..where((t) => t.ownerUid.equals(ownerUid));
    final results = await query.get();
    return results.map(_mapProfile).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<domain.UserProfile?> profileById(String id) async {
    final query = _db.select(_db.profiles)..where((t) => t.id.equals(id));
    final p = await query.getSingleOrNull();
    return p != null ? _mapProfile(p) : null;
  }

  Future<domain.UserProfile> createProfile({
    required String ownerUid,
    required String name,
    required String gender,
    required double heightCm,
    required double weightKg,
    required WeightUnit preferredWeightUnit,
    required HeightUnit preferredHeightUnit,
  }) async {
    final id = _uuid.v4();
    final profile = ProfilesCompanion.insert(
      id: id,
      ownerUid: ownerUid,
      name: name,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      preferredWeightUnit: preferredWeightUnit,
      preferredHeightUnit: preferredHeightUnit,
      createdAt: DateTime.now(),
    );
    await _db.into(_db.profiles).insert(profile);
    await logWeight(profileId: id, weightKg: weightKg);
    await setActiveProfileId(ownerUid, id);

    final created = await profileById(id);
    return created!;
  }

  Future<void> updateProfile(domain.UserProfile updated) async {
    await (_db.update(
      _db.profiles,
    )..where((t) => t.id.equals(updated.id))).write(
      ProfilesCompanion(
        name: Value(updated.name),
        gender: Value(updated.gender),
        heightCm: Value(updated.heightCm),
        weightKg: Value(updated.weightKg),
        preferredWeightUnit: Value(updated.preferredWeightUnit),
        preferredHeightUnit: Value(updated.preferredHeightUnit),
      ),
    );
  }

  Future<void> deleteProfile(String profileId) async {
    final profile = await profileById(profileId);
    if (profile == null) return;

    await (_db.delete(_db.profiles)..where((t) => t.id.equals(profileId))).go();
    // Cascade delete handles weight entries
    if (await activeProfileId(profile.ownerUid) == profileId) {
      await clearActiveProfileId(profile.ownerUid);
    }
  }

  Future<String?> activeProfileId(String ownerUid) async {
    final query = _db.select(_db.appState)
      ..where((t) => t.key.equals('active_profile_id_$ownerUid'));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> setActiveProfileId(String ownerUid, String profileId) async {
    await _db
        .into(_db.appState)
        .insertOnConflictUpdate(
          AppStateCompanion.insert(
            key: 'active_profile_id_$ownerUid',
            value: Value(profileId),
          ),
        );
  }

  Future<void> clearActiveProfileId(String ownerUid) async {
    await (_db.delete(
      _db.appState,
    )..where((t) => t.key.equals('active_profile_id_$ownerUid'))).go();
  }

  Future<domain.WeightEntry> logWeight({
    required String profileId,
    required double weightKg,
    DateTime? date,
  }) async {
    final logDate = date ?? DateTime.now();
    final normalizedDate = DateTime(logDate.year, logDate.month, logDate.day);

    final dateStr =
        "${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}";
    final id = "${profileId}_$dateStr";

    final entry = WeightEntriesCompanion.insert(
      id: id,
      profileId: profileId,
      weightKg: weightKg,
      date: normalizedDate,
    );

    await _db.into(_db.weightEntries).insertOnConflictUpdate(entry);
    await (_db.update(_db.profiles)..where((t) => t.id.equals(profileId)))
        .write(ProfilesCompanion(weightKg: Value(weightKg)));

    return domain.WeightEntry(
      id: id,
      profileId: profileId,
      weightKg: weightKg,
      date: normalizedDate,
    );
  }

  Future<List<domain.WeightEntry>> weightHistory(
    String profileId, {
    int days = 7,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final query = _db.select(_db.weightEntries)
      ..where(
        (t) => t.profileId.equals(profileId) & t.date.isBiggerThanValue(cutoff),
      );
    final results = await query.get();
    return results.map(_mapWeight).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
