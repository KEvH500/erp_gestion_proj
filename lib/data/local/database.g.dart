// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF3B82F6));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorValue, createdAt, isArchived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final int colorValue;
  final DateTime createdAt;
  final bool isArchived;
  const Project(
      {required this.id,
      required this.name,
      required this.colorValue,
      required this.createdAt,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Project copyWith(
          {int? id,
          String? name,
          int? colorValue,
          DateTime? createdAt,
          bool? isArchived}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt ?? this.createdAt,
        isArchived: isArchived ?? this.isArchived,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorValue, createdAt, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? colorValue,
      Value<DateTime>? createdAt,
      Value<bool>? isArchived}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRulesTable extends RecurrenceRules
    with TableInfo<$RecurrenceRulesTable, RecurrenceRuleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceFrequency, int>
      frequency = GeneratedColumn<int>('frequency', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<RecurrenceFrequency>(
              $RecurrenceRulesTable.$converterfrequency);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _byWeekDaysMeta =
      const VerificationMeta('byWeekDays');
  @override
  late final GeneratedColumn<String> byWeekDays = GeneratedColumn<String>(
      'by_week_days', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endTypeMeta =
      const VerificationMeta('endType');
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceEndType, int> endType =
      GeneratedColumn<int>('end_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<RecurrenceEndType>(
              $RecurrenceRulesTable.$converterendType);
  static const VerificationMeta _untilDateMeta =
      const VerificationMeta('untilDate');
  @override
  late final GeneratedColumn<DateTime> untilDate = GeneratedColumn<DateTime>(
      'until_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _occurrenceCountMeta =
      const VerificationMeta('occurrenceCount');
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
      'occurrence_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        frequency,
        interval,
        byWeekDays,
        endType,
        untilDate,
        occurrenceCount,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rules';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurrenceRuleEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_frequencyMeta, const VerificationResult.success());
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('by_week_days')) {
      context.handle(
          _byWeekDaysMeta,
          byWeekDays.isAcceptableOrUnknown(
              data['by_week_days']!, _byWeekDaysMeta));
    }
    context.handle(_endTypeMeta, const VerificationResult.success());
    if (data.containsKey('until_date')) {
      context.handle(_untilDateMeta,
          untilDate.isAcceptableOrUnknown(data['until_date']!, _untilDateMeta));
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
          _occurrenceCountMeta,
          occurrenceCount.isAcceptableOrUnknown(
              data['occurrence_count']!, _occurrenceCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRuleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRuleEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      frequency: $RecurrenceRulesTable.$converterfrequency.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!),
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      byWeekDays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_week_days']),
      endType: $RecurrenceRulesTable.$converterendType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_type'])!),
      untilDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}until_date']),
      occurrenceCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}occurrence_count']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurrenceRulesTable createAlias(String alias) {
    return $RecurrenceRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecurrenceFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<RecurrenceFrequency>(RecurrenceFrequency.values);
  static JsonTypeConverter2<RecurrenceEndType, int, int> $converterendType =
      const EnumIndexConverter<RecurrenceEndType>(RecurrenceEndType.values);
}

class RecurrenceRuleEntry extends DataClass
    implements Insertable<RecurrenceRuleEntry> {
  final int id;
  final RecurrenceFrequency frequency;
  final int interval;
  final String? byWeekDays;
  final RecurrenceEndType endType;
  final DateTime? untilDate;
  final int? occurrenceCount;
  final DateTime createdAt;
  const RecurrenceRuleEntry(
      {required this.id,
      required this.frequency,
      required this.interval,
      this.byWeekDays,
      required this.endType,
      this.untilDate,
      this.occurrenceCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['frequency'] = Variable<int>(
          $RecurrenceRulesTable.$converterfrequency.toSql(frequency));
    }
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || byWeekDays != null) {
      map['by_week_days'] = Variable<String>(byWeekDays);
    }
    {
      map['end_type'] =
          Variable<int>($RecurrenceRulesTable.$converterendType.toSql(endType));
    }
    if (!nullToAbsent || untilDate != null) {
      map['until_date'] = Variable<DateTime>(untilDate);
    }
    if (!nullToAbsent || occurrenceCount != null) {
      map['occurrence_count'] = Variable<int>(occurrenceCount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRulesCompanion(
      id: Value(id),
      frequency: Value(frequency),
      interval: Value(interval),
      byWeekDays: byWeekDays == null && nullToAbsent
          ? const Value.absent()
          : Value(byWeekDays),
      endType: Value(endType),
      untilDate: untilDate == null && nullToAbsent
          ? const Value.absent()
          : Value(untilDate),
      occurrenceCount: occurrenceCount == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceCount),
      createdAt: Value(createdAt),
    );
  }

  factory RecurrenceRuleEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRuleEntry(
      id: serializer.fromJson<int>(json['id']),
      frequency: $RecurrenceRulesTable.$converterfrequency
          .fromJson(serializer.fromJson<int>(json['frequency'])),
      interval: serializer.fromJson<int>(json['interval']),
      byWeekDays: serializer.fromJson<String?>(json['byWeekDays']),
      endType: $RecurrenceRulesTable.$converterendType
          .fromJson(serializer.fromJson<int>(json['endType'])),
      untilDate: serializer.fromJson<DateTime?>(json['untilDate']),
      occurrenceCount: serializer.fromJson<int?>(json['occurrenceCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'frequency': serializer.toJson<int>(
          $RecurrenceRulesTable.$converterfrequency.toJson(frequency)),
      'interval': serializer.toJson<int>(interval),
      'byWeekDays': serializer.toJson<String?>(byWeekDays),
      'endType': serializer
          .toJson<int>($RecurrenceRulesTable.$converterendType.toJson(endType)),
      'untilDate': serializer.toJson<DateTime?>(untilDate),
      'occurrenceCount': serializer.toJson<int?>(occurrenceCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurrenceRuleEntry copyWith(
          {int? id,
          RecurrenceFrequency? frequency,
          int? interval,
          Value<String?> byWeekDays = const Value.absent(),
          RecurrenceEndType? endType,
          Value<DateTime?> untilDate = const Value.absent(),
          Value<int?> occurrenceCount = const Value.absent(),
          DateTime? createdAt}) =>
      RecurrenceRuleEntry(
        id: id ?? this.id,
        frequency: frequency ?? this.frequency,
        interval: interval ?? this.interval,
        byWeekDays: byWeekDays.present ? byWeekDays.value : this.byWeekDays,
        endType: endType ?? this.endType,
        untilDate: untilDate.present ? untilDate.value : this.untilDate,
        occurrenceCount: occurrenceCount.present
            ? occurrenceCount.value
            : this.occurrenceCount,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurrenceRuleEntry copyWithCompanion(RecurrenceRulesCompanion data) {
    return RecurrenceRuleEntry(
      id: data.id.present ? data.id.value : this.id,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      byWeekDays:
          data.byWeekDays.present ? data.byWeekDays.value : this.byWeekDays,
      endType: data.endType.present ? data.endType.value : this.endType,
      untilDate: data.untilDate.present ? data.untilDate.value : this.untilDate,
      occurrenceCount: data.occurrenceCount.present
          ? data.occurrenceCount.value
          : this.occurrenceCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRuleEntry(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('byWeekDays: $byWeekDays, ')
          ..write('endType: $endType, ')
          ..write('untilDate: $untilDate, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, frequency, interval, byWeekDays, endType,
      untilDate, occurrenceCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRuleEntry &&
          other.id == this.id &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.byWeekDays == this.byWeekDays &&
          other.endType == this.endType &&
          other.untilDate == this.untilDate &&
          other.occurrenceCount == this.occurrenceCount &&
          other.createdAt == this.createdAt);
}

class RecurrenceRulesCompanion extends UpdateCompanion<RecurrenceRuleEntry> {
  final Value<int> id;
  final Value<RecurrenceFrequency> frequency;
  final Value<int> interval;
  final Value<String?> byWeekDays;
  final Value<RecurrenceEndType> endType;
  final Value<DateTime?> untilDate;
  final Value<int?> occurrenceCount;
  final Value<DateTime> createdAt;
  const RecurrenceRulesCompanion({
    this.id = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.byWeekDays = const Value.absent(),
    this.endType = const Value.absent(),
    this.untilDate = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurrenceRulesCompanion.insert({
    this.id = const Value.absent(),
    required RecurrenceFrequency frequency,
    this.interval = const Value.absent(),
    this.byWeekDays = const Value.absent(),
    this.endType = const Value.absent(),
    this.untilDate = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : frequency = Value(frequency);
  static Insertable<RecurrenceRuleEntry> custom({
    Expression<int>? id,
    Expression<int>? frequency,
    Expression<int>? interval,
    Expression<String>? byWeekDays,
    Expression<int>? endType,
    Expression<DateTime>? untilDate,
    Expression<int>? occurrenceCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (byWeekDays != null) 'by_week_days': byWeekDays,
      if (endType != null) 'end_type': endType,
      if (untilDate != null) 'until_date': untilDate,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurrenceRulesCompanion copyWith(
      {Value<int>? id,
      Value<RecurrenceFrequency>? frequency,
      Value<int>? interval,
      Value<String?>? byWeekDays,
      Value<RecurrenceEndType>? endType,
      Value<DateTime?>? untilDate,
      Value<int?>? occurrenceCount,
      Value<DateTime>? createdAt}) {
    return RecurrenceRulesCompanion(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      byWeekDays: byWeekDays ?? this.byWeekDays,
      endType: endType ?? this.endType,
      untilDate: untilDate ?? this.untilDate,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(
          $RecurrenceRulesTable.$converterfrequency.toSql(frequency.value));
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (byWeekDays.present) {
      map['by_week_days'] = Variable<String>(byWeekDays.value);
    }
    if (endType.present) {
      map['end_type'] = Variable<int>(
          $RecurrenceRulesTable.$converterendType.toSql(endType.value));
    }
    if (untilDate.present) {
      map['until_date'] = Variable<DateTime>(untilDate.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRulesCompanion(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('byWeekDays: $byWeekDays, ')
          ..write('endType: $endType, ')
          ..write('untilDate: $untilDate, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE SET NULL'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startHourMeta =
      const VerificationMeta('startHour');
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
      'start_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMinuteMeta =
      const VerificationMeta('startMinute');
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
      'start_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endHourMeta =
      const VerificationMeta('endHour');
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
      'end_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMinuteMeta =
      const VerificationMeta('endMinute');
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
      'end_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recurrenceRuleIdMeta =
      const VerificationMeta('recurrenceRuleId');
  @override
  late final GeneratedColumn<int> recurrenceRuleId = GeneratedColumn<int>(
      'recurrence_rule_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurrence_rules (id) ON DELETE SET NULL'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumnWithTypeConverter<ActivityCategory, int> category =
      GeneratedColumn<int>('category', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ActivityCategory>($TasksTable.$convertercategory);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
      'reminder_minutes_before', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF3B82F6));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        title,
        description,
        startDate,
        startHour,
        startMinute,
        endHour,
        endMinute,
        recurrenceRuleId,
        category,
        location,
        reminderMinutesBefore,
        colorValue,
        isCompleted,
        isArchived,
        archivedAt,
        isLocked,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(_startHourMeta,
          startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta));
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
          _startMinuteMeta,
          startMinute.isAcceptableOrUnknown(
              data['start_minute']!, _startMinuteMeta));
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(_endHourMeta,
          endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta));
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(_endMinuteMeta,
          endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta));
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
          _recurrenceRuleIdMeta,
          recurrenceRuleId.isAcceptableOrUnknown(
              data['recurrence_rule_id']!, _recurrenceRuleIdMeta));
    }
    context.handle(_categoryMeta, const VerificationResult.success());
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
          _reminderMinutesBeforeMeta,
          reminderMinutesBefore.isAcceptableOrUnknown(
              data['reminder_minutes_before']!, _reminderMinutesBeforeMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      startHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_hour'])!,
      startMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_minute'])!,
      endHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_hour'])!,
      endMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_minute'])!,
      recurrenceRuleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_rule_id']),
      category: $TasksTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_minutes_before']),
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityCategory, int, int> $convertercategory =
      const EnumIndexConverter<ActivityCategory>(ActivityCategory.values);
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int? projectId;
  final String title;
  final String? description;
  final DateTime startDate;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int? recurrenceRuleId;
  final ActivityCategory category;
  final String? location;
  final int? reminderMinutesBefore;
  final int colorValue;
  final bool isCompleted;
  final bool isArchived;
  final DateTime? archivedAt;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Task(
      {required this.id,
      this.projectId,
      required this.title,
      this.description,
      required this.startDate,
      required this.startHour,
      required this.startMinute,
      required this.endHour,
      required this.endMinute,
      this.recurrenceRuleId,
      required this.category,
      this.location,
      this.reminderMinutesBefore,
      required this.colorValue,
      required this.isCompleted,
      required this.isArchived,
      this.archivedAt,
      required this.isLocked,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['start_hour'] = Variable<int>(startHour);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_hour'] = Variable<int>(endHour);
    map['end_minute'] = Variable<int>(endMinute);
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<int>(recurrenceRuleId);
    }
    {
      map['category'] =
          Variable<int>($TasksTable.$convertercategory.toSql(category));
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || reminderMinutesBefore != null) {
      map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    }
    map['color_value'] = Variable<int>(colorValue);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      startHour: Value(startHour),
      startMinute: Value(startMinute),
      endHour: Value(endHour),
      endMinute: Value(endMinute),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      category: Value(category),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      reminderMinutesBefore: reminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutesBefore),
      colorValue: Value(colorValue),
      isCompleted: Value(isCompleted),
      isArchived: Value(isArchived),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      isLocked: Value(isLocked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      startHour: serializer.fromJson<int>(json['startHour']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endHour: serializer.fromJson<int>(json['endHour']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      recurrenceRuleId: serializer.fromJson<int?>(json['recurrenceRuleId']),
      category: $TasksTable.$convertercategory
          .fromJson(serializer.fromJson<int>(json['category'])),
      location: serializer.fromJson<String?>(json['location']),
      reminderMinutesBefore:
          serializer.fromJson<int?>(json['reminderMinutesBefore']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int?>(projectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime>(startDate),
      'startHour': serializer.toJson<int>(startHour),
      'startMinute': serializer.toJson<int>(startMinute),
      'endHour': serializer.toJson<int>(endHour),
      'endMinute': serializer.toJson<int>(endMinute),
      'recurrenceRuleId': serializer.toJson<int?>(recurrenceRuleId),
      'category': serializer
          .toJson<int>($TasksTable.$convertercategory.toJson(category)),
      'location': serializer.toJson<String?>(location),
      'reminderMinutesBefore': serializer.toJson<int?>(reminderMinutesBefore),
      'colorValue': serializer.toJson<int>(colorValue),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isArchived': serializer.toJson<bool>(isArchived),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Task copyWith(
          {int? id,
          Value<int?> projectId = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? startDate,
          int? startHour,
          int? startMinute,
          int? endHour,
          int? endMinute,
          Value<int?> recurrenceRuleId = const Value.absent(),
          ActivityCategory? category,
          Value<String?> location = const Value.absent(),
          Value<int?> reminderMinutesBefore = const Value.absent(),
          int? colorValue,
          bool? isCompleted,
          bool? isArchived,
          Value<DateTime?> archivedAt = const Value.absent(),
          bool? isLocked,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Task(
        id: id ?? this.id,
        projectId: projectId.present ? projectId.value : this.projectId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        startDate: startDate ?? this.startDate,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
        recurrenceRuleId: recurrenceRuleId.present
            ? recurrenceRuleId.value
            : this.recurrenceRuleId,
        category: category ?? this.category,
        location: location.present ? location.value : this.location,
        reminderMinutesBefore: reminderMinutesBefore.present
            ? reminderMinutesBefore.value
            : this.reminderMinutesBefore,
        colorValue: colorValue ?? this.colorValue,
        isCompleted: isCompleted ?? this.isCompleted,
        isArchived: isArchived ?? this.isArchived,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        isLocked: isLocked ?? this.isLocked,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      startMinute:
          data.startMinute.present ? data.startMinute.value : this.startMinute,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isArchived: $isArchived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      title,
      description,
      startDate,
      startHour,
      startMinute,
      endHour,
      endMinute,
      recurrenceRuleId,
      category,
      location,
      reminderMinutesBefore,
      colorValue,
      isCompleted,
      isArchived,
      archivedAt,
      isLocked,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.startHour == this.startHour &&
          other.startMinute == this.startMinute &&
          other.endHour == this.endHour &&
          other.endMinute == this.endMinute &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.category == this.category &&
          other.location == this.location &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.colorValue == this.colorValue &&
          other.isCompleted == this.isCompleted &&
          other.isArchived == this.isArchived &&
          other.archivedAt == this.archivedAt &&
          other.isLocked == this.isLocked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int?> projectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> startDate;
  final Value<int> startHour;
  final Value<int> startMinute;
  final Value<int> endHour;
  final Value<int> endMinute;
  final Value<int?> recurrenceRuleId;
  final Value<ActivityCategory> category;
  final Value<String?> location;
  final Value<int?> reminderMinutesBefore;
  final Value<int> colorValue;
  final Value<bool> isCompleted;
  final Value<bool> isArchived;
  final Value<DateTime?> archivedAt;
  final Value<bool> isLocked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startHour = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endHour = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime startDate,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    this.recurrenceRuleId = const Value.absent(),
    required ActivityCategory category,
    this.location = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        startDate = Value(startDate),
        startHour = Value(startHour),
        startMinute = Value(startMinute),
        endHour = Value(endHour),
        endMinute = Value(endMinute),
        category = Value(category);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<int>? startHour,
    Expression<int>? startMinute,
    Expression<int>? endHour,
    Expression<int>? endMinute,
    Expression<int>? recurrenceRuleId,
    Expression<int>? category,
    Expression<String>? location,
    Expression<int>? reminderMinutesBefore,
    Expression<int>? colorValue,
    Expression<bool>? isCompleted,
    Expression<bool>? isArchived,
    Expression<DateTime>? archivedAt,
    Expression<bool>? isLocked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (startHour != null) 'start_hour': startHour,
      if (startMinute != null) 'start_minute': startMinute,
      if (endHour != null) 'end_hour': endHour,
      if (endMinute != null) 'end_minute': endMinute,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (colorValue != null) 'color_value': colorValue,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isArchived != null) 'is_archived': isArchived,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (isLocked != null) 'is_locked': isLocked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<int?>? projectId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? startDate,
      Value<int>? startHour,
      Value<int>? startMinute,
      Value<int>? endHour,
      Value<int>? endMinute,
      Value<int?>? recurrenceRuleId,
      Value<ActivityCategory>? category,
      Value<String?>? location,
      Value<int?>? reminderMinutesBefore,
      Value<int>? colorValue,
      Value<bool>? isCompleted,
      Value<bool>? isArchived,
      Value<DateTime?>? archivedAt,
      Value<bool>? isLocked,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TasksCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      category: category ?? this.category,
      location: location ?? this.location,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      colorValue: colorValue ?? this.colorValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<int>(recurrenceRuleId.value);
    }
    if (category.present) {
      map['category'] =
          Variable<int>($TasksTable.$convertercategory.toSql(category.value));
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] =
          Variable<int>(reminderMinutesBefore.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isArchived: $isArchived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TaskCommentsTable extends TaskComments
    with TableInfo<$TaskCommentsTable, TaskComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, taskId, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_comments';
  @override
  VerificationContext validateIntegrity(Insertable<TaskComment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskComment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TaskCommentsTable createAlias(String alias) {
    return $TaskCommentsTable(attachedDatabase, alias);
  }
}

class TaskComment extends DataClass implements Insertable<TaskComment> {
  final int id;
  final int taskId;
  final String content;
  final DateTime createdAt;
  const TaskComment(
      {required this.id,
      required this.taskId,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskCommentsCompanion toCompanion(bool nullToAbsent) {
    return TaskCommentsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory TaskComment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskComment(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskComment copyWith(
          {int? id, int? taskId, String? content, DateTime? createdAt}) =>
      TaskComment(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  TaskComment copyWithCompanion(TaskCommentsCompanion data) {
    return TaskComment(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskComment(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskComment &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class TaskCommentsCompanion extends UpdateCompanion<TaskComment> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const TaskCommentsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskCommentsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String content,
    this.createdAt = const Value.absent(),
  })  : taskId = Value(taskId),
        content = Value(content);
  static Insertable<TaskComment> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskCommentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? taskId,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return TaskCommentsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCommentsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceExceptionsTable extends RecurrenceExceptions
    with TableInfo<$RecurrenceExceptionsTable, RecurrenceExceptionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _originalDateMeta =
      const VerificationMeta('originalDate');
  @override
  late final GeneratedColumn<DateTime> originalDate = GeneratedColumn<DateTime>(
      'original_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCancelledMeta =
      const VerificationMeta('isCancelled');
  @override
  late final GeneratedColumn<bool> isCancelled = GeneratedColumn<bool>(
      'is_cancelled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_cancelled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDetachedMeta =
      const VerificationMeta('isDetached');
  @override
  late final GeneratedColumn<bool> isDetached = GeneratedColumn<bool>(
      'is_detached', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_detached" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _detachedTaskIdMeta =
      const VerificationMeta('detachedTaskId');
  @override
  late final GeneratedColumn<int> detachedTaskId = GeneratedColumn<int>(
      'detached_task_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE SET NULL'));
  static const VerificationMeta _newDateMeta =
      const VerificationMeta('newDate');
  @override
  late final GeneratedColumn<DateTime> newDate = GeneratedColumn<DateTime>(
      'new_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _newStartTimeMeta =
      const VerificationMeta('newStartTime');
  @override
  late final GeneratedColumn<DateTime> newStartTime = GeneratedColumn<DateTime>(
      'new_start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _newEndTimeMeta =
      const VerificationMeta('newEndTime');
  @override
  late final GeneratedColumn<DateTime> newEndTime = GeneratedColumn<DateTime>(
      'new_end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        originalDate,
        isCancelled,
        isDetached,
        detachedTaskId,
        newDate,
        newStartTime,
        newEndTime,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_exceptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurrenceExceptionEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('original_date')) {
      context.handle(
          _originalDateMeta,
          originalDate.isAcceptableOrUnknown(
              data['original_date']!, _originalDateMeta));
    } else if (isInserting) {
      context.missing(_originalDateMeta);
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
          _isCancelledMeta,
          isCancelled.isAcceptableOrUnknown(
              data['is_cancelled']!, _isCancelledMeta));
    }
    if (data.containsKey('is_detached')) {
      context.handle(
          _isDetachedMeta,
          isDetached.isAcceptableOrUnknown(
              data['is_detached']!, _isDetachedMeta));
    }
    if (data.containsKey('detached_task_id')) {
      context.handle(
          _detachedTaskIdMeta,
          detachedTaskId.isAcceptableOrUnknown(
              data['detached_task_id']!, _detachedTaskIdMeta));
    }
    if (data.containsKey('new_date')) {
      context.handle(_newDateMeta,
          newDate.isAcceptableOrUnknown(data['new_date']!, _newDateMeta));
    }
    if (data.containsKey('new_start_time')) {
      context.handle(
          _newStartTimeMeta,
          newStartTime.isAcceptableOrUnknown(
              data['new_start_time']!, _newStartTimeMeta));
    }
    if (data.containsKey('new_end_time')) {
      context.handle(
          _newEndTimeMeta,
          newEndTime.isAcceptableOrUnknown(
              data['new_end_time']!, _newEndTimeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {taskId, originalDate},
      ];
  @override
  RecurrenceExceptionEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceExceptionEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      originalDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}original_date'])!,
      isCancelled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cancelled'])!,
      isDetached: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_detached'])!,
      detachedTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}detached_task_id']),
      newDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}new_date']),
      newStartTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}new_start_time']),
      newEndTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}new_end_time']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurrenceExceptionsTable createAlias(String alias) {
    return $RecurrenceExceptionsTable(attachedDatabase, alias);
  }
}

class RecurrenceExceptionEntry extends DataClass
    implements Insertable<RecurrenceExceptionEntry> {
  final int id;
  final int taskId;
  final DateTime originalDate;
  final bool isCancelled;
  final bool isDetached;
  final int? detachedTaskId;
  final DateTime? newDate;
  final DateTime? newStartTime;
  final DateTime? newEndTime;
  final DateTime createdAt;
  const RecurrenceExceptionEntry(
      {required this.id,
      required this.taskId,
      required this.originalDate,
      required this.isCancelled,
      required this.isDetached,
      this.detachedTaskId,
      this.newDate,
      this.newStartTime,
      this.newEndTime,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['original_date'] = Variable<DateTime>(originalDate);
    map['is_cancelled'] = Variable<bool>(isCancelled);
    map['is_detached'] = Variable<bool>(isDetached);
    if (!nullToAbsent || detachedTaskId != null) {
      map['detached_task_id'] = Variable<int>(detachedTaskId);
    }
    if (!nullToAbsent || newDate != null) {
      map['new_date'] = Variable<DateTime>(newDate);
    }
    if (!nullToAbsent || newStartTime != null) {
      map['new_start_time'] = Variable<DateTime>(newStartTime);
    }
    if (!nullToAbsent || newEndTime != null) {
      map['new_end_time'] = Variable<DateTime>(newEndTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurrenceExceptionsCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceExceptionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      originalDate: Value(originalDate),
      isCancelled: Value(isCancelled),
      isDetached: Value(isDetached),
      detachedTaskId: detachedTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(detachedTaskId),
      newDate: newDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newDate),
      newStartTime: newStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(newStartTime),
      newEndTime: newEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(newEndTime),
      createdAt: Value(createdAt),
    );
  }

  factory RecurrenceExceptionEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceExceptionEntry(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      originalDate: serializer.fromJson<DateTime>(json['originalDate']),
      isCancelled: serializer.fromJson<bool>(json['isCancelled']),
      isDetached: serializer.fromJson<bool>(json['isDetached']),
      detachedTaskId: serializer.fromJson<int?>(json['detachedTaskId']),
      newDate: serializer.fromJson<DateTime?>(json['newDate']),
      newStartTime: serializer.fromJson<DateTime?>(json['newStartTime']),
      newEndTime: serializer.fromJson<DateTime?>(json['newEndTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'originalDate': serializer.toJson<DateTime>(originalDate),
      'isCancelled': serializer.toJson<bool>(isCancelled),
      'isDetached': serializer.toJson<bool>(isDetached),
      'detachedTaskId': serializer.toJson<int?>(detachedTaskId),
      'newDate': serializer.toJson<DateTime?>(newDate),
      'newStartTime': serializer.toJson<DateTime?>(newStartTime),
      'newEndTime': serializer.toJson<DateTime?>(newEndTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurrenceExceptionEntry copyWith(
          {int? id,
          int? taskId,
          DateTime? originalDate,
          bool? isCancelled,
          bool? isDetached,
          Value<int?> detachedTaskId = const Value.absent(),
          Value<DateTime?> newDate = const Value.absent(),
          Value<DateTime?> newStartTime = const Value.absent(),
          Value<DateTime?> newEndTime = const Value.absent(),
          DateTime? createdAt}) =>
      RecurrenceExceptionEntry(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        originalDate: originalDate ?? this.originalDate,
        isCancelled: isCancelled ?? this.isCancelled,
        isDetached: isDetached ?? this.isDetached,
        detachedTaskId:
            detachedTaskId.present ? detachedTaskId.value : this.detachedTaskId,
        newDate: newDate.present ? newDate.value : this.newDate,
        newStartTime:
            newStartTime.present ? newStartTime.value : this.newStartTime,
        newEndTime: newEndTime.present ? newEndTime.value : this.newEndTime,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurrenceExceptionEntry copyWithCompanion(
      RecurrenceExceptionsCompanion data) {
    return RecurrenceExceptionEntry(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      isCancelled:
          data.isCancelled.present ? data.isCancelled.value : this.isCancelled,
      isDetached:
          data.isDetached.present ? data.isDetached.value : this.isDetached,
      detachedTaskId: data.detachedTaskId.present
          ? data.detachedTaskId.value
          : this.detachedTaskId,
      newDate: data.newDate.present ? data.newDate.value : this.newDate,
      newStartTime: data.newStartTime.present
          ? data.newStartTime.value
          : this.newStartTime,
      newEndTime:
          data.newEndTime.present ? data.newEndTime.value : this.newEndTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceExceptionEntry(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('originalDate: $originalDate, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('isDetached: $isDetached, ')
          ..write('detachedTaskId: $detachedTaskId, ')
          ..write('newDate: $newDate, ')
          ..write('newStartTime: $newStartTime, ')
          ..write('newEndTime: $newEndTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, originalDate, isCancelled,
      isDetached, detachedTaskId, newDate, newStartTime, newEndTime, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceExceptionEntry &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.originalDate == this.originalDate &&
          other.isCancelled == this.isCancelled &&
          other.isDetached == this.isDetached &&
          other.detachedTaskId == this.detachedTaskId &&
          other.newDate == this.newDate &&
          other.newStartTime == this.newStartTime &&
          other.newEndTime == this.newEndTime &&
          other.createdAt == this.createdAt);
}

class RecurrenceExceptionsCompanion
    extends UpdateCompanion<RecurrenceExceptionEntry> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<DateTime> originalDate;
  final Value<bool> isCancelled;
  final Value<bool> isDetached;
  final Value<int?> detachedTaskId;
  final Value<DateTime?> newDate;
  final Value<DateTime?> newStartTime;
  final Value<DateTime?> newEndTime;
  final Value<DateTime> createdAt;
  const RecurrenceExceptionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.isDetached = const Value.absent(),
    this.detachedTaskId = const Value.absent(),
    this.newDate = const Value.absent(),
    this.newStartTime = const Value.absent(),
    this.newEndTime = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurrenceExceptionsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required DateTime originalDate,
    this.isCancelled = const Value.absent(),
    this.isDetached = const Value.absent(),
    this.detachedTaskId = const Value.absent(),
    this.newDate = const Value.absent(),
    this.newStartTime = const Value.absent(),
    this.newEndTime = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : taskId = Value(taskId),
        originalDate = Value(originalDate);
  static Insertable<RecurrenceExceptionEntry> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<DateTime>? originalDate,
    Expression<bool>? isCancelled,
    Expression<bool>? isDetached,
    Expression<int>? detachedTaskId,
    Expression<DateTime>? newDate,
    Expression<DateTime>? newStartTime,
    Expression<DateTime>? newEndTime,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (originalDate != null) 'original_date': originalDate,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (isDetached != null) 'is_detached': isDetached,
      if (detachedTaskId != null) 'detached_task_id': detachedTaskId,
      if (newDate != null) 'new_date': newDate,
      if (newStartTime != null) 'new_start_time': newStartTime,
      if (newEndTime != null) 'new_end_time': newEndTime,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurrenceExceptionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? taskId,
      Value<DateTime>? originalDate,
      Value<bool>? isCancelled,
      Value<bool>? isDetached,
      Value<int?>? detachedTaskId,
      Value<DateTime?>? newDate,
      Value<DateTime?>? newStartTime,
      Value<DateTime?>? newEndTime,
      Value<DateTime>? createdAt}) {
    return RecurrenceExceptionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      originalDate: originalDate ?? this.originalDate,
      isCancelled: isCancelled ?? this.isCancelled,
      isDetached: isDetached ?? this.isDetached,
      detachedTaskId: detachedTaskId ?? this.detachedTaskId,
      newDate: newDate ?? this.newDate,
      newStartTime: newStartTime ?? this.newStartTime,
      newEndTime: newEndTime ?? this.newEndTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<DateTime>(originalDate.value);
    }
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<bool>(isCancelled.value);
    }
    if (isDetached.present) {
      map['is_detached'] = Variable<bool>(isDetached.value);
    }
    if (detachedTaskId.present) {
      map['detached_task_id'] = Variable<int>(detachedTaskId.value);
    }
    if (newDate.present) {
      map['new_date'] = Variable<DateTime>(newDate.value);
    }
    if (newStartTime.present) {
      map['new_start_time'] = Variable<DateTime>(newStartTime.value);
    }
    if (newEndTime.present) {
      map['new_end_time'] = Variable<DateTime>(newEndTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceExceptionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('originalDate: $originalDate, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('isDetached: $isDetached, ')
          ..write('detachedTaskId: $detachedTaskId, ')
          ..write('newDate: $newDate, ')
          ..write('newStartTime: $newStartTime, ')
          ..write('newEndTime: $newEndTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $RecurrenceRulesTable recurrenceRules =
      $RecurrenceRulesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskCommentsTable taskComments = $TaskCommentsTable(this);
  late final $RecurrenceExceptionsTable recurrenceExceptions =
      $RecurrenceExceptionsTable(this);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final TaskCommentDao taskCommentDao =
      TaskCommentDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [projects, recurrenceRules, tasks, taskComments, recurrenceExceptions];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tasks', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recurrence_rules',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tasks', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_comments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurrence_exceptions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurrence_exceptions', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<int> colorValue,
  Value<DateTime> createdAt,
  Value<bool> isArchived,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> colorValue,
  Value<DateTime> createdAt,
  Value<bool> isArchived,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.projects.id, db.tasks.projectId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.projectId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function({bool tasksRefs})> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            colorValue: colorValue,
            createdAt: createdAt,
            isArchived: isArchived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            colorValue: colorValue,
            createdAt: createdAt,
            isArchived: isArchived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function({bool tasksRefs})>;
typedef $$RecurrenceRulesTableCreateCompanionBuilder = RecurrenceRulesCompanion
    Function({
  Value<int> id,
  required RecurrenceFrequency frequency,
  Value<int> interval,
  Value<String?> byWeekDays,
  Value<RecurrenceEndType> endType,
  Value<DateTime?> untilDate,
  Value<int?> occurrenceCount,
  Value<DateTime> createdAt,
});
typedef $$RecurrenceRulesTableUpdateCompanionBuilder = RecurrenceRulesCompanion
    Function({
  Value<int> id,
  Value<RecurrenceFrequency> frequency,
  Value<int> interval,
  Value<String?> byWeekDays,
  Value<RecurrenceEndType> endType,
  Value<DateTime?> untilDate,
  Value<int?> occurrenceCount,
  Value<DateTime> createdAt,
});

final class $$RecurrenceRulesTableReferences extends BaseReferences<
    _$AppDatabase, $RecurrenceRulesTable, RecurrenceRuleEntry> {
  $$RecurrenceRulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(
              db.recurrenceRules.id, db.tasks.recurrenceRuleId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.recurrenceRuleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurrenceFrequency, RecurrenceFrequency, int>
      get frequency => $composableBuilder(
          column: $table.frequency,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byWeekDays => $composableBuilder(
      column: $table.byWeekDays, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurrenceEndType, RecurrenceEndType, int>
      get endType => $composableBuilder(
          column: $table.endType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get untilDate => $composableBuilder(
      column: $table.untilDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
      column: $table.occurrenceCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.recurrenceRuleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byWeekDays => $composableBuilder(
      column: $table.byWeekDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endType => $composableBuilder(
      column: $table.endType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get untilDate => $composableBuilder(
      column: $table.untilDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
      column: $table.occurrenceCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<String> get byWeekDays => $composableBuilder(
      column: $table.byWeekDays, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceEndType, int> get endType =>
      $composableBuilder(column: $table.endType, builder: (column) => column);

  GeneratedColumn<DateTime> get untilDate =>
      $composableBuilder(column: $table.untilDate, builder: (column) => column);

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
      column: $table.occurrenceCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.recurrenceRuleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurrenceRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurrenceRulesTable,
    RecurrenceRuleEntry,
    $$RecurrenceRulesTableFilterComposer,
    $$RecurrenceRulesTableOrderingComposer,
    $$RecurrenceRulesTableAnnotationComposer,
    $$RecurrenceRulesTableCreateCompanionBuilder,
    $$RecurrenceRulesTableUpdateCompanionBuilder,
    (RecurrenceRuleEntry, $$RecurrenceRulesTableReferences),
    RecurrenceRuleEntry,
    PrefetchHooks Function({bool tasksRefs})> {
  $$RecurrenceRulesTableTableManager(
      _$AppDatabase db, $RecurrenceRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<RecurrenceFrequency> frequency = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<String?> byWeekDays = const Value.absent(),
            Value<RecurrenceEndType> endType = const Value.absent(),
            Value<DateTime?> untilDate = const Value.absent(),
            Value<int?> occurrenceCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecurrenceRulesCompanion(
            id: id,
            frequency: frequency,
            interval: interval,
            byWeekDays: byWeekDays,
            endType: endType,
            untilDate: untilDate,
            occurrenceCount: occurrenceCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required RecurrenceFrequency frequency,
            Value<int> interval = const Value.absent(),
            Value<String?> byWeekDays = const Value.absent(),
            Value<RecurrenceEndType> endType = const Value.absent(),
            Value<DateTime?> untilDate = const Value.absent(),
            Value<int?> occurrenceCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecurrenceRulesCompanion.insert(
            id: id,
            frequency: frequency,
            interval: interval,
            byWeekDays: byWeekDays,
            endType: endType,
            untilDate: untilDate,
            occurrenceCount: occurrenceCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurrenceRulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RecurrenceRulesTableReferences
                            ._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurrenceRulesTableReferences(db, table, p0)
                                .tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recurrenceRuleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurrenceRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurrenceRulesTable,
    RecurrenceRuleEntry,
    $$RecurrenceRulesTableFilterComposer,
    $$RecurrenceRulesTableOrderingComposer,
    $$RecurrenceRulesTableAnnotationComposer,
    $$RecurrenceRulesTableCreateCompanionBuilder,
    $$RecurrenceRulesTableUpdateCompanionBuilder,
    (RecurrenceRuleEntry, $$RecurrenceRulesTableReferences),
    RecurrenceRuleEntry,
    PrefetchHooks Function({bool tasksRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> projectId,
  required String title,
  Value<String?> description,
  required DateTime startDate,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  Value<int?> recurrenceRuleId,
  required ActivityCategory category,
  Value<String?> location,
  Value<int?> reminderMinutesBefore,
  Value<int> colorValue,
  Value<bool> isCompleted,
  Value<bool> isArchived,
  Value<DateTime?> archivedAt,
  Value<bool> isLocked,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> projectId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> startDate,
  Value<int> startHour,
  Value<int> startMinute,
  Value<int> endHour,
  Value<int> endMinute,
  Value<int?> recurrenceRuleId,
  Value<ActivityCategory> category,
  Value<String?> location,
  Value<int?> reminderMinutesBefore,
  Value<int> colorValue,
  Value<bool> isCompleted,
  Value<bool> isArchived,
  Value<DateTime?> archivedAt,
  Value<bool> isLocked,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.tasks.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get projectId {
    if ($_item.projectId == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id($_item.projectId!));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RecurrenceRulesTable _recurrenceRuleIdTable(_$AppDatabase db) =>
      db.recurrenceRules.createAlias($_aliasNameGenerator(
          db.tasks.recurrenceRuleId, db.recurrenceRules.id));

  $$RecurrenceRulesTableProcessedTableManager? get recurrenceRuleId {
    if ($_item.recurrenceRuleId == null) return null;
    final manager =
        $$RecurrenceRulesTableTableManager($_db, $_db.recurrenceRules)
            .filter((f) => f.id($_item.recurrenceRuleId!));
    final item = $_typedResult.readTableOrNull(_recurrenceRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskCommentsTable, List<TaskComment>>
      _taskCommentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.taskComments,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.taskComments.taskId));

  $$TaskCommentsTableProcessedTableManager get taskCommentsRefs {
    final manager = $$TaskCommentsTableTableManager($_db, $_db.taskComments)
        .filter((f) => f.taskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_taskCommentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurrenceExceptionsTable,
      List<RecurrenceExceptionEntry>> _taskExceptionsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurrenceExceptions,
          aliasName: $_aliasNameGenerator(
              db.tasks.id, db.recurrenceExceptions.taskId));

  $$RecurrenceExceptionsTableProcessedTableManager get taskExceptions {
    final manager =
        $$RecurrenceExceptionsTableTableManager($_db, $_db.recurrenceExceptions)
            .filter((f) => f.taskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_taskExceptionsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurrenceExceptionsTable,
      List<RecurrenceExceptionEntry>> _detachedExceptionsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurrenceExceptions,
          aliasName: $_aliasNameGenerator(
              db.tasks.id, db.recurrenceExceptions.detachedTaskId));

  $$RecurrenceExceptionsTableProcessedTableManager get detachedExceptions {
    final manager =
        $$RecurrenceExceptionsTableTableManager($_db, $_db.recurrenceExceptions)
            .filter((f) => f.detachedTaskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_detachedExceptionsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivityCategory, ActivityCategory, int>
      get category => $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurrenceRulesTableFilterComposer get recurrenceRuleId {
    final $$RecurrenceRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurrenceRuleId,
        referencedTable: $db.recurrenceRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurrenceRulesTableFilterComposer(
              $db: $db,
              $table: $db.recurrenceRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskCommentsRefs(
      Expression<bool> Function($$TaskCommentsTableFilterComposer f) f) {
    final $$TaskCommentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskComments,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskCommentsTableFilterComposer(
              $db: $db,
              $table: $db.taskComments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> taskExceptions(
      Expression<bool> Function($$RecurrenceExceptionsTableFilterComposer f)
          f) {
    final $$RecurrenceExceptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurrenceExceptions,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurrenceExceptionsTableFilterComposer(
              $db: $db,
              $table: $db.recurrenceExceptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> detachedExceptions(
      Expression<bool> Function($$RecurrenceExceptionsTableFilterComposer f)
          f) {
    final $$RecurrenceExceptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurrenceExceptions,
        getReferencedColumn: (t) => t.detachedTaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurrenceExceptionsTableFilterComposer(
              $db: $db,
              $table: $db.recurrenceExceptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurrenceRulesTableOrderingComposer get recurrenceRuleId {
    final $$RecurrenceRulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurrenceRuleId,
        referencedTable: $db.recurrenceRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurrenceRulesTableOrderingComposer(
              $db: $db,
              $table: $db.recurrenceRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurrenceRulesTableAnnotationComposer get recurrenceRuleId {
    final $$RecurrenceRulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurrenceRuleId,
        referencedTable: $db.recurrenceRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurrenceRulesTableAnnotationComposer(
              $db: $db,
              $table: $db.recurrenceRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskCommentsRefs<T extends Object>(
      Expression<T> Function($$TaskCommentsTableAnnotationComposer a) f) {
    final $$TaskCommentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskComments,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskCommentsTableAnnotationComposer(
              $db: $db,
              $table: $db.taskComments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> taskExceptions<T extends Object>(
      Expression<T> Function($$RecurrenceExceptionsTableAnnotationComposer a)
          f) {
    final $$RecurrenceExceptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurrenceExceptions,
            getReferencedColumn: (t) => t.taskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurrenceExceptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurrenceExceptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> detachedExceptions<T extends Object>(
      Expression<T> Function($$RecurrenceExceptionsTableAnnotationComposer a)
          f) {
    final $$RecurrenceExceptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurrenceExceptions,
            getReferencedColumn: (t) => t.detachedTaskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurrenceExceptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurrenceExceptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool projectId,
        bool recurrenceRuleId,
        bool taskCommentsRefs,
        bool taskExceptions,
        bool detachedExceptions})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<int> startHour = const Value.absent(),
            Value<int> startMinute = const Value.absent(),
            Value<int> endHour = const Value.absent(),
            Value<int> endMinute = const Value.absent(),
            Value<int?> recurrenceRuleId = const Value.absent(),
            Value<ActivityCategory> category = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            projectId: projectId,
            title: title,
            description: description,
            startDate: startDate,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            recurrenceRuleId: recurrenceRuleId,
            category: category,
            location: location,
            reminderMinutesBefore: reminderMinutesBefore,
            colorValue: colorValue,
            isCompleted: isCompleted,
            isArchived: isArchived,
            archivedAt: archivedAt,
            isLocked: isLocked,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime startDate,
            required int startHour,
            required int startMinute,
            required int endHour,
            required int endMinute,
            Value<int?> recurrenceRuleId = const Value.absent(),
            required ActivityCategory category,
            Value<String?> location = const Value.absent(),
            Value<int?> reminderMinutesBefore = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            projectId: projectId,
            title: title,
            description: description,
            startDate: startDate,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            recurrenceRuleId: recurrenceRuleId,
            category: category,
            location: location,
            reminderMinutesBefore: reminderMinutesBefore,
            colorValue: colorValue,
            isCompleted: isCompleted,
            isArchived: isArchived,
            archivedAt: archivedAt,
            isLocked: isLocked,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false,
              recurrenceRuleId = false,
              taskCommentsRefs = false,
              taskExceptions = false,
              detachedExceptions = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskCommentsRefs) db.taskComments,
                if (taskExceptions) db.recurrenceExceptions,
                if (detachedExceptions) db.recurrenceExceptions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TasksTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (recurrenceRuleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurrenceRuleId,
                    referencedTable:
                        $$TasksTableReferences._recurrenceRuleIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._recurrenceRuleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskCommentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskCommentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskCommentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (taskExceptions)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskExceptionsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskExceptions,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (detachedExceptions)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._detachedExceptionsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .detachedExceptions,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.detachedTaskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool projectId,
        bool recurrenceRuleId,
        bool taskCommentsRefs,
        bool taskExceptions,
        bool detachedExceptions})>;
typedef $$TaskCommentsTableCreateCompanionBuilder = TaskCommentsCompanion
    Function({
  Value<int> id,
  required int taskId,
  required String content,
  Value<DateTime> createdAt,
});
typedef $$TaskCommentsTableUpdateCompanionBuilder = TaskCommentsCompanion
    Function({
  Value<int> id,
  Value<int> taskId,
  Value<String> content,
  Value<DateTime> createdAt,
});

final class $$TaskCommentsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskCommentsTable, TaskComment> {
  $$TaskCommentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.taskComments.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    if ($_item.taskId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.taskId!));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskCommentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskCommentsTable,
    TaskComment,
    $$TaskCommentsTableFilterComposer,
    $$TaskCommentsTableOrderingComposer,
    $$TaskCommentsTableAnnotationComposer,
    $$TaskCommentsTableCreateCompanionBuilder,
    $$TaskCommentsTableUpdateCompanionBuilder,
    (TaskComment, $$TaskCommentsTableReferences),
    TaskComment,
    PrefetchHooks Function({bool taskId})> {
  $$TaskCommentsTableTableManager(_$AppDatabase db, $TaskCommentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TaskCommentsCompanion(
            id: id,
            taskId: taskId,
            content: content,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required String content,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TaskCommentsCompanion.insert(
            id: id,
            taskId: taskId,
            content: content,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskCommentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskCommentsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskCommentsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TaskCommentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskCommentsTable,
    TaskComment,
    $$TaskCommentsTableFilterComposer,
    $$TaskCommentsTableOrderingComposer,
    $$TaskCommentsTableAnnotationComposer,
    $$TaskCommentsTableCreateCompanionBuilder,
    $$TaskCommentsTableUpdateCompanionBuilder,
    (TaskComment, $$TaskCommentsTableReferences),
    TaskComment,
    PrefetchHooks Function({bool taskId})>;
typedef $$RecurrenceExceptionsTableCreateCompanionBuilder
    = RecurrenceExceptionsCompanion Function({
  Value<int> id,
  required int taskId,
  required DateTime originalDate,
  Value<bool> isCancelled,
  Value<bool> isDetached,
  Value<int?> detachedTaskId,
  Value<DateTime?> newDate,
  Value<DateTime?> newStartTime,
  Value<DateTime?> newEndTime,
  Value<DateTime> createdAt,
});
typedef $$RecurrenceExceptionsTableUpdateCompanionBuilder
    = RecurrenceExceptionsCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<DateTime> originalDate,
  Value<bool> isCancelled,
  Value<bool> isDetached,
  Value<int?> detachedTaskId,
  Value<DateTime?> newDate,
  Value<DateTime?> newStartTime,
  Value<DateTime?> newEndTime,
  Value<DateTime> createdAt,
});

final class $$RecurrenceExceptionsTableReferences extends BaseReferences<
    _$AppDatabase, $RecurrenceExceptionsTable, RecurrenceExceptionEntry> {
  $$RecurrenceExceptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
      $_aliasNameGenerator(db.recurrenceExceptions.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    if ($_item.taskId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.taskId!));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TasksTable _detachedTaskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias($_aliasNameGenerator(
          db.recurrenceExceptions.detachedTaskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get detachedTaskId {
    if ($_item.detachedTaskId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.detachedTaskId!));
    final item = $_typedResult.readTableOrNull(_detachedTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurrenceExceptionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get originalDate => $composableBuilder(
      column: $table.originalDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDetached => $composableBuilder(
      column: $table.isDetached, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newDate => $composableBuilder(
      column: $table.newDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newStartTime => $composableBuilder(
      column: $table.newStartTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newEndTime => $composableBuilder(
      column: $table.newEndTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableFilterComposer get detachedTaskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.detachedTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurrenceExceptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get originalDate => $composableBuilder(
      column: $table.originalDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDetached => $composableBuilder(
      column: $table.isDetached, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newDate => $composableBuilder(
      column: $table.newDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newStartTime => $composableBuilder(
      column: $table.newStartTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newEndTime => $composableBuilder(
      column: $table.newEndTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableOrderingComposer get detachedTaskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.detachedTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurrenceExceptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get originalDate => $composableBuilder(
      column: $table.originalDate, builder: (column) => column);

  GeneratedColumn<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => column);

  GeneratedColumn<bool> get isDetached => $composableBuilder(
      column: $table.isDetached, builder: (column) => column);

  GeneratedColumn<DateTime> get newDate =>
      $composableBuilder(column: $table.newDate, builder: (column) => column);

  GeneratedColumn<DateTime> get newStartTime => $composableBuilder(
      column: $table.newStartTime, builder: (column) => column);

  GeneratedColumn<DateTime> get newEndTime => $composableBuilder(
      column: $table.newEndTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableAnnotationComposer get detachedTaskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.detachedTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurrenceExceptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurrenceExceptionsTable,
    RecurrenceExceptionEntry,
    $$RecurrenceExceptionsTableFilterComposer,
    $$RecurrenceExceptionsTableOrderingComposer,
    $$RecurrenceExceptionsTableAnnotationComposer,
    $$RecurrenceExceptionsTableCreateCompanionBuilder,
    $$RecurrenceExceptionsTableUpdateCompanionBuilder,
    (RecurrenceExceptionEntry, $$RecurrenceExceptionsTableReferences),
    RecurrenceExceptionEntry,
    PrefetchHooks Function({bool taskId, bool detachedTaskId})> {
  $$RecurrenceExceptionsTableTableManager(
      _$AppDatabase db, $RecurrenceExceptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceExceptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceExceptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceExceptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<DateTime> originalDate = const Value.absent(),
            Value<bool> isCancelled = const Value.absent(),
            Value<bool> isDetached = const Value.absent(),
            Value<int?> detachedTaskId = const Value.absent(),
            Value<DateTime?> newDate = const Value.absent(),
            Value<DateTime?> newStartTime = const Value.absent(),
            Value<DateTime?> newEndTime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecurrenceExceptionsCompanion(
            id: id,
            taskId: taskId,
            originalDate: originalDate,
            isCancelled: isCancelled,
            isDetached: isDetached,
            detachedTaskId: detachedTaskId,
            newDate: newDate,
            newStartTime: newStartTime,
            newEndTime: newEndTime,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required DateTime originalDate,
            Value<bool> isCancelled = const Value.absent(),
            Value<bool> isDetached = const Value.absent(),
            Value<int?> detachedTaskId = const Value.absent(),
            Value<DateTime?> newDate = const Value.absent(),
            Value<DateTime?> newStartTime = const Value.absent(),
            Value<DateTime?> newEndTime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecurrenceExceptionsCompanion.insert(
            id: id,
            taskId: taskId,
            originalDate: originalDate,
            isCancelled: isCancelled,
            isDetached: isDetached,
            detachedTaskId: detachedTaskId,
            newDate: newDate,
            newStartTime: newStartTime,
            newEndTime: newEndTime,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurrenceExceptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false, detachedTaskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$RecurrenceExceptionsTableReferences._taskIdTable(db),
                    referencedColumn: $$RecurrenceExceptionsTableReferences
                        ._taskIdTable(db)
                        .id,
                  ) as T;
                }
                if (detachedTaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.detachedTaskId,
                    referencedTable: $$RecurrenceExceptionsTableReferences
                        ._detachedTaskIdTable(db),
                    referencedColumn: $$RecurrenceExceptionsTableReferences
                        ._detachedTaskIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurrenceExceptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecurrenceExceptionsTable,
        RecurrenceExceptionEntry,
        $$RecurrenceExceptionsTableFilterComposer,
        $$RecurrenceExceptionsTableOrderingComposer,
        $$RecurrenceExceptionsTableAnnotationComposer,
        $$RecurrenceExceptionsTableCreateCompanionBuilder,
        $$RecurrenceExceptionsTableUpdateCompanionBuilder,
        (RecurrenceExceptionEntry, $$RecurrenceExceptionsTableReferences),
        RecurrenceExceptionEntry,
        PrefetchHooks Function({bool taskId, bool detachedTaskId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$RecurrenceRulesTableTableManager get recurrenceRules =>
      $$RecurrenceRulesTableTableManager(_db, _db.recurrenceRules);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskCommentsTableTableManager get taskComments =>
      $$TaskCommentsTableTableManager(_db, _db.taskComments);
  $$RecurrenceExceptionsTableTableManager get recurrenceExceptions =>
      $$RecurrenceExceptionsTableTableManager(_db, _db.recurrenceExceptions);
}
