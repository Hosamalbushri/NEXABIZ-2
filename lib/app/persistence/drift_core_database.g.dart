// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_core_database.dart';

// ignore_for_file: type=lint
class $CoreCompaniesTable extends CoreCompanies
    with TableInfo<$CoreCompaniesTable, CoreCompanyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreCompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreCompanyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoreCompanyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreCompanyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CoreCompaniesTable createAlias(String alias) {
    return $CoreCompaniesTable(attachedDatabase, alias);
  }
}

class CoreCompanyRow extends DataClass implements Insertable<CoreCompanyRow> {
  final String id;
  final String? code;
  final String? name;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const CoreCompanyRow({
    required this.id,
    this.code,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CoreCompaniesCompanion toCompanion(bool nullToAbsent) {
    return CoreCompaniesCompanion(
      id: Value(id),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CoreCompanyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreCompanyRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String?>(json['name']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String?>(name),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CoreCompanyRow copyWith({
    String? id,
    Value<String?> code = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CoreCompanyRow(
    id: id ?? this.id,
    code: code.present ? code.value : this.code,
    name: name.present ? name.value : this.name,
    status: status.present ? status.value : this.status,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CoreCompanyRow copyWithCompanion(CoreCompaniesCompanion data) {
    return CoreCompanyRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreCompanyRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreCompanyRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoreCompaniesCompanion extends UpdateCompanion<CoreCompanyRow> {
  final Value<String> id;
  final Value<String?> code;
  final Value<String?> name;
  final Value<String?> status;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CoreCompaniesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreCompaniesCompanion.insert({
    required String id,
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CoreCompanyRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreCompaniesCompanion copyWith({
    Value<String>? id,
    Value<String?>? code,
    Value<String?>? name,
    Value<String?>? status,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoreCompaniesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreCompaniesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreUsersTable extends CoreUsers
    with TableInfo<$CoreUsersTable, CoreUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    name,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoreUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreUserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CoreUsersTable createAlias(String alias) {
    return $CoreUsersTable(attachedDatabase, alias);
  }
}

class CoreUserRow extends DataClass implements Insertable<CoreUserRow> {
  final String id;
  final String? email;
  final String? name;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const CoreUserRow({
    required this.id,
    this.email,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CoreUsersCompanion toCompanion(bool nullToAbsent) {
    return CoreUsersCompanion(
      id: Value(id),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CoreUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreUserRow(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String?>(json['email']),
      name: serializer.fromJson<String?>(json['name']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String?>(email),
      'name': serializer.toJson<String?>(name),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CoreUserRow copyWith({
    String? id,
    Value<String?> email = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CoreUserRow(
    id: id ?? this.id,
    email: email.present ? email.value : this.email,
    name: name.present ? name.value : this.name,
    status: status.present ? status.value : this.status,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CoreUserRow copyWithCompanion(CoreUsersCompanion data) {
    return CoreUserRow(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreUserRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, name, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreUserRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoreUsersCompanion extends UpdateCompanion<CoreUserRow> {
  final Value<String> id;
  final Value<String?> email;
  final Value<String?> name;
  final Value<String?> status;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CoreUsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreUsersCompanion.insert({
    required String id,
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CoreUserRow> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreUsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? email,
    Value<String?>? name,
    Value<String?>? status,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoreUsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreUsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreCompanyMembershipsTable extends CoreCompanyMemberships
    with TableInfo<$CoreCompanyMembershipsTable, CoreCompanyMembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreCompanyMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_users (id)',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_companies (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    companyId,
    role,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_company_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreCompanyMembershipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, userId},
  ];
  @override
  CoreCompanyMembershipRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreCompanyMembershipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CoreCompanyMembershipsTable createAlias(String alias) {
    return $CoreCompanyMembershipsTable(attachedDatabase, alias);
  }
}

class CoreCompanyMembershipRow extends DataClass
    implements Insertable<CoreCompanyMembershipRow> {
  final String id;
  final String userId;
  final String companyId;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const CoreCompanyMembershipRow({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.role,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['company_id'] = Variable<String>(companyId);
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CoreCompanyMembershipsCompanion toCompanion(bool nullToAbsent) {
    return CoreCompanyMembershipsCompanion(
      id: Value(id),
      userId: Value(userId),
      companyId: Value(companyId),
      role: Value(role),
      status: Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CoreCompanyMembershipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreCompanyMembershipRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      companyId: serializer.fromJson<String>(json['companyId']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'companyId': serializer.toJson<String>(companyId),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CoreCompanyMembershipRow copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? role,
    String? status,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CoreCompanyMembershipRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    companyId: companyId ?? this.companyId,
    role: role ?? this.role,
    status: status ?? this.status,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CoreCompanyMembershipRow copyWithCompanion(
    CoreCompanyMembershipsCompanion data,
  ) {
    return CoreCompanyMembershipRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreCompanyMembershipRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('companyId: $companyId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, companyId, role, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreCompanyMembershipRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.companyId == this.companyId &&
          other.role == this.role &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoreCompanyMembershipsCompanion
    extends UpdateCompanion<CoreCompanyMembershipRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> companyId;
  final Value<String> role;
  final Value<String> status;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CoreCompanyMembershipsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreCompanyMembershipsCompanion.insert({
    required String id,
    required String userId,
    required String companyId,
    required String role,
    required String status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       companyId = Value(companyId),
       role = Value(role),
       status = Value(status);
  static Insertable<CoreCompanyMembershipRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? companyId,
    Expression<String>? role,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (companyId != null) 'company_id': companyId,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreCompanyMembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? companyId,
    Value<String>? role,
    Value<String>? status,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoreCompanyMembershipsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreCompanyMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('companyId: $companyId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreCredentialsTable extends CoreCredentials
    with TableInfo<$CoreCredentialsTable, CoreCredentialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_users (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parametersMeta = const VerificationMeta(
    'parameters',
  );
  @override
  late final GeneratedColumn<String> parameters = GeneratedColumn<String>(
    'parameters',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifierMeta = const VerificationMeta(
    'verifier',
  );
  @override
  late final GeneratedColumn<String> verifier = GeneratedColumn<String>(
    'verifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    kind,
    algorithm,
    parameters,
    salt,
    verifier,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreCredentialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    } else if (isInserting) {
      context.missing(_algorithmMeta);
    }
    if (data.containsKey('parameters')) {
      context.handle(
        _parametersMeta,
        parameters.isAcceptableOrUnknown(data['parameters']!, _parametersMeta),
      );
    } else if (isInserting) {
      context.missing(_parametersMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('verifier')) {
      context.handle(
        _verifierMeta,
        verifier.isAcceptableOrUnknown(data['verifier']!, _verifierMeta),
      );
    } else if (isInserting) {
      context.missing(_verifierMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, kind};
  @override
  CoreCredentialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreCredentialRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      )!,
      parameters: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      verifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verifier'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoreCredentialsTable createAlias(String alias) {
    return $CoreCredentialsTable(attachedDatabase, alias);
  }
}

class CoreCredentialRow extends DataClass
    implements Insertable<CoreCredentialRow> {
  final String userId;
  final String kind;
  final String algorithm;
  final String parameters;
  final String salt;
  final String verifier;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CoreCredentialRow({
    required this.userId,
    required this.kind,
    required this.algorithm,
    required this.parameters,
    required this.salt,
    required this.verifier,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['kind'] = Variable<String>(kind);
    map['algorithm'] = Variable<String>(algorithm);
    map['parameters'] = Variable<String>(parameters);
    map['salt'] = Variable<String>(salt);
    map['verifier'] = Variable<String>(verifier);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoreCredentialsCompanion toCompanion(bool nullToAbsent) {
    return CoreCredentialsCompanion(
      userId: Value(userId),
      kind: Value(kind),
      algorithm: Value(algorithm),
      parameters: Value(parameters),
      salt: Value(salt),
      verifier: Value(verifier),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CoreCredentialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreCredentialRow(
      userId: serializer.fromJson<String>(json['userId']),
      kind: serializer.fromJson<String>(json['kind']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
      parameters: serializer.fromJson<String>(json['parameters']),
      salt: serializer.fromJson<String>(json['salt']),
      verifier: serializer.fromJson<String>(json['verifier']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'kind': serializer.toJson<String>(kind),
      'algorithm': serializer.toJson<String>(algorithm),
      'parameters': serializer.toJson<String>(parameters),
      'salt': serializer.toJson<String>(salt),
      'verifier': serializer.toJson<String>(verifier),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CoreCredentialRow copyWith({
    String? userId,
    String? kind,
    String? algorithm,
    String? parameters,
    String? salt,
    String? verifier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CoreCredentialRow(
    userId: userId ?? this.userId,
    kind: kind ?? this.kind,
    algorithm: algorithm ?? this.algorithm,
    parameters: parameters ?? this.parameters,
    salt: salt ?? this.salt,
    verifier: verifier ?? this.verifier,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CoreCredentialRow copyWithCompanion(CoreCredentialsCompanion data) {
    return CoreCredentialRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      kind: data.kind.present ? data.kind.value : this.kind,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      parameters: data.parameters.present
          ? data.parameters.value
          : this.parameters,
      salt: data.salt.present ? data.salt.value : this.salt,
      verifier: data.verifier.present ? data.verifier.value : this.verifier,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreCredentialRow(')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('algorithm: $algorithm, ')
          ..write('parameters: $parameters, ')
          ..write('salt: $salt, ')
          ..write('verifier: $verifier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    kind,
    algorithm,
    parameters,
    salt,
    verifier,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreCredentialRow &&
          other.userId == this.userId &&
          other.kind == this.kind &&
          other.algorithm == this.algorithm &&
          other.parameters == this.parameters &&
          other.salt == this.salt &&
          other.verifier == this.verifier &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoreCredentialsCompanion extends UpdateCompanion<CoreCredentialRow> {
  final Value<String> userId;
  final Value<String> kind;
  final Value<String> algorithm;
  final Value<String> parameters;
  final Value<String> salt;
  final Value<String> verifier;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CoreCredentialsCompanion({
    this.userId = const Value.absent(),
    this.kind = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.parameters = const Value.absent(),
    this.salt = const Value.absent(),
    this.verifier = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreCredentialsCompanion.insert({
    required String userId,
    required String kind,
    required String algorithm,
    required String parameters,
    required String salt,
    required String verifier,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       kind = Value(kind),
       algorithm = Value(algorithm),
       parameters = Value(parameters),
       salt = Value(salt),
       verifier = Value(verifier),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CoreCredentialRow> custom({
    Expression<String>? userId,
    Expression<String>? kind,
    Expression<String>? algorithm,
    Expression<String>? parameters,
    Expression<String>? salt,
    Expression<String>? verifier,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (kind != null) 'kind': kind,
      if (algorithm != null) 'algorithm': algorithm,
      if (parameters != null) 'parameters': parameters,
      if (salt != null) 'salt': salt,
      if (verifier != null) 'verifier': verifier,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreCredentialsCompanion copyWith({
    Value<String>? userId,
    Value<String>? kind,
    Value<String>? algorithm,
    Value<String>? parameters,
    Value<String>? salt,
    Value<String>? verifier,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoreCredentialsCompanion(
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      algorithm: algorithm ?? this.algorithm,
      parameters: parameters ?? this.parameters,
      salt: salt ?? this.salt,
      verifier: verifier ?? this.verifier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(parameters.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (verifier.present) {
      map['verifier'] = Variable<String>(verifier.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreCredentialsCompanion(')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('algorithm: $algorithm, ')
          ..write('parameters: $parameters, ')
          ..write('salt: $salt, ')
          ..write('verifier: $verifier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreLoginAttemptsTable extends CoreLoginAttempts
    with TableInfo<$CoreLoginAttemptsTable, CoreLoginAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreLoginAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identifierHashMeta = const VerificationMeta(
    'identifierHash',
  );
  @override
  late final GeneratedColumn<String> identifierHash = GeneratedColumn<String>(
    'identifier_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    identifierHash,
    attemptCount,
    lockedUntil,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_login_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreLoginAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identifier_hash')) {
      context.handle(
        _identifierHashMeta,
        identifierHash.isAcceptableOrUnknown(
          data['identifier_hash']!,
          _identifierHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identifierHashMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptCountMeta);
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAttemptAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identifierHash};
  @override
  CoreLoginAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreLoginAttemptRow(
      identifierHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifier_hash'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      )!,
    );
  }

  @override
  $CoreLoginAttemptsTable createAlias(String alias) {
    return $CoreLoginAttemptsTable(attachedDatabase, alias);
  }
}

class CoreLoginAttemptRow extends DataClass
    implements Insertable<CoreLoginAttemptRow> {
  final String identifierHash;
  final int attemptCount;
  final DateTime? lockedUntil;
  final DateTime lastAttemptAt;
  const CoreLoginAttemptRow({
    required this.identifierHash,
    required this.attemptCount,
    this.lockedUntil,
    required this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identifier_hash'] = Variable<String>(identifierHash);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    return map;
  }

  CoreLoginAttemptsCompanion toCompanion(bool nullToAbsent) {
    return CoreLoginAttemptsCompanion(
      identifierHash: Value(identifierHash),
      attemptCount: Value(attemptCount),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      lastAttemptAt: Value(lastAttemptAt),
    );
  }

  factory CoreLoginAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreLoginAttemptRow(
      identifierHash: serializer.fromJson<String>(json['identifierHash']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      lastAttemptAt: serializer.fromJson<DateTime>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identifierHash': serializer.toJson<String>(identifierHash),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'lastAttemptAt': serializer.toJson<DateTime>(lastAttemptAt),
    };
  }

  CoreLoginAttemptRow copyWith({
    String? identifierHash,
    int? attemptCount,
    Value<DateTime?> lockedUntil = const Value.absent(),
    DateTime? lastAttemptAt,
  }) => CoreLoginAttemptRow(
    identifierHash: identifierHash ?? this.identifierHash,
    attemptCount: attemptCount ?? this.attemptCount,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
  );
  CoreLoginAttemptRow copyWithCompanion(CoreLoginAttemptsCompanion data) {
    return CoreLoginAttemptRow(
      identifierHash: data.identifierHash.present
          ? data.identifierHash.value
          : this.identifierHash,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreLoginAttemptRow(')
          ..write('identifierHash: $identifierHash, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(identifierHash, attemptCount, lockedUntil, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreLoginAttemptRow &&
          other.identifierHash == this.identifierHash &&
          other.attemptCount == this.attemptCount &&
          other.lockedUntil == this.lockedUntil &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class CoreLoginAttemptsCompanion extends UpdateCompanion<CoreLoginAttemptRow> {
  final Value<String> identifierHash;
  final Value<int> attemptCount;
  final Value<DateTime?> lockedUntil;
  final Value<DateTime> lastAttemptAt;
  final Value<int> rowid;
  const CoreLoginAttemptsCompanion({
    this.identifierHash = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreLoginAttemptsCompanion.insert({
    required String identifierHash,
    required int attemptCount,
    this.lockedUntil = const Value.absent(),
    required DateTime lastAttemptAt,
    this.rowid = const Value.absent(),
  }) : identifierHash = Value(identifierHash),
       attemptCount = Value(attemptCount),
       lastAttemptAt = Value(lastAttemptAt);
  static Insertable<CoreLoginAttemptRow> custom({
    Expression<String>? identifierHash,
    Expression<int>? attemptCount,
    Expression<DateTime>? lockedUntil,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identifierHash != null) 'identifier_hash': identifierHash,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreLoginAttemptsCompanion copyWith({
    Value<String>? identifierHash,
    Value<int>? attemptCount,
    Value<DateTime?>? lockedUntil,
    Value<DateTime>? lastAttemptAt,
    Value<int>? rowid,
  }) {
    return CoreLoginAttemptsCompanion(
      identifierHash: identifierHash ?? this.identifierHash,
      attemptCount: attemptCount ?? this.attemptCount,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identifierHash.present) {
      map['identifier_hash'] = Variable<String>(identifierHash.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreLoginAttemptsCompanion(')
          ..write('identifierHash: $identifierHash, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreRolesTable extends CoreRoles
    with TableInfo<$CoreRolesTable, CoreRoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_companies (id)',
    ),
  );
  static const VerificationMeta _roleKeyMeta = const VerificationMeta(
    'roleKey',
  );
  @override
  late final GeneratedColumn<String> roleKey = GeneratedColumn<String>(
    'role_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    companyId,
    roleKey,
    name,
    normalizedName,
    description,
    isBuiltin,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreRoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('role_key')) {
      context.handle(
        _roleKeyMeta,
        roleKey.isAcceptableOrUnknown(data['role_key']!, _roleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_roleKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoreRoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreRoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      ),
      roleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoreRolesTable createAlias(String alias) {
    return $CoreRolesTable(attachedDatabase, alias);
  }
}

class CoreRoleRow extends DataClass implements Insertable<CoreRoleRow> {
  final String id;
  final String scope;
  final String? companyId;
  final String roleKey;
  final String? name;
  final String? normalizedName;
  final String? description;
  final bool isBuiltin;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CoreRoleRow({
    required this.id,
    required this.scope,
    this.companyId,
    required this.roleKey,
    this.name,
    this.normalizedName,
    this.description,
    required this.isBuiltin,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    map['role_key'] = Variable<String>(roleKey);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || normalizedName != null) {
      map['normalized_name'] = Variable<String>(normalizedName);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoreRolesCompanion toCompanion(bool nullToAbsent) {
    return CoreRolesCompanion(
      id: Value(id),
      scope: Value(scope),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      roleKey: Value(roleKey),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      normalizedName: normalizedName == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isBuiltin: Value(isBuiltin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CoreRoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreRoleRow(
      id: serializer.fromJson<String>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      companyId: serializer.fromJson<String?>(json['companyId']),
      roleKey: serializer.fromJson<String>(json['roleKey']),
      name: serializer.fromJson<String?>(json['name']),
      normalizedName: serializer.fromJson<String?>(json['normalizedName']),
      description: serializer.fromJson<String?>(json['description']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scope': serializer.toJson<String>(scope),
      'companyId': serializer.toJson<String?>(companyId),
      'roleKey': serializer.toJson<String>(roleKey),
      'name': serializer.toJson<String?>(name),
      'normalizedName': serializer.toJson<String?>(normalizedName),
      'description': serializer.toJson<String?>(description),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CoreRoleRow copyWith({
    String? id,
    String? scope,
    Value<String?> companyId = const Value.absent(),
    String? roleKey,
    Value<String?> name = const Value.absent(),
    Value<String?> normalizedName = const Value.absent(),
    Value<String?> description = const Value.absent(),
    bool? isBuiltin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CoreRoleRow(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    companyId: companyId.present ? companyId.value : this.companyId,
    roleKey: roleKey ?? this.roleKey,
    name: name.present ? name.value : this.name,
    normalizedName: normalizedName.present
        ? normalizedName.value
        : this.normalizedName,
    description: description.present ? description.value : this.description,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CoreRoleRow copyWithCompanion(CoreRolesCompanion data) {
    return CoreRoleRow(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      roleKey: data.roleKey.present ? data.roleKey.value : this.roleKey,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      description: data.description.present
          ? data.description.value
          : this.description,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreRoleRow(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('companyId: $companyId, ')
          ..write('roleKey: $roleKey, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('description: $description, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    companyId,
    roleKey,
    name,
    normalizedName,
    description,
    isBuiltin,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreRoleRow &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.companyId == this.companyId &&
          other.roleKey == this.roleKey &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.description == this.description &&
          other.isBuiltin == this.isBuiltin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoreRolesCompanion extends UpdateCompanion<CoreRoleRow> {
  final Value<String> id;
  final Value<String> scope;
  final Value<String?> companyId;
  final Value<String> roleKey;
  final Value<String?> name;
  final Value<String?> normalizedName;
  final Value<String?> description;
  final Value<bool> isBuiltin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CoreRolesCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.companyId = const Value.absent(),
    this.roleKey = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.description = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreRolesCompanion.insert({
    required String id,
    required String scope,
    this.companyId = const Value.absent(),
    required String roleKey,
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.description = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scope = Value(scope),
       roleKey = Value(roleKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CoreRoleRow> custom({
    Expression<String>? id,
    Expression<String>? scope,
    Expression<String>? companyId,
    Expression<String>? roleKey,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? description,
    Expression<bool>? isBuiltin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (companyId != null) 'company_id': companyId,
      if (roleKey != null) 'role_key': roleKey,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (description != null) 'description': description,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreRolesCompanion copyWith({
    Value<String>? id,
    Value<String>? scope,
    Value<String?>? companyId,
    Value<String>? roleKey,
    Value<String?>? name,
    Value<String?>? normalizedName,
    Value<String?>? description,
    Value<bool>? isBuiltin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoreRolesCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      companyId: companyId ?? this.companyId,
      roleKey: roleKey ?? this.roleKey,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      description: description ?? this.description,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (roleKey.present) {
      map['role_key'] = Variable<String>(roleKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreRolesCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('companyId: $companyId, ')
          ..write('roleKey: $roleKey, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('description: $description, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreMembershipRolesTable extends CoreMembershipRoles
    with TableInfo<$CoreMembershipRolesTable, CoreMembershipRoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreMembershipRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  @override
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_company_memberships (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_roles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [membershipId, roleId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_membership_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreMembershipRoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {membershipId, roleId};
  @override
  CoreMembershipRoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreMembershipRoleRow(
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoreMembershipRolesTable createAlias(String alias) {
    return $CoreMembershipRolesTable(attachedDatabase, alias);
  }
}

class CoreMembershipRoleRow extends DataClass
    implements Insertable<CoreMembershipRoleRow> {
  final String membershipId;
  final String roleId;
  final DateTime createdAt;
  const CoreMembershipRoleRow({
    required this.membershipId,
    required this.roleId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['membership_id'] = Variable<String>(membershipId);
    map['role_id'] = Variable<String>(roleId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CoreMembershipRolesCompanion toCompanion(bool nullToAbsent) {
    return CoreMembershipRolesCompanion(
      membershipId: Value(membershipId),
      roleId: Value(roleId),
      createdAt: Value(createdAt),
    );
  }

  factory CoreMembershipRoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreMembershipRoleRow(
      membershipId: serializer.fromJson<String>(json['membershipId']),
      roleId: serializer.fromJson<String>(json['roleId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'membershipId': serializer.toJson<String>(membershipId),
      'roleId': serializer.toJson<String>(roleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CoreMembershipRoleRow copyWith({
    String? membershipId,
    String? roleId,
    DateTime? createdAt,
  }) => CoreMembershipRoleRow(
    membershipId: membershipId ?? this.membershipId,
    roleId: roleId ?? this.roleId,
    createdAt: createdAt ?? this.createdAt,
  );
  CoreMembershipRoleRow copyWithCompanion(CoreMembershipRolesCompanion data) {
    return CoreMembershipRoleRow(
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreMembershipRoleRow(')
          ..write('membershipId: $membershipId, ')
          ..write('roleId: $roleId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(membershipId, roleId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreMembershipRoleRow &&
          other.membershipId == this.membershipId &&
          other.roleId == this.roleId &&
          other.createdAt == this.createdAt);
}

class CoreMembershipRolesCompanion
    extends UpdateCompanion<CoreMembershipRoleRow> {
  final Value<String> membershipId;
  final Value<String> roleId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CoreMembershipRolesCompanion({
    this.membershipId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreMembershipRolesCompanion.insert({
    required String membershipId,
    required String roleId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : membershipId = Value(membershipId),
       roleId = Value(roleId),
       createdAt = Value(createdAt);
  static Insertable<CoreMembershipRoleRow> custom({
    Expression<String>? membershipId,
    Expression<String>? roleId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (membershipId != null) 'membership_id': membershipId,
      if (roleId != null) 'role_id': roleId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreMembershipRolesCompanion copyWith({
    Value<String>? membershipId,
    Value<String>? roleId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CoreMembershipRolesCompanion(
      membershipId: membershipId ?? this.membershipId,
      roleId: roleId ?? this.roleId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreMembershipRolesCompanion(')
          ..write('membershipId: $membershipId, ')
          ..write('roleId: $roleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoreRolePermissionsTable extends CoreRolePermissions
    with TableInfo<$CoreRolePermissionsTable, CoreRolePermissionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoreRolePermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_roles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _permissionIdMeta = const VerificationMeta(
    'permissionId',
  );
  @override
  late final GeneratedColumn<String> permissionId = GeneratedColumn<String>(
    'permission_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [roleId, permissionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_role_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreRolePermissionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('permission_id')) {
      context.handle(
        _permissionIdMeta,
        permissionId.isAcceptableOrUnknown(
          data['permission_id']!,
          _permissionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roleId, permissionId};
  @override
  CoreRolePermissionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreRolePermissionRow(
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      )!,
      permissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoreRolePermissionsTable createAlias(String alias) {
    return $CoreRolePermissionsTable(attachedDatabase, alias);
  }
}

class CoreRolePermissionRow extends DataClass
    implements Insertable<CoreRolePermissionRow> {
  final String roleId;
  final String permissionId;
  final DateTime createdAt;
  const CoreRolePermissionRow({
    required this.roleId,
    required this.permissionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role_id'] = Variable<String>(roleId);
    map['permission_id'] = Variable<String>(permissionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CoreRolePermissionsCompanion toCompanion(bool nullToAbsent) {
    return CoreRolePermissionsCompanion(
      roleId: Value(roleId),
      permissionId: Value(permissionId),
      createdAt: Value(createdAt),
    );
  }

  factory CoreRolePermissionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreRolePermissionRow(
      roleId: serializer.fromJson<String>(json['roleId']),
      permissionId: serializer.fromJson<String>(json['permissionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roleId': serializer.toJson<String>(roleId),
      'permissionId': serializer.toJson<String>(permissionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CoreRolePermissionRow copyWith({
    String? roleId,
    String? permissionId,
    DateTime? createdAt,
  }) => CoreRolePermissionRow(
    roleId: roleId ?? this.roleId,
    permissionId: permissionId ?? this.permissionId,
    createdAt: createdAt ?? this.createdAt,
  );
  CoreRolePermissionRow copyWithCompanion(CoreRolePermissionsCompanion data) {
    return CoreRolePermissionRow(
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      permissionId: data.permissionId.present
          ? data.permissionId.value
          : this.permissionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreRolePermissionRow(')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(roleId, permissionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreRolePermissionRow &&
          other.roleId == this.roleId &&
          other.permissionId == this.permissionId &&
          other.createdAt == this.createdAt);
}

class CoreRolePermissionsCompanion
    extends UpdateCompanion<CoreRolePermissionRow> {
  final Value<String> roleId;
  final Value<String> permissionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CoreRolePermissionsCompanion({
    this.roleId = const Value.absent(),
    this.permissionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoreRolePermissionsCompanion.insert({
    required String roleId,
    required String permissionId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : roleId = Value(roleId),
       permissionId = Value(permissionId),
       createdAt = Value(createdAt);
  static Insertable<CoreRolePermissionRow> custom({
    Expression<String>? roleId,
    Expression<String>? permissionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roleId != null) 'role_id': roleId,
      if (permissionId != null) 'permission_id': permissionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoreRolePermissionsCompanion copyWith({
    Value<String>? roleId,
    Value<String>? permissionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CoreRolePermissionsCompanion(
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (permissionId.present) {
      map['permission_id'] = Variable<String>(permissionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreRolePermissionsCompanion(')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchemaMigrationsTable extends SchemaMigrations
    with TableInfo<$SchemaMigrationsTable, CoreSchemaMigrationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMigrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [owner, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoreSchemaMigrationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {owner, version};
  @override
  CoreSchemaMigrationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreSchemaMigrationRow(
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SchemaMigrationsTable createAlias(String alias) {
    return $SchemaMigrationsTable(attachedDatabase, alias);
  }
}

class CoreSchemaMigrationRow extends DataClass
    implements Insertable<CoreSchemaMigrationRow> {
  final String owner;
  final int version;
  const CoreSchemaMigrationRow({required this.owner, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner'] = Variable<String>(owner);
    map['version'] = Variable<int>(version);
    return map;
  }

  SchemaMigrationsCompanion toCompanion(bool nullToAbsent) {
    return SchemaMigrationsCompanion(
      owner: Value(owner),
      version: Value(version),
    );
  }

  factory CoreSchemaMigrationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreSchemaMigrationRow(
      owner: serializer.fromJson<String>(json['owner']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'owner': serializer.toJson<String>(owner),
      'version': serializer.toJson<int>(version),
    };
  }

  CoreSchemaMigrationRow copyWith({String? owner, int? version}) =>
      CoreSchemaMigrationRow(
        owner: owner ?? this.owner,
        version: version ?? this.version,
      );
  CoreSchemaMigrationRow copyWithCompanion(SchemaMigrationsCompanion data) {
    return CoreSchemaMigrationRow(
      owner: data.owner.present ? data.owner.value : this.owner,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreSchemaMigrationRow(')
          ..write('owner: $owner, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(owner, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreSchemaMigrationRow &&
          other.owner == this.owner &&
          other.version == this.version);
}

class SchemaMigrationsCompanion
    extends UpdateCompanion<CoreSchemaMigrationRow> {
  final Value<String> owner;
  final Value<int> version;
  final Value<int> rowid;
  const SchemaMigrationsCompanion({
    this.owner = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchemaMigrationsCompanion.insert({
    required String owner,
    required int version,
    this.rowid = const Value.absent(),
  }) : owner = Value(owner),
       version = Value(version);
  static Insertable<CoreSchemaMigrationRow> custom({
    Expression<String>? owner,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (owner != null) 'owner': owner,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchemaMigrationsCompanion copyWith({
    Value<String>? owner,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return SchemaMigrationsCompanion(
      owner: owner ?? this.owner,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMigrationsCompanion(')
          ..write('owner: $owner, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftCoreDatabase extends GeneratedDatabase {
  _$DriftCoreDatabase(QueryExecutor e) : super(e);
  $DriftCoreDatabaseManager get managers => $DriftCoreDatabaseManager(this);
  late final $CoreCompaniesTable coreCompanies = $CoreCompaniesTable(this);
  late final $CoreUsersTable coreUsers = $CoreUsersTable(this);
  late final $CoreCompanyMembershipsTable coreCompanyMemberships =
      $CoreCompanyMembershipsTable(this);
  late final $CoreCredentialsTable coreCredentials = $CoreCredentialsTable(
    this,
  );
  late final $CoreLoginAttemptsTable coreLoginAttempts =
      $CoreLoginAttemptsTable(this);
  late final $CoreRolesTable coreRoles = $CoreRolesTable(this);
  late final $CoreMembershipRolesTable coreMembershipRoles =
      $CoreMembershipRolesTable(this);
  late final $CoreRolePermissionsTable coreRolePermissions =
      $CoreRolePermissionsTable(this);
  late final $SchemaMigrationsTable schemaMigrations = $SchemaMigrationsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    coreCompanies,
    coreUsers,
    coreCompanyMemberships,
    coreCredentials,
    coreLoginAttempts,
    coreRoles,
    coreMembershipRoles,
    coreRolePermissions,
    schemaMigrations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'core_company_memberships',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('core_membership_roles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'core_roles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('core_membership_roles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'core_roles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('core_role_permissions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CoreCompaniesTableCreateCompanionBuilder =
    CoreCompaniesCompanion Function({
      required String id,
      Value<String?> code,
      Value<String?> name,
      Value<String?> status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CoreCompaniesTableUpdateCompanionBuilder =
    CoreCompaniesCompanion Function({
      Value<String> id,
      Value<String?> code,
      Value<String?> name,
      Value<String?> status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$CoreCompaniesTableReferences
    extends
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreCompaniesTable,
          CoreCompanyRow
        > {
  $$CoreCompaniesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CoreCompanyMembershipsTable,
    List<CoreCompanyMembershipRow>
  >
  _coreCompanyMembershipsRefsTable(_$DriftCoreDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.coreCompanyMemberships,
        aliasName: 'core_companies__id__core_company_memberships__company_id',
      );

  $$CoreCompanyMembershipsTableProcessedTableManager
  get coreCompanyMembershipsRefs {
    final manager = $$CoreCompanyMembershipsTableTableManager(
      $_db,
      $_db.coreCompanyMemberships,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreCompanyMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CoreRolesTable, List<CoreRoleRow>>
  _coreRolesRefsTable(_$DriftCoreDatabase db) => MultiTypedResultKey.fromTable(
    db.coreRoles,
    aliasName: 'core_companies__id__core_roles__company_id',
  );

  $$CoreRolesTableProcessedTableManager get coreRolesRefs {
    final manager = $$CoreRolesTableTableManager(
      $_db,
      $_db.coreRoles,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_coreRolesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoreCompaniesTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompaniesTable> {
  $$CoreCompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coreCompanyMembershipsRefs(
    Expression<bool> Function($$CoreCompanyMembershipsTableFilterComposer f) f,
  ) {
    final $$CoreCompanyMembershipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableFilterComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> coreRolesRefs(
    Expression<bool> Function($$CoreRolesTableFilterComposer f) f,
  ) {
    final $$CoreRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableFilterComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreCompaniesTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompaniesTable> {
  $$CoreCompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoreCompaniesTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompaniesTable> {
  $$CoreCompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> coreCompanyMembershipsRefs<T extends Object>(
    Expression<T> Function($$CoreCompanyMembershipsTableAnnotationComposer a) f,
  ) {
    final $$CoreCompanyMembershipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableAnnotationComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> coreRolesRefs<T extends Object>(
    Expression<T> Function($$CoreRolesTableAnnotationComposer a) f,
  ) {
    final $$CoreRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreCompaniesTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreCompaniesTable,
          CoreCompanyRow,
          $$CoreCompaniesTableFilterComposer,
          $$CoreCompaniesTableOrderingComposer,
          $$CoreCompaniesTableAnnotationComposer,
          $$CoreCompaniesTableCreateCompanionBuilder,
          $$CoreCompaniesTableUpdateCompanionBuilder,
          (CoreCompanyRow, $$CoreCompaniesTableReferences),
          CoreCompanyRow,
          PrefetchHooks Function({
            bool coreCompanyMembershipsRefs,
            bool coreRolesRefs,
          })
        > {
  $$CoreCompaniesTableTableManager(
    _$DriftCoreDatabase db,
    $CoreCompaniesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreCompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreCompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoreCompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreCompaniesCompanion(
                id: id,
                code: code,
                name: name,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> code = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreCompaniesCompanion.insert(
                id: id,
                code: code,
                name: name,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreCompaniesTable, CoreCompanyRow>(table),
                  $$CoreCompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({coreCompanyMembershipsRefs = false, coreRolesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coreCompanyMembershipsRefs) db.coreCompanyMemberships,
                    if (coreRolesRefs) db.coreRoles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coreCompanyMembershipsRefs)
                        await $_getPrefetchedData<
                          CoreCompanyRow,
                          $CoreCompaniesTable,
                          CoreCompanyMembershipRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreCompaniesTableReferences
                              ._coreCompanyMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreCompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).coreCompanyMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (coreRolesRefs)
                        await $_getPrefetchedData<
                          CoreCompanyRow,
                          $CoreCompaniesTable,
                          CoreRoleRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreCompaniesTableReferences
                              ._coreRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreCompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).coreRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoreCompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreCompaniesTable,
      CoreCompanyRow,
      $$CoreCompaniesTableFilterComposer,
      $$CoreCompaniesTableOrderingComposer,
      $$CoreCompaniesTableAnnotationComposer,
      $$CoreCompaniesTableCreateCompanionBuilder,
      $$CoreCompaniesTableUpdateCompanionBuilder,
      (CoreCompanyRow, $$CoreCompaniesTableReferences),
      CoreCompanyRow,
      PrefetchHooks Function({
        bool coreCompanyMembershipsRefs,
        bool coreRolesRefs,
      })
    >;
typedef $$CoreUsersTableCreateCompanionBuilder =
    CoreUsersCompanion Function({
      required String id,
      Value<String?> email,
      Value<String?> name,
      Value<String?> status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CoreUsersTableUpdateCompanionBuilder =
    CoreUsersCompanion Function({
      Value<String> id,
      Value<String?> email,
      Value<String?> name,
      Value<String?> status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$CoreUsersTableReferences
    extends BaseReferences<_$DriftCoreDatabase, $CoreUsersTable, CoreUserRow> {
  $$CoreUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CoreCompanyMembershipsTable,
    List<CoreCompanyMembershipRow>
  >
  _coreCompanyMembershipsRefsTable(_$DriftCoreDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.coreCompanyMemberships,
        aliasName: 'core_users__id__core_company_memberships__user_id',
      );

  $$CoreCompanyMembershipsTableProcessedTableManager
  get coreCompanyMembershipsRefs {
    final manager = $$CoreCompanyMembershipsTableTableManager(
      $_db,
      $_db.coreCompanyMemberships,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreCompanyMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CoreCredentialsTable, List<CoreCredentialRow>>
  _coreCredentialsRefsTable(_$DriftCoreDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.coreCredentials,
        aliasName: 'core_users__id__core_credentials__user_id',
      );

  $$CoreCredentialsTableProcessedTableManager get coreCredentialsRefs {
    final manager = $$CoreCredentialsTableTableManager(
      $_db,
      $_db.coreCredentials,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreCredentialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoreUsersTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreUsersTable> {
  $$CoreUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coreCompanyMembershipsRefs(
    Expression<bool> Function($$CoreCompanyMembershipsTableFilterComposer f) f,
  ) {
    final $$CoreCompanyMembershipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableFilterComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> coreCredentialsRefs(
    Expression<bool> Function($$CoreCredentialsTableFilterComposer f) f,
  ) {
    final $$CoreCredentialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreCredentials,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCredentialsTableFilterComposer(
            $db: $db,
            $table: $db.coreCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreUsersTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreUsersTable> {
  $$CoreUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoreUsersTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreUsersTable> {
  $$CoreUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> coreCompanyMembershipsRefs<T extends Object>(
    Expression<T> Function($$CoreCompanyMembershipsTableAnnotationComposer a) f,
  ) {
    final $$CoreCompanyMembershipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableAnnotationComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> coreCredentialsRefs<T extends Object>(
    Expression<T> Function($$CoreCredentialsTableAnnotationComposer a) f,
  ) {
    final $$CoreCredentialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreCredentials,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCredentialsTableAnnotationComposer(
            $db: $db,
            $table: $db.coreCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreUsersTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreUsersTable,
          CoreUserRow,
          $$CoreUsersTableFilterComposer,
          $$CoreUsersTableOrderingComposer,
          $$CoreUsersTableAnnotationComposer,
          $$CoreUsersTableCreateCompanionBuilder,
          $$CoreUsersTableUpdateCompanionBuilder,
          (CoreUserRow, $$CoreUsersTableReferences),
          CoreUserRow,
          PrefetchHooks Function({
            bool coreCompanyMembershipsRefs,
            bool coreCredentialsRefs,
          })
        > {
  $$CoreUsersTableTableManager(_$DriftCoreDatabase db, $CoreUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoreUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreUsersCompanion(
                id: id,
                email: email,
                name: name,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> email = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreUsersCompanion.insert(
                id: id,
                email: email,
                name: name,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreUsersTable, CoreUserRow>(table),
                  $$CoreUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                coreCompanyMembershipsRefs = false,
                coreCredentialsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coreCompanyMembershipsRefs) db.coreCompanyMemberships,
                    if (coreCredentialsRefs) db.coreCredentials,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coreCompanyMembershipsRefs)
                        await $_getPrefetchedData<
                          CoreUserRow,
                          $CoreUsersTable,
                          CoreCompanyMembershipRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreUsersTableReferences
                              ._coreCompanyMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).coreCompanyMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (coreCredentialsRefs)
                        await $_getPrefetchedData<
                          CoreUserRow,
                          $CoreUsersTable,
                          CoreCredentialRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreUsersTableReferences
                              ._coreCredentialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).coreCredentialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoreUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreUsersTable,
      CoreUserRow,
      $$CoreUsersTableFilterComposer,
      $$CoreUsersTableOrderingComposer,
      $$CoreUsersTableAnnotationComposer,
      $$CoreUsersTableCreateCompanionBuilder,
      $$CoreUsersTableUpdateCompanionBuilder,
      (CoreUserRow, $$CoreUsersTableReferences),
      CoreUserRow,
      PrefetchHooks Function({
        bool coreCompanyMembershipsRefs,
        bool coreCredentialsRefs,
      })
    >;
typedef $$CoreCompanyMembershipsTableCreateCompanionBuilder =
    CoreCompanyMembershipsCompanion Function({
      required String id,
      required String userId,
      required String companyId,
      required String role,
      required String status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CoreCompanyMembershipsTableUpdateCompanionBuilder =
    CoreCompanyMembershipsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> companyId,
      Value<String> role,
      Value<String> status,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$CoreCompanyMembershipsTableReferences
    extends
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreCompanyMembershipsTable,
          CoreCompanyMembershipRow
        > {
  $$CoreCompanyMembershipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoreUsersTable _userIdTable(_$DriftCoreDatabase db) => db.coreUsers
      .createAlias('core_company_memberships__user_id__core_users__id');

  $$CoreUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$CoreUsersTableTableManager(
      $_db,
      $_db.coreUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CoreCompaniesTable _companyIdTable(_$DriftCoreDatabase db) => db
      .coreCompanies
      .createAlias('core_company_memberships__company_id__core_companies__id');

  $$CoreCompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CoreCompaniesTableTableManager(
      $_db,
      $_db.coreCompanies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CoreMembershipRolesTable,
    List<CoreMembershipRoleRow>
  >
  _coreMembershipRolesRefsTable(
    _$DriftCoreDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.coreMembershipRoles,
    aliasName:
        'core_company_memberships__id__core_membership_roles__membership_id',
  );

  $$CoreMembershipRolesTableProcessedTableManager get coreMembershipRolesRefs {
    final manager = $$CoreMembershipRolesTableTableManager(
      $_db,
      $_db.coreMembershipRoles,
    ).filter((f) => f.membershipId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreMembershipRolesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoreCompanyMembershipsTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompanyMembershipsTable> {
  $$CoreCompanyMembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoreUsersTableFilterComposer get userId {
    final $$CoreUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableFilterComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoreCompaniesTableFilterComposer get companyId {
    final $$CoreCompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableFilterComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> coreMembershipRolesRefs(
    Expression<bool> Function($$CoreMembershipRolesTableFilterComposer f) f,
  ) {
    final $$CoreMembershipRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreMembershipRoles,
      getReferencedColumn: (t) => t.membershipId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreMembershipRolesTableFilterComposer(
            $db: $db,
            $table: $db.coreMembershipRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreCompanyMembershipsTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompanyMembershipsTable> {
  $$CoreCompanyMembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoreUsersTableOrderingComposer get userId {
    final $$CoreUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableOrderingComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoreCompaniesTableOrderingComposer get companyId {
    final $$CoreCompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreCompanyMembershipsTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreCompanyMembershipsTable> {
  $$CoreCompanyMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CoreUsersTableAnnotationComposer get userId {
    final $$CoreUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoreCompaniesTableAnnotationComposer get companyId {
    final $$CoreCompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> coreMembershipRolesRefs<T extends Object>(
    Expression<T> Function($$CoreMembershipRolesTableAnnotationComposer a) f,
  ) {
    final $$CoreMembershipRolesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreMembershipRoles,
          getReferencedColumn: (t) => t.membershipId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreMembershipRolesTableAnnotationComposer(
                $db: $db,
                $table: $db.coreMembershipRoles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CoreCompanyMembershipsTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreCompanyMembershipsTable,
          CoreCompanyMembershipRow,
          $$CoreCompanyMembershipsTableFilterComposer,
          $$CoreCompanyMembershipsTableOrderingComposer,
          $$CoreCompanyMembershipsTableAnnotationComposer,
          $$CoreCompanyMembershipsTableCreateCompanionBuilder,
          $$CoreCompanyMembershipsTableUpdateCompanionBuilder,
          (CoreCompanyMembershipRow, $$CoreCompanyMembershipsTableReferences),
          CoreCompanyMembershipRow,
          PrefetchHooks Function({
            bool userId,
            bool companyId,
            bool coreMembershipRolesRefs,
          })
        > {
  $$CoreCompanyMembershipsTableTableManager(
    _$DriftCoreDatabase db,
    $CoreCompanyMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreCompanyMembershipsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CoreCompanyMembershipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CoreCompanyMembershipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreCompanyMembershipsCompanion(
                id: id,
                userId: userId,
                companyId: companyId,
                role: role,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String companyId,
                required String role,
                required String status,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreCompanyMembershipsCompanion.insert(
                id: id,
                userId: userId,
                companyId: companyId,
                role: role,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CoreCompanyMembershipsTable,
                    CoreCompanyMembershipRow
                  >(table),
                  $$CoreCompanyMembershipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                companyId = false,
                coreMembershipRolesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coreMembershipRolesRefs) db.coreMembershipRoles,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$CoreCompanyMembershipsTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$CoreCompanyMembershipsTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$CoreCompanyMembershipsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$CoreCompanyMembershipsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coreMembershipRolesRefs)
                        await $_getPrefetchedData<
                          CoreCompanyMembershipRow,
                          $CoreCompanyMembershipsTable,
                          CoreMembershipRoleRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CoreCompanyMembershipsTableReferences
                                  ._coreMembershipRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreCompanyMembershipsTableReferences(
                                db,
                                table,
                                p0,
                              ).coreMembershipRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.membershipId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoreCompanyMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreCompanyMembershipsTable,
      CoreCompanyMembershipRow,
      $$CoreCompanyMembershipsTableFilterComposer,
      $$CoreCompanyMembershipsTableOrderingComposer,
      $$CoreCompanyMembershipsTableAnnotationComposer,
      $$CoreCompanyMembershipsTableCreateCompanionBuilder,
      $$CoreCompanyMembershipsTableUpdateCompanionBuilder,
      (CoreCompanyMembershipRow, $$CoreCompanyMembershipsTableReferences),
      CoreCompanyMembershipRow,
      PrefetchHooks Function({
        bool userId,
        bool companyId,
        bool coreMembershipRolesRefs,
      })
    >;
typedef $$CoreCredentialsTableCreateCompanionBuilder =
    CoreCredentialsCompanion Function({
      required String userId,
      required String kind,
      required String algorithm,
      required String parameters,
      required String salt,
      required String verifier,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CoreCredentialsTableUpdateCompanionBuilder =
    CoreCredentialsCompanion Function({
      Value<String> userId,
      Value<String> kind,
      Value<String> algorithm,
      Value<String> parameters,
      Value<String> salt,
      Value<String> verifier,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CoreCredentialsTableReferences
    extends
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreCredentialsTable,
          CoreCredentialRow
        > {
  $$CoreCredentialsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoreUsersTable _userIdTable(_$DriftCoreDatabase db) =>
      db.coreUsers.createAlias('core_credentials__user_id__core_users__id');

  $$CoreUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$CoreUsersTableTableManager(
      $_db,
      $_db.coreUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CoreCredentialsTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreCredentialsTable> {
  $$CoreCredentialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verifier => $composableBuilder(
    column: $table.verifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoreUsersTableFilterComposer get userId {
    final $$CoreUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableFilterComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreCredentialsTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreCredentialsTable> {
  $$CoreCredentialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verifier => $composableBuilder(
    column: $table.verifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoreUsersTableOrderingComposer get userId {
    final $$CoreUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableOrderingComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreCredentialsTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreCredentialsTable> {
  $$CoreCredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get verifier =>
      $composableBuilder(column: $table.verifier, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CoreUsersTableAnnotationComposer get userId {
    final $$CoreUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.coreUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.coreUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreCredentialsTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreCredentialsTable,
          CoreCredentialRow,
          $$CoreCredentialsTableFilterComposer,
          $$CoreCredentialsTableOrderingComposer,
          $$CoreCredentialsTableAnnotationComposer,
          $$CoreCredentialsTableCreateCompanionBuilder,
          $$CoreCredentialsTableUpdateCompanionBuilder,
          (CoreCredentialRow, $$CoreCredentialsTableReferences),
          CoreCredentialRow,
          PrefetchHooks Function({bool userId})
        > {
  $$CoreCredentialsTableTableManager(
    _$DriftCoreDatabase db,
    $CoreCredentialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreCredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreCredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoreCredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<String> parameters = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<String> verifier = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreCredentialsCompanion(
                userId: userId,
                kind: kind,
                algorithm: algorithm,
                parameters: parameters,
                salt: salt,
                verifier: verifier,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String kind,
                required String algorithm,
                required String parameters,
                required String salt,
                required String verifier,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CoreCredentialsCompanion.insert(
                userId: userId,
                kind: kind,
                algorithm: algorithm,
                parameters: parameters,
                salt: salt,
                verifier: verifier,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreCredentialsTable, CoreCredentialRow>(table),
                  $$CoreCredentialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$CoreCredentialsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$CoreCredentialsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CoreCredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreCredentialsTable,
      CoreCredentialRow,
      $$CoreCredentialsTableFilterComposer,
      $$CoreCredentialsTableOrderingComposer,
      $$CoreCredentialsTableAnnotationComposer,
      $$CoreCredentialsTableCreateCompanionBuilder,
      $$CoreCredentialsTableUpdateCompanionBuilder,
      (CoreCredentialRow, $$CoreCredentialsTableReferences),
      CoreCredentialRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$CoreLoginAttemptsTableCreateCompanionBuilder =
    CoreLoginAttemptsCompanion Function({
      required String identifierHash,
      required int attemptCount,
      Value<DateTime?> lockedUntil,
      required DateTime lastAttemptAt,
      Value<int> rowid,
    });
typedef $$CoreLoginAttemptsTableUpdateCompanionBuilder =
    CoreLoginAttemptsCompanion Function({
      Value<String> identifierHash,
      Value<int> attemptCount,
      Value<DateTime?> lockedUntil,
      Value<DateTime> lastAttemptAt,
      Value<int> rowid,
    });

class $$CoreLoginAttemptsTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreLoginAttemptsTable> {
  $$CoreLoginAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoreLoginAttemptsTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreLoginAttemptsTable> {
  $$CoreLoginAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoreLoginAttemptsTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreLoginAttemptsTable> {
  $$CoreLoginAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$CoreLoginAttemptsTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreLoginAttemptsTable,
          CoreLoginAttemptRow,
          $$CoreLoginAttemptsTableFilterComposer,
          $$CoreLoginAttemptsTableOrderingComposer,
          $$CoreLoginAttemptsTableAnnotationComposer,
          $$CoreLoginAttemptsTableCreateCompanionBuilder,
          $$CoreLoginAttemptsTableUpdateCompanionBuilder,
          (
            CoreLoginAttemptRow,
            BaseReferences<
              _$DriftCoreDatabase,
              $CoreLoginAttemptsTable,
              CoreLoginAttemptRow
            >,
          ),
          CoreLoginAttemptRow,
          PrefetchHooks Function()
        > {
  $$CoreLoginAttemptsTableTableManager(
    _$DriftCoreDatabase db,
    $CoreLoginAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreLoginAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreLoginAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoreLoginAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> identifierHash = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<DateTime> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreLoginAttemptsCompanion(
                identifierHash: identifierHash,
                attemptCount: attemptCount,
                lockedUntil: lockedUntil,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identifierHash,
                required int attemptCount,
                Value<DateTime?> lockedUntil = const Value.absent(),
                required DateTime lastAttemptAt,
                Value<int> rowid = const Value.absent(),
              }) => CoreLoginAttemptsCompanion.insert(
                identifierHash: identifierHash,
                attemptCount: attemptCount,
                lockedUntil: lockedUntil,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreLoginAttemptsTable, CoreLoginAttemptRow>(
                    table,
                  ),
                  BaseReferences<
                    _$DriftCoreDatabase,
                    $CoreLoginAttemptsTable,
                    CoreLoginAttemptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoreLoginAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreLoginAttemptsTable,
      CoreLoginAttemptRow,
      $$CoreLoginAttemptsTableFilterComposer,
      $$CoreLoginAttemptsTableOrderingComposer,
      $$CoreLoginAttemptsTableAnnotationComposer,
      $$CoreLoginAttemptsTableCreateCompanionBuilder,
      $$CoreLoginAttemptsTableUpdateCompanionBuilder,
      (
        CoreLoginAttemptRow,
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreLoginAttemptsTable,
          CoreLoginAttemptRow
        >,
      ),
      CoreLoginAttemptRow,
      PrefetchHooks Function()
    >;
typedef $$CoreRolesTableCreateCompanionBuilder =
    CoreRolesCompanion Function({
      required String id,
      required String scope,
      Value<String?> companyId,
      required String roleKey,
      Value<String?> name,
      Value<String?> normalizedName,
      Value<String?> description,
      Value<bool> isBuiltin,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CoreRolesTableUpdateCompanionBuilder =
    CoreRolesCompanion Function({
      Value<String> id,
      Value<String> scope,
      Value<String?> companyId,
      Value<String> roleKey,
      Value<String?> name,
      Value<String?> normalizedName,
      Value<String?> description,
      Value<bool> isBuiltin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CoreRolesTableReferences
    extends BaseReferences<_$DriftCoreDatabase, $CoreRolesTable, CoreRoleRow> {
  $$CoreRolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CoreCompaniesTable _companyIdTable(_$DriftCoreDatabase db) => db
      .coreCompanies
      .createAlias('core_roles__company_id__core_companies__id');

  $$CoreCompaniesTableProcessedTableManager? get companyId {
    final $_column = $_itemColumn<String>('company_id');
    if ($_column == null) return null;
    final manager = $$CoreCompaniesTableTableManager(
      $_db,
      $_db.coreCompanies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CoreMembershipRolesTable,
    List<CoreMembershipRoleRow>
  >
  _coreMembershipRolesRefsTable(_$DriftCoreDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.coreMembershipRoles,
        aliasName: 'core_roles__id__core_membership_roles__role_id',
      );

  $$CoreMembershipRolesTableProcessedTableManager get coreMembershipRolesRefs {
    final manager = $$CoreMembershipRolesTableTableManager(
      $_db,
      $_db.coreMembershipRoles,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreMembershipRolesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CoreRolePermissionsTable,
    List<CoreRolePermissionRow>
  >
  _coreRolePermissionsRefsTable(_$DriftCoreDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.coreRolePermissions,
        aliasName: 'core_roles__id__core_role_permissions__role_id',
      );

  $$CoreRolePermissionsTableProcessedTableManager get coreRolePermissionsRefs {
    final manager = $$CoreRolePermissionsTableTableManager(
      $_db,
      $_db.coreRolePermissions,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _coreRolePermissionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoreRolesTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolesTable> {
  $$CoreRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleKey => $composableBuilder(
    column: $table.roleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoreCompaniesTableFilterComposer get companyId {
    final $$CoreCompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableFilterComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> coreMembershipRolesRefs(
    Expression<bool> Function($$CoreMembershipRolesTableFilterComposer f) f,
  ) {
    final $$CoreMembershipRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreMembershipRoles,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreMembershipRolesTableFilterComposer(
            $db: $db,
            $table: $db.coreMembershipRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> coreRolePermissionsRefs(
    Expression<bool> Function($$CoreRolePermissionsTableFilterComposer f) f,
  ) {
    final $$CoreRolePermissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coreRolePermissions,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolePermissionsTableFilterComposer(
            $db: $db,
            $table: $db.coreRolePermissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoreRolesTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolesTable> {
  $$CoreRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleKey => $composableBuilder(
    column: $table.roleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoreCompaniesTableOrderingComposer get companyId {
    final $$CoreCompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreRolesTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolesTable> {
  $$CoreRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get roleKey =>
      $composableBuilder(column: $table.roleKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CoreCompaniesTableAnnotationComposer get companyId {
    final $$CoreCompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.coreCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreCompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.coreCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> coreMembershipRolesRefs<T extends Object>(
    Expression<T> Function($$CoreMembershipRolesTableAnnotationComposer a) f,
  ) {
    final $$CoreMembershipRolesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreMembershipRoles,
          getReferencedColumn: (t) => t.roleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreMembershipRolesTableAnnotationComposer(
                $db: $db,
                $table: $db.coreMembershipRoles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> coreRolePermissionsRefs<T extends Object>(
    Expression<T> Function($$CoreRolePermissionsTableAnnotationComposer a) f,
  ) {
    final $$CoreRolePermissionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.coreRolePermissions,
          getReferencedColumn: (t) => t.roleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreRolePermissionsTableAnnotationComposer(
                $db: $db,
                $table: $db.coreRolePermissions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CoreRolesTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreRolesTable,
          CoreRoleRow,
          $$CoreRolesTableFilterComposer,
          $$CoreRolesTableOrderingComposer,
          $$CoreRolesTableAnnotationComposer,
          $$CoreRolesTableCreateCompanionBuilder,
          $$CoreRolesTableUpdateCompanionBuilder,
          (CoreRoleRow, $$CoreRolesTableReferences),
          CoreRoleRow,
          PrefetchHooks Function({
            bool companyId,
            bool coreMembershipRolesRefs,
            bool coreRolePermissionsRefs,
          })
        > {
  $$CoreRolesTableTableManager(_$DriftCoreDatabase db, $CoreRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoreRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                Value<String> roleKey = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> normalizedName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreRolesCompanion(
                id: id,
                scope: scope,
                companyId: companyId,
                roleKey: roleKey,
                name: name,
                normalizedName: normalizedName,
                description: description,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scope,
                Value<String?> companyId = const Value.absent(),
                required String roleKey,
                Value<String?> name = const Value.absent(),
                Value<String?> normalizedName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CoreRolesCompanion.insert(
                id: id,
                scope: scope,
                companyId: companyId,
                roleKey: roleKey,
                name: name,
                normalizedName: normalizedName,
                description: description,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreRolesTable, CoreRoleRow>(table),
                  $$CoreRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                coreMembershipRolesRefs = false,
                coreRolePermissionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coreMembershipRolesRefs) db.coreMembershipRoles,
                    if (coreRolePermissionsRefs) db.coreRolePermissions,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$CoreRolesTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$CoreRolesTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coreMembershipRolesRefs)
                        await $_getPrefetchedData<
                          CoreRoleRow,
                          $CoreRolesTable,
                          CoreMembershipRoleRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreRolesTableReferences
                              ._coreMembershipRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreRolesTableReferences(
                                db,
                                table,
                                p0,
                              ).coreMembershipRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (coreRolePermissionsRefs)
                        await $_getPrefetchedData<
                          CoreRoleRow,
                          $CoreRolesTable,
                          CoreRolePermissionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoreRolesTableReferences
                              ._coreRolePermissionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoreRolesTableReferences(
                                db,
                                table,
                                p0,
                              ).coreRolePermissionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoreRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreRolesTable,
      CoreRoleRow,
      $$CoreRolesTableFilterComposer,
      $$CoreRolesTableOrderingComposer,
      $$CoreRolesTableAnnotationComposer,
      $$CoreRolesTableCreateCompanionBuilder,
      $$CoreRolesTableUpdateCompanionBuilder,
      (CoreRoleRow, $$CoreRolesTableReferences),
      CoreRoleRow,
      PrefetchHooks Function({
        bool companyId,
        bool coreMembershipRolesRefs,
        bool coreRolePermissionsRefs,
      })
    >;
typedef $$CoreMembershipRolesTableCreateCompanionBuilder =
    CoreMembershipRolesCompanion Function({
      required String membershipId,
      required String roleId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CoreMembershipRolesTableUpdateCompanionBuilder =
    CoreMembershipRolesCompanion Function({
      Value<String> membershipId,
      Value<String> roleId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CoreMembershipRolesTableReferences
    extends
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreMembershipRolesTable,
          CoreMembershipRoleRow
        > {
  $$CoreMembershipRolesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoreCompanyMembershipsTable _membershipIdTable(
    _$DriftCoreDatabase db,
  ) => db.coreCompanyMemberships.createAlias(
    'core_membership_roles__membership_id__core_company_memberships__id',
  );

  $$CoreCompanyMembershipsTableProcessedTableManager get membershipId {
    final $_column = $_itemColumn<String>('membership_id')!;

    final manager = $$CoreCompanyMembershipsTableTableManager(
      $_db,
      $_db.coreCompanyMemberships,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_membershipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CoreRolesTable _roleIdTable(_$DriftCoreDatabase db) => db.coreRoles
      .createAlias('core_membership_roles__role_id__core_roles__id');

  $$CoreRolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<String>('role_id')!;

    final manager = $$CoreRolesTableTableManager(
      $_db,
      $_db.coreRoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CoreMembershipRolesTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreMembershipRolesTable> {
  $$CoreMembershipRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoreCompanyMembershipsTableFilterComposer get membershipId {
    final $$CoreCompanyMembershipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.membershipId,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableFilterComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CoreRolesTableFilterComposer get roleId {
    final $$CoreRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableFilterComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreMembershipRolesTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreMembershipRolesTable> {
  $$CoreMembershipRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoreCompanyMembershipsTableOrderingComposer get membershipId {
    final $$CoreCompanyMembershipsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.membershipId,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableOrderingComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CoreRolesTableOrderingComposer get roleId {
    final $$CoreRolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableOrderingComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreMembershipRolesTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreMembershipRolesTable> {
  $$CoreMembershipRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CoreCompanyMembershipsTableAnnotationComposer get membershipId {
    final $$CoreCompanyMembershipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.membershipId,
          referencedTable: $db.coreCompanyMemberships,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CoreCompanyMembershipsTableAnnotationComposer(
                $db: $db,
                $table: $db.coreCompanyMemberships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CoreRolesTableAnnotationComposer get roleId {
    final $$CoreRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreMembershipRolesTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreMembershipRolesTable,
          CoreMembershipRoleRow,
          $$CoreMembershipRolesTableFilterComposer,
          $$CoreMembershipRolesTableOrderingComposer,
          $$CoreMembershipRolesTableAnnotationComposer,
          $$CoreMembershipRolesTableCreateCompanionBuilder,
          $$CoreMembershipRolesTableUpdateCompanionBuilder,
          (CoreMembershipRoleRow, $$CoreMembershipRolesTableReferences),
          CoreMembershipRoleRow,
          PrefetchHooks Function({bool membershipId, bool roleId})
        > {
  $$CoreMembershipRolesTableTableManager(
    _$DriftCoreDatabase db,
    $CoreMembershipRolesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreMembershipRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreMembershipRolesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CoreMembershipRolesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> membershipId = const Value.absent(),
                Value<String> roleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreMembershipRolesCompanion(
                membershipId: membershipId,
                roleId: roleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String membershipId,
                required String roleId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CoreMembershipRolesCompanion.insert(
                membershipId: membershipId,
                roleId: roleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreMembershipRolesTable, CoreMembershipRoleRow>(
                    table,
                  ),
                  $$CoreMembershipRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({membershipId = false, roleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (membershipId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.membershipId,
                                referencedTable:
                                    $$CoreMembershipRolesTableReferences
                                        ._membershipIdTable(db),
                                referencedColumn:
                                    $$CoreMembershipRolesTableReferences
                                        ._membershipIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (roleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roleId,
                                referencedTable:
                                    $$CoreMembershipRolesTableReferences
                                        ._roleIdTable(db),
                                referencedColumn:
                                    $$CoreMembershipRolesTableReferences
                                        ._roleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CoreMembershipRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreMembershipRolesTable,
      CoreMembershipRoleRow,
      $$CoreMembershipRolesTableFilterComposer,
      $$CoreMembershipRolesTableOrderingComposer,
      $$CoreMembershipRolesTableAnnotationComposer,
      $$CoreMembershipRolesTableCreateCompanionBuilder,
      $$CoreMembershipRolesTableUpdateCompanionBuilder,
      (CoreMembershipRoleRow, $$CoreMembershipRolesTableReferences),
      CoreMembershipRoleRow,
      PrefetchHooks Function({bool membershipId, bool roleId})
    >;
typedef $$CoreRolePermissionsTableCreateCompanionBuilder =
    CoreRolePermissionsCompanion Function({
      required String roleId,
      required String permissionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CoreRolePermissionsTableUpdateCompanionBuilder =
    CoreRolePermissionsCompanion Function({
      Value<String> roleId,
      Value<String> permissionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CoreRolePermissionsTableReferences
    extends
        BaseReferences<
          _$DriftCoreDatabase,
          $CoreRolePermissionsTable,
          CoreRolePermissionRow
        > {
  $$CoreRolePermissionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoreRolesTable _roleIdTable(_$DriftCoreDatabase db) => db.coreRoles
      .createAlias('core_role_permissions__role_id__core_roles__id');

  $$CoreRolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<String>('role_id')!;

    final manager = $$CoreRolesTableTableManager(
      $_db,
      $_db.coreRoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CoreRolePermissionsTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolePermissionsTable> {
  $$CoreRolePermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoreRolesTableFilterComposer get roleId {
    final $$CoreRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableFilterComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreRolePermissionsTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolePermissionsTable> {
  $$CoreRolePermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoreRolesTableOrderingComposer get roleId {
    final $$CoreRolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableOrderingComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreRolePermissionsTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $CoreRolePermissionsTable> {
  $$CoreRolePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CoreRolesTableAnnotationComposer get roleId {
    final $$CoreRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.coreRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoreRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.coreRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoreRolePermissionsTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $CoreRolePermissionsTable,
          CoreRolePermissionRow,
          $$CoreRolePermissionsTableFilterComposer,
          $$CoreRolePermissionsTableOrderingComposer,
          $$CoreRolePermissionsTableAnnotationComposer,
          $$CoreRolePermissionsTableCreateCompanionBuilder,
          $$CoreRolePermissionsTableUpdateCompanionBuilder,
          (CoreRolePermissionRow, $$CoreRolePermissionsTableReferences),
          CoreRolePermissionRow,
          PrefetchHooks Function({bool roleId})
        > {
  $$CoreRolePermissionsTableTableManager(
    _$DriftCoreDatabase db,
    $CoreRolePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoreRolePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoreRolePermissionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CoreRolePermissionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> roleId = const Value.absent(),
                Value<String> permissionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoreRolePermissionsCompanion(
                roleId: roleId,
                permissionId: permissionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String roleId,
                required String permissionId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CoreRolePermissionsCompanion.insert(
                roleId: roleId,
                permissionId: permissionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoreRolePermissionsTable, CoreRolePermissionRow>(
                    table,
                  ),
                  $$CoreRolePermissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (roleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roleId,
                                referencedTable:
                                    $$CoreRolePermissionsTableReferences
                                        ._roleIdTable(db),
                                referencedColumn:
                                    $$CoreRolePermissionsTableReferences
                                        ._roleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CoreRolePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $CoreRolePermissionsTable,
      CoreRolePermissionRow,
      $$CoreRolePermissionsTableFilterComposer,
      $$CoreRolePermissionsTableOrderingComposer,
      $$CoreRolePermissionsTableAnnotationComposer,
      $$CoreRolePermissionsTableCreateCompanionBuilder,
      $$CoreRolePermissionsTableUpdateCompanionBuilder,
      (CoreRolePermissionRow, $$CoreRolePermissionsTableReferences),
      CoreRolePermissionRow,
      PrefetchHooks Function({bool roleId})
    >;
typedef $$SchemaMigrationsTableCreateCompanionBuilder =
    SchemaMigrationsCompanion Function({
      required String owner,
      required int version,
      Value<int> rowid,
    });
typedef $$SchemaMigrationsTableUpdateCompanionBuilder =
    SchemaMigrationsCompanion Function({
      Value<String> owner,
      Value<int> version,
      Value<int> rowid,
    });

class $$SchemaMigrationsTableFilterComposer
    extends Composer<_$DriftCoreDatabase, $SchemaMigrationsTable> {
  $$SchemaMigrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchemaMigrationsTableOrderingComposer
    extends Composer<_$DriftCoreDatabase, $SchemaMigrationsTable> {
  $$SchemaMigrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchemaMigrationsTableAnnotationComposer
    extends Composer<_$DriftCoreDatabase, $SchemaMigrationsTable> {
  $$SchemaMigrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SchemaMigrationsTableTableManager
    extends
        RootTableManager<
          _$DriftCoreDatabase,
          $SchemaMigrationsTable,
          CoreSchemaMigrationRow,
          $$SchemaMigrationsTableFilterComposer,
          $$SchemaMigrationsTableOrderingComposer,
          $$SchemaMigrationsTableAnnotationComposer,
          $$SchemaMigrationsTableCreateCompanionBuilder,
          $$SchemaMigrationsTableUpdateCompanionBuilder,
          (
            CoreSchemaMigrationRow,
            BaseReferences<
              _$DriftCoreDatabase,
              $SchemaMigrationsTable,
              CoreSchemaMigrationRow
            >,
          ),
          CoreSchemaMigrationRow,
          PrefetchHooks Function()
        > {
  $$SchemaMigrationsTableTableManager(
    _$DriftCoreDatabase db,
    $SchemaMigrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMigrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMigrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaMigrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> owner = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchemaMigrationsCompanion(
                owner: owner,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String owner,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => SchemaMigrationsCompanion.insert(
                owner: owner,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchemaMigrationsTable, CoreSchemaMigrationRow>(
                    table,
                  ),
                  BaseReferences<
                    _$DriftCoreDatabase,
                    $SchemaMigrationsTable,
                    CoreSchemaMigrationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchemaMigrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftCoreDatabase,
      $SchemaMigrationsTable,
      CoreSchemaMigrationRow,
      $$SchemaMigrationsTableFilterComposer,
      $$SchemaMigrationsTableOrderingComposer,
      $$SchemaMigrationsTableAnnotationComposer,
      $$SchemaMigrationsTableCreateCompanionBuilder,
      $$SchemaMigrationsTableUpdateCompanionBuilder,
      (
        CoreSchemaMigrationRow,
        BaseReferences<
          _$DriftCoreDatabase,
          $SchemaMigrationsTable,
          CoreSchemaMigrationRow
        >,
      ),
      CoreSchemaMigrationRow,
      PrefetchHooks Function()
    >;

class $DriftCoreDatabaseManager {
  final _$DriftCoreDatabase _db;
  $DriftCoreDatabaseManager(this._db);
  $$CoreCompaniesTableTableManager get coreCompanies =>
      $$CoreCompaniesTableTableManager(_db, _db.coreCompanies);
  $$CoreUsersTableTableManager get coreUsers =>
      $$CoreUsersTableTableManager(_db, _db.coreUsers);
  $$CoreCompanyMembershipsTableTableManager get coreCompanyMemberships =>
      $$CoreCompanyMembershipsTableTableManager(
        _db,
        _db.coreCompanyMemberships,
      );
  $$CoreCredentialsTableTableManager get coreCredentials =>
      $$CoreCredentialsTableTableManager(_db, _db.coreCredentials);
  $$CoreLoginAttemptsTableTableManager get coreLoginAttempts =>
      $$CoreLoginAttemptsTableTableManager(_db, _db.coreLoginAttempts);
  $$CoreRolesTableTableManager get coreRoles =>
      $$CoreRolesTableTableManager(_db, _db.coreRoles);
  $$CoreMembershipRolesTableTableManager get coreMembershipRoles =>
      $$CoreMembershipRolesTableTableManager(_db, _db.coreMembershipRoles);
  $$CoreRolePermissionsTableTableManager get coreRolePermissions =>
      $$CoreRolePermissionsTableTableManager(_db, _db.coreRolePermissions);
  $$SchemaMigrationsTableTableManager get schemaMigrations =>
      $$SchemaMigrationsTableTableManager(_db, _db.schemaMigrations);
}
