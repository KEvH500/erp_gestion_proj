import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Service de gestion de la base de données SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Initialisation FFI si exécution sur Windows/Linux/macOS ou en test unitaire
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'erp_gestion_config.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table des jours de la semaine
        await db.execute('''
          CREATE TABLE app_days (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value INTEGER UNIQUE,
            label TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            order_index INTEGER NOT NULL
          )
        ''');

        // Table des options de rappels
        await db.execute('''
          CREATE TABLE reminder_options (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            minutes INTEGER UNIQUE,
            label TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            is_default INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Peuplement des valeurs par défaut
        await _seedDefaultData(db);
      },
    );
  }

  Future<void> _seedDefaultData(Database db) async {
    // 1. Jours par défaut
    final defaultDays = [
      {'value': 1, 'label': 'Lundi', 'is_active': 1, 'order_index': 1},
      {'value': 2, 'label': 'Mardi', 'is_active': 1, 'order_index': 2},
      {'value': 3, 'label': 'Mercredi', 'is_active': 1, 'order_index': 3},
      {'value': 4, 'label': 'Jeudi', 'is_active': 1, 'order_index': 4},
      {'value': 5, 'label': 'Vendredi', 'is_active': 1, 'order_index': 5},
      {'value': 6, 'label': 'Samedi', 'is_active': 1, 'order_index': 6},
      {'value': 7, 'label': 'Dimanche', 'is_active': 1, 'order_index': 7},
    ];

    for (final day in defaultDays) {
      await db.insert('app_days', day, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2. Options de rappel par défaut (-1 = aucun rappel)
    final defaultReminders = [
      {'minutes': -1, 'label': 'Aucun rappel', 'is_active': 1, 'is_default': 1},
      {'minutes': 5, 'label': '5 minutes avant', 'is_active': 1, 'is_default': 0},
      {'minutes': 10, 'label': '10 minutes avant', 'is_active': 1, 'is_default': 0},
      {'minutes': 15, 'label': '15 minutes avant', 'is_active': 1, 'is_default': 0},
      {'minutes': 30, 'label': '30 minutes avant', 'is_active': 1, 'is_default': 0},
      {'minutes': 60, 'label': '1 heure avant', 'is_active': 1, 'is_default': 0},
    ];

    for (final reminder in defaultReminders) {
      await db.insert('reminder_options', reminder, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Réinitialiser les données de configuration aux valeurs par défaut
  Future<void> resetToDefaults() async {
    final db = await database;
    await db.delete('app_days');
    await db.delete('reminder_options');
    await _seedDefaultData(db);
  }
}
