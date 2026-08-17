import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/bmi_utils.dart';

part 'database.g.dart';

class Profiles extends Table {
  TextColumn get id => text()();

  TextColumn get ownerUid => text()();

  TextColumn get name => text()();

  TextColumn get gender => text()();

  RealColumn get heightCm => real()();

  RealColumn get weightKg => real()();

  IntColumn get preferredWeightUnit => intEnum<WeightUnit>()();

  IntColumn get preferredHeightUnit => intEnum<HeightUnit>()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WeightEntries extends Table {
  TextColumn get id => text()();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  RealColumn get weightKg => real()();

  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppState extends Table {
  TextColumn get key => text()();

  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Profiles, WeightEntries, AppState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
