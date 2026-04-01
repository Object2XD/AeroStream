// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncAccountsTable extends SyncAccounts
    with TableInfo<$SyncAccountsTable, SyncAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerAccountIdMeta = const VerificationMeta(
    'providerAccountId',
  );
  @override
  late final GeneratedColumn<String> providerAccountId =
      GeneratedColumn<String>(
        'provider_account_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authKindMeta = const VerificationMeta(
    'authKind',
  );
  @override
  late final GeneratedColumn<String> authKind = GeneratedColumn<String>(
    'auth_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authSessionStateMeta = const VerificationMeta(
    'authSessionState',
  );
  @override
  late final GeneratedColumn<String> authSessionState = GeneratedColumn<String>(
    'auth_session_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DriveAuthSessionState.ready.value),
  );
  static const VerificationMeta _authSessionErrorMeta = const VerificationMeta(
    'authSessionError',
  );
  @override
  late final GeneratedColumn<String> authSessionError = GeneratedColumn<String>(
    'auth_session_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driveStartPageTokenMeta =
      const VerificationMeta('driveStartPageToken');
  @override
  late final GeneratedColumn<String> driveStartPageToken =
      GeneratedColumn<String>(
        'drive_start_page_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _driveChangePageTokenMeta =
      const VerificationMeta('driveChangePageToken');
  @override
  late final GeneratedColumn<String> driveChangePageToken =
      GeneratedColumn<String>(
        'drive_change_page_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerAccountId,
    email,
    displayName,
    authKind,
    isActive,
    connectedAt,
    authSessionState,
    authSessionError,
    driveStartPageToken,
    driveChangePageToken,
    lastSuccessfulSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_account_id')) {
      context.handle(
        _providerAccountIdMeta,
        providerAccountId.isAcceptableOrUnknown(
          data['provider_account_id']!,
          _providerAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerAccountIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('auth_kind')) {
      context.handle(
        _authKindMeta,
        authKind.isAcceptableOrUnknown(data['auth_kind']!, _authKindMeta),
      );
    } else if (isInserting) {
      context.missing(_authKindMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    if (data.containsKey('auth_session_state')) {
      context.handle(
        _authSessionStateMeta,
        authSessionState.isAcceptableOrUnknown(
          data['auth_session_state']!,
          _authSessionStateMeta,
        ),
      );
    }
    if (data.containsKey('auth_session_error')) {
      context.handle(
        _authSessionErrorMeta,
        authSessionError.isAcceptableOrUnknown(
          data['auth_session_error']!,
          _authSessionErrorMeta,
        ),
      );
    }
    if (data.containsKey('drive_start_page_token')) {
      context.handle(
        _driveStartPageTokenMeta,
        driveStartPageToken.isAcceptableOrUnknown(
          data['drive_start_page_token']!,
          _driveStartPageTokenMeta,
        ),
      );
    }
    if (data.containsKey('drive_change_page_token')) {
      context.handle(
        _driveChangePageTokenMeta,
        driveChangePageToken.isAcceptableOrUnknown(
          data['drive_change_page_token']!,
          _driveChangePageTokenMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_account_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      authKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_kind'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      )!,
      authSessionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_session_state'],
      )!,
      authSessionError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_session_error'],
      ),
      driveStartPageToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_start_page_token'],
      ),
      driveChangePageToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_change_page_token'],
      ),
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
    );
  }

  @override
  $SyncAccountsTable createAlias(String alias) {
    return $SyncAccountsTable(attachedDatabase, alias);
  }
}

class SyncAccount extends DataClass implements Insertable<SyncAccount> {
  final int id;
  final String providerAccountId;
  final String email;
  final String displayName;
  final String authKind;
  final bool isActive;
  final DateTime connectedAt;
  final String authSessionState;
  final String? authSessionError;
  final String? driveStartPageToken;
  final String? driveChangePageToken;
  final DateTime? lastSuccessfulSyncAt;
  const SyncAccount({
    required this.id,
    required this.providerAccountId,
    required this.email,
    required this.displayName,
    required this.authKind,
    required this.isActive,
    required this.connectedAt,
    required this.authSessionState,
    this.authSessionError,
    this.driveStartPageToken,
    this.driveChangePageToken,
    this.lastSuccessfulSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_account_id'] = Variable<String>(providerAccountId);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    map['auth_kind'] = Variable<String>(authKind);
    map['is_active'] = Variable<bool>(isActive);
    map['connected_at'] = Variable<DateTime>(connectedAt);
    map['auth_session_state'] = Variable<String>(authSessionState);
    if (!nullToAbsent || authSessionError != null) {
      map['auth_session_error'] = Variable<String>(authSessionError);
    }
    if (!nullToAbsent || driveStartPageToken != null) {
      map['drive_start_page_token'] = Variable<String>(driveStartPageToken);
    }
    if (!nullToAbsent || driveChangePageToken != null) {
      map['drive_change_page_token'] = Variable<String>(driveChangePageToken);
    }
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    return map;
  }

  SyncAccountsCompanion toCompanion(bool nullToAbsent) {
    return SyncAccountsCompanion(
      id: Value(id),
      providerAccountId: Value(providerAccountId),
      email: Value(email),
      displayName: Value(displayName),
      authKind: Value(authKind),
      isActive: Value(isActive),
      connectedAt: Value(connectedAt),
      authSessionState: Value(authSessionState),
      authSessionError: authSessionError == null && nullToAbsent
          ? const Value.absent()
          : Value(authSessionError),
      driveStartPageToken: driveStartPageToken == null && nullToAbsent
          ? const Value.absent()
          : Value(driveStartPageToken),
      driveChangePageToken: driveChangePageToken == null && nullToAbsent
          ? const Value.absent()
          : Value(driveChangePageToken),
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAt),
    );
  }

  factory SyncAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncAccount(
      id: serializer.fromJson<int>(json['id']),
      providerAccountId: serializer.fromJson<String>(json['providerAccountId']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      authKind: serializer.fromJson<String>(json['authKind']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
      authSessionState: serializer.fromJson<String>(json['authSessionState']),
      authSessionError: serializer.fromJson<String?>(json['authSessionError']),
      driveStartPageToken: serializer.fromJson<String?>(
        json['driveStartPageToken'],
      ),
      driveChangePageToken: serializer.fromJson<String?>(
        json['driveChangePageToken'],
      ),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerAccountId': serializer.toJson<String>(providerAccountId),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'authKind': serializer.toJson<String>(authKind),
      'isActive': serializer.toJson<bool>(isActive),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
      'authSessionState': serializer.toJson<String>(authSessionState),
      'authSessionError': serializer.toJson<String?>(authSessionError),
      'driveStartPageToken': serializer.toJson<String?>(driveStartPageToken),
      'driveChangePageToken': serializer.toJson<String?>(driveChangePageToken),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
    };
  }

  SyncAccount copyWith({
    int? id,
    String? providerAccountId,
    String? email,
    String? displayName,
    String? authKind,
    bool? isActive,
    DateTime? connectedAt,
    String? authSessionState,
    Value<String?> authSessionError = const Value.absent(),
    Value<String?> driveStartPageToken = const Value.absent(),
    Value<String?> driveChangePageToken = const Value.absent(),
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
  }) => SyncAccount(
    id: id ?? this.id,
    providerAccountId: providerAccountId ?? this.providerAccountId,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    authKind: authKind ?? this.authKind,
    isActive: isActive ?? this.isActive,
    connectedAt: connectedAt ?? this.connectedAt,
    authSessionState: authSessionState ?? this.authSessionState,
    authSessionError: authSessionError.present
        ? authSessionError.value
        : this.authSessionError,
    driveStartPageToken: driveStartPageToken.present
        ? driveStartPageToken.value
        : this.driveStartPageToken,
    driveChangePageToken: driveChangePageToken.present
        ? driveChangePageToken.value
        : this.driveChangePageToken,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt.present
        ? lastSuccessfulSyncAt.value
        : this.lastSuccessfulSyncAt,
  );
  SyncAccount copyWithCompanion(SyncAccountsCompanion data) {
    return SyncAccount(
      id: data.id.present ? data.id.value : this.id,
      providerAccountId: data.providerAccountId.present
          ? data.providerAccountId.value
          : this.providerAccountId,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      authKind: data.authKind.present ? data.authKind.value : this.authKind,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
      authSessionState: data.authSessionState.present
          ? data.authSessionState.value
          : this.authSessionState,
      authSessionError: data.authSessionError.present
          ? data.authSessionError.value
          : this.authSessionError,
      driveStartPageToken: data.driveStartPageToken.present
          ? data.driveStartPageToken.value
          : this.driveStartPageToken,
      driveChangePageToken: data.driveChangePageToken.present
          ? data.driveChangePageToken.value
          : this.driveChangePageToken,
      lastSuccessfulSyncAt: data.lastSuccessfulSyncAt.present
          ? data.lastSuccessfulSyncAt.value
          : this.lastSuccessfulSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncAccount(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('authKind: $authKind, ')
          ..write('isActive: $isActive, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('authSessionState: $authSessionState, ')
          ..write('authSessionError: $authSessionError, ')
          ..write('driveStartPageToken: $driveStartPageToken, ')
          ..write('driveChangePageToken: $driveChangePageToken, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerAccountId,
    email,
    displayName,
    authKind,
    isActive,
    connectedAt,
    authSessionState,
    authSessionError,
    driveStartPageToken,
    driveChangePageToken,
    lastSuccessfulSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncAccount &&
          other.id == this.id &&
          other.providerAccountId == this.providerAccountId &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.authKind == this.authKind &&
          other.isActive == this.isActive &&
          other.connectedAt == this.connectedAt &&
          other.authSessionState == this.authSessionState &&
          other.authSessionError == this.authSessionError &&
          other.driveStartPageToken == this.driveStartPageToken &&
          other.driveChangePageToken == this.driveChangePageToken &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt);
}

class SyncAccountsCompanion extends UpdateCompanion<SyncAccount> {
  final Value<int> id;
  final Value<String> providerAccountId;
  final Value<String> email;
  final Value<String> displayName;
  final Value<String> authKind;
  final Value<bool> isActive;
  final Value<DateTime> connectedAt;
  final Value<String> authSessionState;
  final Value<String?> authSessionError;
  final Value<String?> driveStartPageToken;
  final Value<String?> driveChangePageToken;
  final Value<DateTime?> lastSuccessfulSyncAt;
  const SyncAccountsCompanion({
    this.id = const Value.absent(),
    this.providerAccountId = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.authKind = const Value.absent(),
    this.isActive = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.authSessionState = const Value.absent(),
    this.authSessionError = const Value.absent(),
    this.driveStartPageToken = const Value.absent(),
    this.driveChangePageToken = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
  });
  SyncAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String providerAccountId,
    required String email,
    required String displayName,
    required String authKind,
    this.isActive = const Value.absent(),
    required DateTime connectedAt,
    this.authSessionState = const Value.absent(),
    this.authSessionError = const Value.absent(),
    this.driveStartPageToken = const Value.absent(),
    this.driveChangePageToken = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
  }) : providerAccountId = Value(providerAccountId),
       email = Value(email),
       displayName = Value(displayName),
       authKind = Value(authKind),
       connectedAt = Value(connectedAt);
  static Insertable<SyncAccount> custom({
    Expression<int>? id,
    Expression<String>? providerAccountId,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? authKind,
    Expression<bool>? isActive,
    Expression<DateTime>? connectedAt,
    Expression<String>? authSessionState,
    Expression<String>? authSessionError,
    Expression<String>? driveStartPageToken,
    Expression<String>? driveChangePageToken,
    Expression<DateTime>? lastSuccessfulSyncAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerAccountId != null) 'provider_account_id': providerAccountId,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (authKind != null) 'auth_kind': authKind,
      if (isActive != null) 'is_active': isActive,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (authSessionState != null) 'auth_session_state': authSessionState,
      if (authSessionError != null) 'auth_session_error': authSessionError,
      if (driveStartPageToken != null)
        'drive_start_page_token': driveStartPageToken,
      if (driveChangePageToken != null)
        'drive_change_page_token': driveChangePageToken,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
    });
  }

  SyncAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerAccountId,
    Value<String>? email,
    Value<String>? displayName,
    Value<String>? authKind,
    Value<bool>? isActive,
    Value<DateTime>? connectedAt,
    Value<String>? authSessionState,
    Value<String?>? authSessionError,
    Value<String?>? driveStartPageToken,
    Value<String?>? driveChangePageToken,
    Value<DateTime?>? lastSuccessfulSyncAt,
  }) {
    return SyncAccountsCompanion(
      id: id ?? this.id,
      providerAccountId: providerAccountId ?? this.providerAccountId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      authKind: authKind ?? this.authKind,
      isActive: isActive ?? this.isActive,
      connectedAt: connectedAt ?? this.connectedAt,
      authSessionState: authSessionState ?? this.authSessionState,
      authSessionError: authSessionError ?? this.authSessionError,
      driveStartPageToken: driveStartPageToken ?? this.driveStartPageToken,
      driveChangePageToken: driveChangePageToken ?? this.driveChangePageToken,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerAccountId.present) {
      map['provider_account_id'] = Variable<String>(providerAccountId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (authKind.present) {
      map['auth_kind'] = Variable<String>(authKind.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (authSessionState.present) {
      map['auth_session_state'] = Variable<String>(authSessionState.value);
    }
    if (authSessionError.present) {
      map['auth_session_error'] = Variable<String>(authSessionError.value);
    }
    if (driveStartPageToken.present) {
      map['drive_start_page_token'] = Variable<String>(
        driveStartPageToken.value,
      );
    }
    if (driveChangePageToken.present) {
      map['drive_change_page_token'] = Variable<String>(
        driveChangePageToken.value,
      );
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncAccountsCompanion(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('authKind: $authKind, ')
          ..write('isActive: $isActive, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('authSessionState: $authSessionState, ')
          ..write('authSessionError: $authSessionError, ')
          ..write('driveStartPageToken: $driveStartPageToken, ')
          ..write('driveChangePageToken: $driveChangePageToken, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt')
          ..write(')'))
        .toString();
  }
}

class $SyncRootsTable extends SyncRoots
    with TableInfo<$SyncRootsTable, SyncRoot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRootsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_accounts (id)',
    ),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentFolderIdMeta = const VerificationMeta(
    'parentFolderId',
  );
  @override
  late final GeneratedColumn<String> parentFolderId = GeneratedColumn<String>(
    'parent_folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DriveScanJobState.completed.value),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeJobIdMeta = const VerificationMeta(
    'activeJobId',
  );
  @override
  late final GeneratedColumn<int> activeJobId = GeneratedColumn<int>(
    'active_job_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedCountMeta = const VerificationMeta(
    'indexedCount',
  );
  @override
  late final GeneratedColumn<int> indexedCount = GeneratedColumn<int>(
    'indexed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metadataReadyCountMeta =
      const VerificationMeta('metadataReadyCount');
  @override
  late final GeneratedColumn<int> metadataReadyCount = GeneratedColumn<int>(
    'metadata_ready_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkReadyCountMeta = const VerificationMeta(
    'artworkReadyCount',
  );
  @override
  late final GeneratedColumn<int> artworkReadyCount = GeneratedColumn<int>(
    'artwork_ready_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    folderId,
    folderName,
    parentFolderId,
    syncState,
    lastSyncedAt,
    lastError,
    activeJobId,
    indexedCount,
    metadataReadyCount,
    artworkReadyCount,
    failedCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_roots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRoot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('parent_folder_id')) {
      context.handle(
        _parentFolderIdMeta,
        parentFolderId.isAcceptableOrUnknown(
          data['parent_folder_id']!,
          _parentFolderIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('active_job_id')) {
      context.handle(
        _activeJobIdMeta,
        activeJobId.isAcceptableOrUnknown(
          data['active_job_id']!,
          _activeJobIdMeta,
        ),
      );
    }
    if (data.containsKey('indexed_count')) {
      context.handle(
        _indexedCountMeta,
        indexedCount.isAcceptableOrUnknown(
          data['indexed_count']!,
          _indexedCountMeta,
        ),
      );
    }
    if (data.containsKey('metadata_ready_count')) {
      context.handle(
        _metadataReadyCountMeta,
        metadataReadyCount.isAcceptableOrUnknown(
          data['metadata_ready_count']!,
          _metadataReadyCountMeta,
        ),
      );
    }
    if (data.containsKey('artwork_ready_count')) {
      context.handle(
        _artworkReadyCountMeta,
        artworkReadyCount.isAcceptableOrUnknown(
          data['artwork_ready_count']!,
          _artworkReadyCountMeta,
        ),
      );
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, folderId},
  ];
  @override
  SyncRoot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRoot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      parentFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_folder_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      activeJobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_job_id'],
      ),
      indexedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indexed_count'],
      )!,
      metadataReadyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_ready_count'],
      )!,
      artworkReadyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artwork_ready_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
    );
  }

  @override
  $SyncRootsTable createAlias(String alias) {
    return $SyncRootsTable(attachedDatabase, alias);
  }
}

class SyncRoot extends DataClass implements Insertable<SyncRoot> {
  final int id;
  final int accountId;
  final String folderId;
  final String folderName;
  final String? parentFolderId;
  final String syncState;
  final DateTime? lastSyncedAt;
  final String? lastError;
  final int? activeJobId;
  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
  const SyncRoot({
    required this.id,
    required this.accountId,
    required this.folderId,
    required this.folderName,
    this.parentFolderId,
    required this.syncState,
    this.lastSyncedAt,
    this.lastError,
    this.activeJobId,
    required this.indexedCount,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['folder_id'] = Variable<String>(folderId);
    map['folder_name'] = Variable<String>(folderName);
    if (!nullToAbsent || parentFolderId != null) {
      map['parent_folder_id'] = Variable<String>(parentFolderId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || activeJobId != null) {
      map['active_job_id'] = Variable<int>(activeJobId);
    }
    map['indexed_count'] = Variable<int>(indexedCount);
    map['metadata_ready_count'] = Variable<int>(metadataReadyCount);
    map['artwork_ready_count'] = Variable<int>(artworkReadyCount);
    map['failed_count'] = Variable<int>(failedCount);
    return map;
  }

  SyncRootsCompanion toCompanion(bool nullToAbsent) {
    return SyncRootsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderId: Value(folderId),
      folderName: Value(folderName),
      parentFolderId: parentFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFolderId),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      activeJobId: activeJobId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeJobId),
      indexedCount: Value(indexedCount),
      metadataReadyCount: Value(metadataReadyCount),
      artworkReadyCount: Value(artworkReadyCount),
      failedCount: Value(failedCount),
    );
  }

  factory SyncRoot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRoot(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      folderId: serializer.fromJson<String>(json['folderId']),
      folderName: serializer.fromJson<String>(json['folderName']),
      parentFolderId: serializer.fromJson<String?>(json['parentFolderId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      activeJobId: serializer.fromJson<int?>(json['activeJobId']),
      indexedCount: serializer.fromJson<int>(json['indexedCount']),
      metadataReadyCount: serializer.fromJson<int>(json['metadataReadyCount']),
      artworkReadyCount: serializer.fromJson<int>(json['artworkReadyCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'folderId': serializer.toJson<String>(folderId),
      'folderName': serializer.toJson<String>(folderName),
      'parentFolderId': serializer.toJson<String?>(parentFolderId),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'activeJobId': serializer.toJson<int?>(activeJobId),
      'indexedCount': serializer.toJson<int>(indexedCount),
      'metadataReadyCount': serializer.toJson<int>(metadataReadyCount),
      'artworkReadyCount': serializer.toJson<int>(artworkReadyCount),
      'failedCount': serializer.toJson<int>(failedCount),
    };
  }

  SyncRoot copyWith({
    int? id,
    int? accountId,
    String? folderId,
    String? folderName,
    Value<String?> parentFolderId = const Value.absent(),
    String? syncState,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<int?> activeJobId = const Value.absent(),
    int? indexedCount,
    int? metadataReadyCount,
    int? artworkReadyCount,
    int? failedCount,
  }) => SyncRoot(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    folderId: folderId ?? this.folderId,
    folderName: folderName ?? this.folderName,
    parentFolderId: parentFolderId.present
        ? parentFolderId.value
        : this.parentFolderId,
    syncState: syncState ?? this.syncState,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    activeJobId: activeJobId.present ? activeJobId.value : this.activeJobId,
    indexedCount: indexedCount ?? this.indexedCount,
    metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
    artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
    failedCount: failedCount ?? this.failedCount,
  );
  SyncRoot copyWithCompanion(SyncRootsCompanion data) {
    return SyncRoot(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      parentFolderId: data.parentFolderId.present
          ? data.parentFolderId.value
          : this.parentFolderId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      activeJobId: data.activeJobId.present
          ? data.activeJobId.value
          : this.activeJobId,
      indexedCount: data.indexedCount.present
          ? data.indexedCount.value
          : this.indexedCount,
      metadataReadyCount: data.metadataReadyCount.present
          ? data.metadataReadyCount.value
          : this.metadataReadyCount,
      artworkReadyCount: data.artworkReadyCount.present
          ? data.artworkReadyCount.value
          : this.artworkReadyCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRoot(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('folderName: $folderName, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError, ')
          ..write('activeJobId: $activeJobId, ')
          ..write('indexedCount: $indexedCount, ')
          ..write('metadataReadyCount: $metadataReadyCount, ')
          ..write('artworkReadyCount: $artworkReadyCount, ')
          ..write('failedCount: $failedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    folderId,
    folderName,
    parentFolderId,
    syncState,
    lastSyncedAt,
    lastError,
    activeJobId,
    indexedCount,
    metadataReadyCount,
    artworkReadyCount,
    failedCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRoot &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderId == this.folderId &&
          other.folderName == this.folderName &&
          other.parentFolderId == this.parentFolderId &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastError == this.lastError &&
          other.activeJobId == this.activeJobId &&
          other.indexedCount == this.indexedCount &&
          other.metadataReadyCount == this.metadataReadyCount &&
          other.artworkReadyCount == this.artworkReadyCount &&
          other.failedCount == this.failedCount);
}

class SyncRootsCompanion extends UpdateCompanion<SyncRoot> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<String> folderId;
  final Value<String> folderName;
  final Value<String?> parentFolderId;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> lastError;
  final Value<int?> activeJobId;
  final Value<int> indexedCount;
  final Value<int> metadataReadyCount;
  final Value<int> artworkReadyCount;
  final Value<int> failedCount;
  const SyncRootsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.folderName = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.activeJobId = const Value.absent(),
    this.indexedCount = const Value.absent(),
    this.metadataReadyCount = const Value.absent(),
    this.artworkReadyCount = const Value.absent(),
    this.failedCount = const Value.absent(),
  });
  SyncRootsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required String folderId,
    required String folderName,
    this.parentFolderId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.activeJobId = const Value.absent(),
    this.indexedCount = const Value.absent(),
    this.metadataReadyCount = const Value.absent(),
    this.artworkReadyCount = const Value.absent(),
    this.failedCount = const Value.absent(),
  }) : accountId = Value(accountId),
       folderId = Value(folderId),
       folderName = Value(folderName);
  static Insertable<SyncRoot> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<String>? folderId,
    Expression<String>? folderName,
    Expression<String>? parentFolderId,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? lastError,
    Expression<int>? activeJobId,
    Expression<int>? indexedCount,
    Expression<int>? metadataReadyCount,
    Expression<int>? artworkReadyCount,
    Expression<int>? failedCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderId != null) 'folder_id': folderId,
      if (folderName != null) 'folder_name': folderName,
      if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastError != null) 'last_error': lastError,
      if (activeJobId != null) 'active_job_id': activeJobId,
      if (indexedCount != null) 'indexed_count': indexedCount,
      if (metadataReadyCount != null)
        'metadata_ready_count': metadataReadyCount,
      if (artworkReadyCount != null) 'artwork_ready_count': artworkReadyCount,
      if (failedCount != null) 'failed_count': failedCount,
    });
  }

  SyncRootsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<String>? folderId,
    Value<String>? folderName,
    Value<String?>? parentFolderId,
    Value<String>? syncState,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? lastError,
    Value<int?>? activeJobId,
    Value<int>? indexedCount,
    Value<int>? metadataReadyCount,
    Value<int>? artworkReadyCount,
    Value<int>? failedCount,
  }) {
    return SyncRootsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError ?? this.lastError,
      activeJobId: activeJobId ?? this.activeJobId,
      indexedCount: indexedCount ?? this.indexedCount,
      metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
      artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
      failedCount: failedCount ?? this.failedCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (parentFolderId.present) {
      map['parent_folder_id'] = Variable<String>(parentFolderId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (activeJobId.present) {
      map['active_job_id'] = Variable<int>(activeJobId.value);
    }
    if (indexedCount.present) {
      map['indexed_count'] = Variable<int>(indexedCount.value);
    }
    if (metadataReadyCount.present) {
      map['metadata_ready_count'] = Variable<int>(metadataReadyCount.value);
    }
    if (artworkReadyCount.present) {
      map['artwork_ready_count'] = Variable<int>(artworkReadyCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRootsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('folderName: $folderName, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError, ')
          ..write('activeJobId: $activeJobId, ')
          ..write('indexedCount: $indexedCount, ')
          ..write('metadataReadyCount: $metadataReadyCount, ')
          ..write('artworkReadyCount: $artworkReadyCount, ')
          ..write('failedCount: $failedCount')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<int> rootId = GeneratedColumn<int>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_roots (id)',
    ),
  );
  static const VerificationMeta _driveFileIdMeta = const VerificationMeta(
    'driveFileId',
  );
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
    'drive_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceKeyMeta = const VerificationMeta(
    'resourceKey',
  );
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
    'resource_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleSortMeta = const VerificationMeta(
    'titleSort',
  );
  @override
  late final GeneratedColumn<String> titleSort = GeneratedColumn<String>(
    'title_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistSortMeta = const VerificationMeta(
    'artistSort',
  );
  @override
  late final GeneratedColumn<String> artistSort = GeneratedColumn<String>(
    'artist_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _md5ChecksumMeta = const VerificationMeta(
    'md5Checksum',
  );
  @override
  late final GeneratedColumn<String> md5Checksum = GeneratedColumn<String>(
    'md5_checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedTimeMeta = const VerificationMeta(
    'modifiedTime',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedTime = GeneratedColumn<DateTime>(
    'modified_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkBlobIdMeta = const VerificationMeta(
    'artworkBlobId',
  );
  @override
  late final GeneratedColumn<int> artworkBlobId = GeneratedColumn<int>(
    'artwork_blob_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkStatusMeta = const VerificationMeta(
    'artworkStatus',
  );
  @override
  late final GeneratedColumn<String> artworkStatus = GeneratedColumn<String>(
    'artwork_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TrackArtworkStatus.pending.value),
  );
  static const VerificationMeta _cachePathMeta = const VerificationMeta(
    'cachePath',
  );
  @override
  late final GeneratedColumn<String> cachePath = GeneratedColumn<String>(
    'cache_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cacheStatusMeta = const VerificationMeta(
    'cacheStatus',
  );
  @override
  late final GeneratedColumn<String> cacheStatus = GeneratedColumn<String>(
    'cache_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _metadataStatusMeta = const VerificationMeta(
    'metadataStatus',
  );
  @override
  late final GeneratedColumn<String> metadataStatus = GeneratedColumn<String>(
    'metadata_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TrackMetadataStatus.pending.value),
  );
  static const VerificationMeta _indexStatusMeta = const VerificationMeta(
    'indexStatus',
  );
  @override
  late final GeneratedColumn<String> indexStatus = GeneratedColumn<String>(
    'index_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TrackIndexStatus.active.value),
  );
  static const VerificationMeta _metadataSchemaVersionMeta =
      const VerificationMeta('metadataSchemaVersion');
  @override
  late final GeneratedColumn<int> metadataSchemaVersion = GeneratedColumn<int>(
    'metadata_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(currentTrackMetadataSchemaVersion),
  );
  static const VerificationMeta _contentFingerprintMeta =
      const VerificationMeta('contentFingerprint');
  @override
  late final GeneratedColumn<String> contentFingerprint =
      GeneratedColumn<String>(
        'content_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _insertedAtMeta = const VerificationMeta(
    'insertedAt',
  );
  @override
  late final GeneratedColumn<DateTime> insertedAt = GeneratedColumn<DateTime>(
    'inserted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _discoveredAtMeta = const VerificationMeta(
    'discoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> discoveredAt = GeneratedColumn<DateTime>(
    'discovered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootId,
    driveFileId,
    resourceKey,
    fileName,
    title,
    titleSort,
    artist,
    artistSort,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    discNumber,
    durationMs,
    mimeType,
    sizeBytes,
    md5Checksum,
    modifiedTime,
    artworkUri,
    artworkBlobId,
    artworkStatus,
    cachePath,
    cacheStatus,
    metadataStatus,
    indexStatus,
    metadataSchemaVersion,
    contentFingerprint,
    playCount,
    lastPlayedAt,
    isFavorite,
    insertedAt,
    discoveredAt,
    updatedAt,
    removedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
        _driveFileIdMeta,
        driveFileId.isAcceptableOrUnknown(
          data['drive_file_id']!,
          _driveFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_driveFileIdMeta);
    }
    if (data.containsKey('resource_key')) {
      context.handle(
        _resourceKeyMeta,
        resourceKey.isAcceptableOrUnknown(
          data['resource_key']!,
          _resourceKeyMeta,
        ),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_sort')) {
      context.handle(
        _titleSortMeta,
        titleSort.isAcceptableOrUnknown(data['title_sort']!, _titleSortMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('artist_sort')) {
      context.handle(
        _artistSortMeta,
        artistSort.isAcceptableOrUnknown(data['artist_sort']!, _artistSortMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_albumArtistMeta);
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    } else if (isInserting) {
      context.missing(_genreMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('md5_checksum')) {
      context.handle(
        _md5ChecksumMeta,
        md5Checksum.isAcceptableOrUnknown(
          data['md5_checksum']!,
          _md5ChecksumMeta,
        ),
      );
    }
    if (data.containsKey('modified_time')) {
      context.handle(
        _modifiedTimeMeta,
        modifiedTime.isAcceptableOrUnknown(
          data['modified_time']!,
          _modifiedTimeMeta,
        ),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    }
    if (data.containsKey('artwork_blob_id')) {
      context.handle(
        _artworkBlobIdMeta,
        artworkBlobId.isAcceptableOrUnknown(
          data['artwork_blob_id']!,
          _artworkBlobIdMeta,
        ),
      );
    }
    if (data.containsKey('artwork_status')) {
      context.handle(
        _artworkStatusMeta,
        artworkStatus.isAcceptableOrUnknown(
          data['artwork_status']!,
          _artworkStatusMeta,
        ),
      );
    }
    if (data.containsKey('cache_path')) {
      context.handle(
        _cachePathMeta,
        cachePath.isAcceptableOrUnknown(data['cache_path']!, _cachePathMeta),
      );
    }
    if (data.containsKey('cache_status')) {
      context.handle(
        _cacheStatusMeta,
        cacheStatus.isAcceptableOrUnknown(
          data['cache_status']!,
          _cacheStatusMeta,
        ),
      );
    }
    if (data.containsKey('metadata_status')) {
      context.handle(
        _metadataStatusMeta,
        metadataStatus.isAcceptableOrUnknown(
          data['metadata_status']!,
          _metadataStatusMeta,
        ),
      );
    }
    if (data.containsKey('index_status')) {
      context.handle(
        _indexStatusMeta,
        indexStatus.isAcceptableOrUnknown(
          data['index_status']!,
          _indexStatusMeta,
        ),
      );
    }
    if (data.containsKey('metadata_schema_version')) {
      context.handle(
        _metadataSchemaVersionMeta,
        metadataSchemaVersion.isAcceptableOrUnknown(
          data['metadata_schema_version']!,
          _metadataSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('content_fingerprint')) {
      context.handle(
        _contentFingerprintMeta,
        contentFingerprint.isAcceptableOrUnknown(
          data['content_fingerprint']!,
          _contentFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('inserted_at')) {
      context.handle(
        _insertedAtMeta,
        insertedAt.isAcceptableOrUnknown(data['inserted_at']!, _insertedAtMeta),
      );
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
        _discoveredAtMeta,
        discoveredAt.isAcceptableOrUnknown(
          data['discovered_at']!,
          _discoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {driveFileId},
  ];
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_id'],
      )!,
      driveFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_file_id'],
      )!,
      resourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_key'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_sort'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      artistSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_sort'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      )!,
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      md5Checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}md5_checksum'],
      ),
      modifiedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_time'],
      ),
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      ),
      artworkBlobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artwork_blob_id'],
      ),
      artworkStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_status'],
      )!,
      cachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_path'],
      ),
      cacheStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_status'],
      )!,
      metadataStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_status'],
      )!,
      indexStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}index_status'],
      )!,
      metadataSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_schema_version'],
      )!,
      contentFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_fingerprint'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      insertedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inserted_at'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final int id;
  final int rootId;
  final String driveFileId;
  final String? resourceKey;
  final String fileName;
  final String title;
  final String titleSort;
  final String artist;
  final String artistSort;
  final String album;
  final String albumArtist;
  final String genre;
  final int? year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
  final String mimeType;
  final int? sizeBytes;
  final String? md5Checksum;
  final DateTime? modifiedTime;
  final String? artworkUri;
  final int? artworkBlobId;
  final String artworkStatus;
  final String? cachePath;
  final String cacheStatus;
  final String metadataStatus;
  final String indexStatus;
  final int metadataSchemaVersion;
  final String? contentFingerprint;
  final int playCount;
  final DateTime? lastPlayedAt;
  final bool isFavorite;
  final DateTime insertedAt;
  final DateTime discoveredAt;
  final DateTime updatedAt;
  final DateTime? removedAt;
  const Track({
    required this.id,
    required this.rootId,
    required this.driveFileId,
    this.resourceKey,
    required this.fileName,
    required this.title,
    required this.titleSort,
    required this.artist,
    required this.artistSort,
    required this.album,
    required this.albumArtist,
    required this.genre,
    this.year,
    required this.trackNumber,
    required this.discNumber,
    required this.durationMs,
    required this.mimeType,
    this.sizeBytes,
    this.md5Checksum,
    this.modifiedTime,
    this.artworkUri,
    this.artworkBlobId,
    required this.artworkStatus,
    this.cachePath,
    required this.cacheStatus,
    required this.metadataStatus,
    required this.indexStatus,
    required this.metadataSchemaVersion,
    this.contentFingerprint,
    required this.playCount,
    this.lastPlayedAt,
    required this.isFavorite,
    required this.insertedAt,
    required this.discoveredAt,
    required this.updatedAt,
    this.removedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['root_id'] = Variable<int>(rootId);
    map['drive_file_id'] = Variable<String>(driveFileId);
    if (!nullToAbsent || resourceKey != null) {
      map['resource_key'] = Variable<String>(resourceKey);
    }
    map['file_name'] = Variable<String>(fileName);
    map['title'] = Variable<String>(title);
    map['title_sort'] = Variable<String>(titleSort);
    map['artist'] = Variable<String>(artist);
    map['artist_sort'] = Variable<String>(artistSort);
    map['album'] = Variable<String>(album);
    map['album_artist'] = Variable<String>(albumArtist);
    map['genre'] = Variable<String>(genre);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['track_number'] = Variable<int>(trackNumber);
    map['disc_number'] = Variable<int>(discNumber);
    map['duration_ms'] = Variable<int>(durationMs);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || md5Checksum != null) {
      map['md5_checksum'] = Variable<String>(md5Checksum);
    }
    if (!nullToAbsent || modifiedTime != null) {
      map['modified_time'] = Variable<DateTime>(modifiedTime);
    }
    if (!nullToAbsent || artworkUri != null) {
      map['artwork_uri'] = Variable<String>(artworkUri);
    }
    if (!nullToAbsent || artworkBlobId != null) {
      map['artwork_blob_id'] = Variable<int>(artworkBlobId);
    }
    map['artwork_status'] = Variable<String>(artworkStatus);
    if (!nullToAbsent || cachePath != null) {
      map['cache_path'] = Variable<String>(cachePath);
    }
    map['cache_status'] = Variable<String>(cacheStatus);
    map['metadata_status'] = Variable<String>(metadataStatus);
    map['index_status'] = Variable<String>(indexStatus);
    map['metadata_schema_version'] = Variable<int>(metadataSchemaVersion);
    if (!nullToAbsent || contentFingerprint != null) {
      map['content_fingerprint'] = Variable<String>(contentFingerprint);
    }
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['inserted_at'] = Variable<DateTime>(insertedAt);
    map['discovered_at'] = Variable<DateTime>(discoveredAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      rootId: Value(rootId),
      driveFileId: Value(driveFileId),
      resourceKey: resourceKey == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceKey),
      fileName: Value(fileName),
      title: Value(title),
      titleSort: Value(titleSort),
      artist: Value(artist),
      artistSort: Value(artistSort),
      album: Value(album),
      albumArtist: Value(albumArtist),
      genre: Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      trackNumber: Value(trackNumber),
      discNumber: Value(discNumber),
      durationMs: Value(durationMs),
      mimeType: Value(mimeType),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      md5Checksum: md5Checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(md5Checksum),
      modifiedTime: modifiedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedTime),
      artworkUri: artworkUri == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUri),
      artworkBlobId: artworkBlobId == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkBlobId),
      artworkStatus: Value(artworkStatus),
      cachePath: cachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cachePath),
      cacheStatus: Value(cacheStatus),
      metadataStatus: Value(metadataStatus),
      indexStatus: Value(indexStatus),
      metadataSchemaVersion: Value(metadataSchemaVersion),
      contentFingerprint: contentFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(contentFingerprint),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      isFavorite: Value(isFavorite),
      insertedAt: Value(insertedAt),
      discoveredAt: Value(discoveredAt),
      updatedAt: Value(updatedAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<int>(json['id']),
      rootId: serializer.fromJson<int>(json['rootId']),
      driveFileId: serializer.fromJson<String>(json['driveFileId']),
      resourceKey: serializer.fromJson<String?>(json['resourceKey']),
      fileName: serializer.fromJson<String>(json['fileName']),
      title: serializer.fromJson<String>(json['title']),
      titleSort: serializer.fromJson<String>(json['titleSort']),
      artist: serializer.fromJson<String>(json['artist']),
      artistSort: serializer.fromJson<String>(json['artistSort']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String>(json['albumArtist']),
      genre: serializer.fromJson<String>(json['genre']),
      year: serializer.fromJson<int?>(json['year']),
      trackNumber: serializer.fromJson<int>(json['trackNumber']),
      discNumber: serializer.fromJson<int>(json['discNumber']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      md5Checksum: serializer.fromJson<String?>(json['md5Checksum']),
      modifiedTime: serializer.fromJson<DateTime?>(json['modifiedTime']),
      artworkUri: serializer.fromJson<String?>(json['artworkUri']),
      artworkBlobId: serializer.fromJson<int?>(json['artworkBlobId']),
      artworkStatus: serializer.fromJson<String>(json['artworkStatus']),
      cachePath: serializer.fromJson<String?>(json['cachePath']),
      cacheStatus: serializer.fromJson<String>(json['cacheStatus']),
      metadataStatus: serializer.fromJson<String>(json['metadataStatus']),
      indexStatus: serializer.fromJson<String>(json['indexStatus']),
      metadataSchemaVersion: serializer.fromJson<int>(
        json['metadataSchemaVersion'],
      ),
      contentFingerprint: serializer.fromJson<String?>(
        json['contentFingerprint'],
      ),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      insertedAt: serializer.fromJson<DateTime>(json['insertedAt']),
      discoveredAt: serializer.fromJson<DateTime>(json['discoveredAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rootId': serializer.toJson<int>(rootId),
      'driveFileId': serializer.toJson<String>(driveFileId),
      'resourceKey': serializer.toJson<String?>(resourceKey),
      'fileName': serializer.toJson<String>(fileName),
      'title': serializer.toJson<String>(title),
      'titleSort': serializer.toJson<String>(titleSort),
      'artist': serializer.toJson<String>(artist),
      'artistSort': serializer.toJson<String>(artistSort),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String>(albumArtist),
      'genre': serializer.toJson<String>(genre),
      'year': serializer.toJson<int?>(year),
      'trackNumber': serializer.toJson<int>(trackNumber),
      'discNumber': serializer.toJson<int>(discNumber),
      'durationMs': serializer.toJson<int>(durationMs),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'md5Checksum': serializer.toJson<String?>(md5Checksum),
      'modifiedTime': serializer.toJson<DateTime?>(modifiedTime),
      'artworkUri': serializer.toJson<String?>(artworkUri),
      'artworkBlobId': serializer.toJson<int?>(artworkBlobId),
      'artworkStatus': serializer.toJson<String>(artworkStatus),
      'cachePath': serializer.toJson<String?>(cachePath),
      'cacheStatus': serializer.toJson<String>(cacheStatus),
      'metadataStatus': serializer.toJson<String>(metadataStatus),
      'indexStatus': serializer.toJson<String>(indexStatus),
      'metadataSchemaVersion': serializer.toJson<int>(metadataSchemaVersion),
      'contentFingerprint': serializer.toJson<String?>(contentFingerprint),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'insertedAt': serializer.toJson<DateTime>(insertedAt),
      'discoveredAt': serializer.toJson<DateTime>(discoveredAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
    };
  }

  Track copyWith({
    int? id,
    int? rootId,
    String? driveFileId,
    Value<String?> resourceKey = const Value.absent(),
    String? fileName,
    String? title,
    String? titleSort,
    String? artist,
    String? artistSort,
    String? album,
    String? albumArtist,
    String? genre,
    Value<int?> year = const Value.absent(),
    int? trackNumber,
    int? discNumber,
    int? durationMs,
    String? mimeType,
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> md5Checksum = const Value.absent(),
    Value<DateTime?> modifiedTime = const Value.absent(),
    Value<String?> artworkUri = const Value.absent(),
    Value<int?> artworkBlobId = const Value.absent(),
    String? artworkStatus,
    Value<String?> cachePath = const Value.absent(),
    String? cacheStatus,
    String? metadataStatus,
    String? indexStatus,
    int? metadataSchemaVersion,
    Value<String?> contentFingerprint = const Value.absent(),
    int? playCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    bool? isFavorite,
    DateTime? insertedAt,
    DateTime? discoveredAt,
    DateTime? updatedAt,
    Value<DateTime?> removedAt = const Value.absent(),
  }) => Track(
    id: id ?? this.id,
    rootId: rootId ?? this.rootId,
    driveFileId: driveFileId ?? this.driveFileId,
    resourceKey: resourceKey.present ? resourceKey.value : this.resourceKey,
    fileName: fileName ?? this.fileName,
    title: title ?? this.title,
    titleSort: titleSort ?? this.titleSort,
    artist: artist ?? this.artist,
    artistSort: artistSort ?? this.artistSort,
    album: album ?? this.album,
    albumArtist: albumArtist ?? this.albumArtist,
    genre: genre ?? this.genre,
    year: year.present ? year.value : this.year,
    trackNumber: trackNumber ?? this.trackNumber,
    discNumber: discNumber ?? this.discNumber,
    durationMs: durationMs ?? this.durationMs,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    md5Checksum: md5Checksum.present ? md5Checksum.value : this.md5Checksum,
    modifiedTime: modifiedTime.present ? modifiedTime.value : this.modifiedTime,
    artworkUri: artworkUri.present ? artworkUri.value : this.artworkUri,
    artworkBlobId: artworkBlobId.present
        ? artworkBlobId.value
        : this.artworkBlobId,
    artworkStatus: artworkStatus ?? this.artworkStatus,
    cachePath: cachePath.present ? cachePath.value : this.cachePath,
    cacheStatus: cacheStatus ?? this.cacheStatus,
    metadataStatus: metadataStatus ?? this.metadataStatus,
    indexStatus: indexStatus ?? this.indexStatus,
    metadataSchemaVersion: metadataSchemaVersion ?? this.metadataSchemaVersion,
    contentFingerprint: contentFingerprint.present
        ? contentFingerprint.value
        : this.contentFingerprint,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    isFavorite: isFavorite ?? this.isFavorite,
    insertedAt: insertedAt ?? this.insertedAt,
    discoveredAt: discoveredAt ?? this.discoveredAt,
    updatedAt: updatedAt ?? this.updatedAt,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      driveFileId: data.driveFileId.present
          ? data.driveFileId.value
          : this.driveFileId,
      resourceKey: data.resourceKey.present
          ? data.resourceKey.value
          : this.resourceKey,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      title: data.title.present ? data.title.value : this.title,
      titleSort: data.titleSort.present ? data.titleSort.value : this.titleSort,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistSort: data.artistSort.present
          ? data.artistSort.value
          : this.artistSort,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      md5Checksum: data.md5Checksum.present
          ? data.md5Checksum.value
          : this.md5Checksum,
      modifiedTime: data.modifiedTime.present
          ? data.modifiedTime.value
          : this.modifiedTime,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      artworkBlobId: data.artworkBlobId.present
          ? data.artworkBlobId.value
          : this.artworkBlobId,
      artworkStatus: data.artworkStatus.present
          ? data.artworkStatus.value
          : this.artworkStatus,
      cachePath: data.cachePath.present ? data.cachePath.value : this.cachePath,
      cacheStatus: data.cacheStatus.present
          ? data.cacheStatus.value
          : this.cacheStatus,
      metadataStatus: data.metadataStatus.present
          ? data.metadataStatus.value
          : this.metadataStatus,
      indexStatus: data.indexStatus.present
          ? data.indexStatus.value
          : this.indexStatus,
      metadataSchemaVersion: data.metadataSchemaVersion.present
          ? data.metadataSchemaVersion.value
          : this.metadataSchemaVersion,
      contentFingerprint: data.contentFingerprint.present
          ? data.contentFingerprint.value
          : this.contentFingerprint,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      insertedAt: data.insertedAt.present
          ? data.insertedAt.value
          : this.insertedAt,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('artist: $artist, ')
          ..write('artistSort: $artistSort, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('md5Checksum: $md5Checksum, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('artworkBlobId: $artworkBlobId, ')
          ..write('artworkStatus: $artworkStatus, ')
          ..write('cachePath: $cachePath, ')
          ..write('cacheStatus: $cacheStatus, ')
          ..write('metadataStatus: $metadataStatus, ')
          ..write('indexStatus: $indexStatus, ')
          ..write('metadataSchemaVersion: $metadataSchemaVersion, ')
          ..write('contentFingerprint: $contentFingerprint, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('insertedAt: $insertedAt, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    rootId,
    driveFileId,
    resourceKey,
    fileName,
    title,
    titleSort,
    artist,
    artistSort,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    discNumber,
    durationMs,
    mimeType,
    sizeBytes,
    md5Checksum,
    modifiedTime,
    artworkUri,
    artworkBlobId,
    artworkStatus,
    cachePath,
    cacheStatus,
    metadataStatus,
    indexStatus,
    metadataSchemaVersion,
    contentFingerprint,
    playCount,
    lastPlayedAt,
    isFavorite,
    insertedAt,
    discoveredAt,
    updatedAt,
    removedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.rootId == this.rootId &&
          other.driveFileId == this.driveFileId &&
          other.resourceKey == this.resourceKey &&
          other.fileName == this.fileName &&
          other.title == this.title &&
          other.titleSort == this.titleSort &&
          other.artist == this.artist &&
          other.artistSort == this.artistSort &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.trackNumber == this.trackNumber &&
          other.discNumber == this.discNumber &&
          other.durationMs == this.durationMs &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.md5Checksum == this.md5Checksum &&
          other.modifiedTime == this.modifiedTime &&
          other.artworkUri == this.artworkUri &&
          other.artworkBlobId == this.artworkBlobId &&
          other.artworkStatus == this.artworkStatus &&
          other.cachePath == this.cachePath &&
          other.cacheStatus == this.cacheStatus &&
          other.metadataStatus == this.metadataStatus &&
          other.indexStatus == this.indexStatus &&
          other.metadataSchemaVersion == this.metadataSchemaVersion &&
          other.contentFingerprint == this.contentFingerprint &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.isFavorite == this.isFavorite &&
          other.insertedAt == this.insertedAt &&
          other.discoveredAt == this.discoveredAt &&
          other.updatedAt == this.updatedAt &&
          other.removedAt == this.removedAt);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<int> id;
  final Value<int> rootId;
  final Value<String> driveFileId;
  final Value<String?> resourceKey;
  final Value<String> fileName;
  final Value<String> title;
  final Value<String> titleSort;
  final Value<String> artist;
  final Value<String> artistSort;
  final Value<String> album;
  final Value<String> albumArtist;
  final Value<String> genre;
  final Value<int?> year;
  final Value<int> trackNumber;
  final Value<int> discNumber;
  final Value<int> durationMs;
  final Value<String> mimeType;
  final Value<int?> sizeBytes;
  final Value<String?> md5Checksum;
  final Value<DateTime?> modifiedTime;
  final Value<String?> artworkUri;
  final Value<int?> artworkBlobId;
  final Value<String> artworkStatus;
  final Value<String?> cachePath;
  final Value<String> cacheStatus;
  final Value<String> metadataStatus;
  final Value<String> indexStatus;
  final Value<int> metadataSchemaVersion;
  final Value<String?> contentFingerprint;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<bool> isFavorite;
  final Value<DateTime> insertedAt;
  final Value<DateTime> discoveredAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> removedAt;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.rootId = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.resourceKey = const Value.absent(),
    this.fileName = const Value.absent(),
    this.title = const Value.absent(),
    this.titleSort = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistSort = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.md5Checksum = const Value.absent(),
    this.modifiedTime = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.artworkBlobId = const Value.absent(),
    this.artworkStatus = const Value.absent(),
    this.cachePath = const Value.absent(),
    this.cacheStatus = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.indexStatus = const Value.absent(),
    this.metadataSchemaVersion = const Value.absent(),
    this.contentFingerprint = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.insertedAt = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required int rootId,
    required String driveFileId,
    this.resourceKey = const Value.absent(),
    required String fileName,
    required String title,
    this.titleSort = const Value.absent(),
    required String artist,
    this.artistSort = const Value.absent(),
    required String album,
    required String albumArtist,
    required String genre,
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String mimeType,
    this.sizeBytes = const Value.absent(),
    this.md5Checksum = const Value.absent(),
    this.modifiedTime = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.artworkBlobId = const Value.absent(),
    this.artworkStatus = const Value.absent(),
    this.cachePath = const Value.absent(),
    this.cacheStatus = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.indexStatus = const Value.absent(),
    this.metadataSchemaVersion = const Value.absent(),
    this.contentFingerprint = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.insertedAt = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
  }) : rootId = Value(rootId),
       driveFileId = Value(driveFileId),
       fileName = Value(fileName),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       albumArtist = Value(albumArtist),
       genre = Value(genre),
       mimeType = Value(mimeType);
  static Insertable<Track> custom({
    Expression<int>? id,
    Expression<int>? rootId,
    Expression<String>? driveFileId,
    Expression<String>? resourceKey,
    Expression<String>? fileName,
    Expression<String>? title,
    Expression<String>? titleSort,
    Expression<String>? artist,
    Expression<String>? artistSort,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? trackNumber,
    Expression<int>? discNumber,
    Expression<int>? durationMs,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? md5Checksum,
    Expression<DateTime>? modifiedTime,
    Expression<String>? artworkUri,
    Expression<int>? artworkBlobId,
    Expression<String>? artworkStatus,
    Expression<String>? cachePath,
    Expression<String>? cacheStatus,
    Expression<String>? metadataStatus,
    Expression<String>? indexStatus,
    Expression<int>? metadataSchemaVersion,
    Expression<String>? contentFingerprint,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<bool>? isFavorite,
    Expression<DateTime>? insertedAt,
    Expression<DateTime>? discoveredAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? removedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootId != null) 'root_id': rootId,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (resourceKey != null) 'resource_key': resourceKey,
      if (fileName != null) 'file_name': fileName,
      if (title != null) 'title': title,
      if (titleSort != null) 'title_sort': titleSort,
      if (artist != null) 'artist': artist,
      if (artistSort != null) 'artist_sort': artistSort,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (trackNumber != null) 'track_number': trackNumber,
      if (discNumber != null) 'disc_number': discNumber,
      if (durationMs != null) 'duration_ms': durationMs,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (md5Checksum != null) 'md5_checksum': md5Checksum,
      if (modifiedTime != null) 'modified_time': modifiedTime,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (artworkBlobId != null) 'artwork_blob_id': artworkBlobId,
      if (artworkStatus != null) 'artwork_status': artworkStatus,
      if (cachePath != null) 'cache_path': cachePath,
      if (cacheStatus != null) 'cache_status': cacheStatus,
      if (metadataStatus != null) 'metadata_status': metadataStatus,
      if (indexStatus != null) 'index_status': indexStatus,
      if (metadataSchemaVersion != null)
        'metadata_schema_version': metadataSchemaVersion,
      if (contentFingerprint != null) 'content_fingerprint': contentFingerprint,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (insertedAt != null) 'inserted_at': insertedAt,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (removedAt != null) 'removed_at': removedAt,
    });
  }

  TracksCompanion copyWith({
    Value<int>? id,
    Value<int>? rootId,
    Value<String>? driveFileId,
    Value<String?>? resourceKey,
    Value<String>? fileName,
    Value<String>? title,
    Value<String>? titleSort,
    Value<String>? artist,
    Value<String>? artistSort,
    Value<String>? album,
    Value<String>? albumArtist,
    Value<String>? genre,
    Value<int?>? year,
    Value<int>? trackNumber,
    Value<int>? discNumber,
    Value<int>? durationMs,
    Value<String>? mimeType,
    Value<int?>? sizeBytes,
    Value<String?>? md5Checksum,
    Value<DateTime?>? modifiedTime,
    Value<String?>? artworkUri,
    Value<int?>? artworkBlobId,
    Value<String>? artworkStatus,
    Value<String?>? cachePath,
    Value<String>? cacheStatus,
    Value<String>? metadataStatus,
    Value<String>? indexStatus,
    Value<int>? metadataSchemaVersion,
    Value<String?>? contentFingerprint,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayedAt,
    Value<bool>? isFavorite,
    Value<DateTime>? insertedAt,
    Value<DateTime>? discoveredAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? removedAt,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      rootId: rootId ?? this.rootId,
      driveFileId: driveFileId ?? this.driveFileId,
      resourceKey: resourceKey ?? this.resourceKey,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      titleSort: titleSort ?? this.titleSort,
      artist: artist ?? this.artist,
      artistSort: artistSort ?? this.artistSort,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      durationMs: durationMs ?? this.durationMs,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      md5Checksum: md5Checksum ?? this.md5Checksum,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      artworkUri: artworkUri ?? this.artworkUri,
      artworkBlobId: artworkBlobId ?? this.artworkBlobId,
      artworkStatus: artworkStatus ?? this.artworkStatus,
      cachePath: cachePath ?? this.cachePath,
      cacheStatus: cacheStatus ?? this.cacheStatus,
      metadataStatus: metadataStatus ?? this.metadataStatus,
      indexStatus: indexStatus ?? this.indexStatus,
      metadataSchemaVersion:
          metadataSchemaVersion ?? this.metadataSchemaVersion,
      contentFingerprint: contentFingerprint ?? this.contentFingerprint,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      insertedAt: insertedAt ?? this.insertedAt,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      removedAt: removedAt ?? this.removedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<int>(rootId.value);
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleSort.present) {
      map['title_sort'] = Variable<String>(titleSort.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistSort.present) {
      map['artist_sort'] = Variable<String>(artistSort.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (md5Checksum.present) {
      map['md5_checksum'] = Variable<String>(md5Checksum.value);
    }
    if (modifiedTime.present) {
      map['modified_time'] = Variable<DateTime>(modifiedTime.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (artworkBlobId.present) {
      map['artwork_blob_id'] = Variable<int>(artworkBlobId.value);
    }
    if (artworkStatus.present) {
      map['artwork_status'] = Variable<String>(artworkStatus.value);
    }
    if (cachePath.present) {
      map['cache_path'] = Variable<String>(cachePath.value);
    }
    if (cacheStatus.present) {
      map['cache_status'] = Variable<String>(cacheStatus.value);
    }
    if (metadataStatus.present) {
      map['metadata_status'] = Variable<String>(metadataStatus.value);
    }
    if (indexStatus.present) {
      map['index_status'] = Variable<String>(indexStatus.value);
    }
    if (metadataSchemaVersion.present) {
      map['metadata_schema_version'] = Variable<int>(
        metadataSchemaVersion.value,
      );
    }
    if (contentFingerprint.present) {
      map['content_fingerprint'] = Variable<String>(contentFingerprint.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (insertedAt.present) {
      map['inserted_at'] = Variable<DateTime>(insertedAt.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('artist: $artist, ')
          ..write('artistSort: $artistSort, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('md5Checksum: $md5Checksum, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('artworkBlobId: $artworkBlobId, ')
          ..write('artworkStatus: $artworkStatus, ')
          ..write('cachePath: $cachePath, ')
          ..write('cacheStatus: $cacheStatus, ')
          ..write('metadataStatus: $metadataStatus, ')
          ..write('indexStatus: $indexStatus, ')
          ..write('metadataSchemaVersion: $metadataSchemaVersion, ')
          ..write('contentFingerprint: $contentFingerprint, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('insertedAt: $insertedAt, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }
}

class $LibraryProjectionMetasTable extends LibraryProjectionMetas
    with TableInfo<$LibraryProjectionMetasTable, LibraryProjectionMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryProjectionMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backfillStateMeta = const VerificationMeta(
    'backfillState',
  );
  @override
  late final GeneratedColumn<String> backfillState = GeneratedColumn<String>(
    'backfill_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(LibraryProjectionBackfillState.pending.name),
  );
  static const VerificationMeta _lastBackfillAtMeta = const VerificationMeta(
    'lastBackfillAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastBackfillAt =
      GeneratedColumn<DateTime>(
        'last_backfill_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    revision,
    backfillState,
    lastBackfillAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_projection_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryProjectionMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('backfill_state')) {
      context.handle(
        _backfillStateMeta,
        backfillState.isAcceptableOrUnknown(
          data['backfill_state']!,
          _backfillStateMeta,
        ),
      );
    }
    if (data.containsKey('last_backfill_at')) {
      context.handle(
        _lastBackfillAtMeta,
        lastBackfillAt.isAcceptableOrUnknown(
          data['last_backfill_at']!,
          _lastBackfillAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryProjectionMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryProjectionMeta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      backfillState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backfill_state'],
      )!,
      lastBackfillAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_backfill_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $LibraryProjectionMetasTable createAlias(String alias) {
    return $LibraryProjectionMetasTable(attachedDatabase, alias);
  }
}

class LibraryProjectionMeta extends DataClass
    implements Insertable<LibraryProjectionMeta> {
  final int id;
  final int revision;
  final String backfillState;
  final DateTime? lastBackfillAt;
  final String? lastError;
  const LibraryProjectionMeta({
    required this.id,
    required this.revision,
    required this.backfillState,
    this.lastBackfillAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['revision'] = Variable<int>(revision);
    map['backfill_state'] = Variable<String>(backfillState);
    if (!nullToAbsent || lastBackfillAt != null) {
      map['last_backfill_at'] = Variable<DateTime>(lastBackfillAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  LibraryProjectionMetasCompanion toCompanion(bool nullToAbsent) {
    return LibraryProjectionMetasCompanion(
      id: Value(id),
      revision: Value(revision),
      backfillState: Value(backfillState),
      lastBackfillAt: lastBackfillAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackfillAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory LibraryProjectionMeta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryProjectionMeta(
      id: serializer.fromJson<int>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      backfillState: serializer.fromJson<String>(json['backfillState']),
      lastBackfillAt: serializer.fromJson<DateTime?>(json['lastBackfillAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'revision': serializer.toJson<int>(revision),
      'backfillState': serializer.toJson<String>(backfillState),
      'lastBackfillAt': serializer.toJson<DateTime?>(lastBackfillAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  LibraryProjectionMeta copyWith({
    int? id,
    int? revision,
    String? backfillState,
    Value<DateTime?> lastBackfillAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => LibraryProjectionMeta(
    id: id ?? this.id,
    revision: revision ?? this.revision,
    backfillState: backfillState ?? this.backfillState,
    lastBackfillAt: lastBackfillAt.present
        ? lastBackfillAt.value
        : this.lastBackfillAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  LibraryProjectionMeta copyWithCompanion(
    LibraryProjectionMetasCompanion data,
  ) {
    return LibraryProjectionMeta(
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      backfillState: data.backfillState.present
          ? data.backfillState.value
          : this.backfillState,
      lastBackfillAt: data.lastBackfillAt.present
          ? data.lastBackfillAt.value
          : this.lastBackfillAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryProjectionMeta(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('backfillState: $backfillState, ')
          ..write('lastBackfillAt: $lastBackfillAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, revision, backfillState, lastBackfillAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryProjectionMeta &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.backfillState == this.backfillState &&
          other.lastBackfillAt == this.lastBackfillAt &&
          other.lastError == this.lastError);
}

class LibraryProjectionMetasCompanion
    extends UpdateCompanion<LibraryProjectionMeta> {
  final Value<int> id;
  final Value<int> revision;
  final Value<String> backfillState;
  final Value<DateTime?> lastBackfillAt;
  final Value<String?> lastError;
  const LibraryProjectionMetasCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.backfillState = const Value.absent(),
    this.lastBackfillAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  LibraryProjectionMetasCompanion.insert({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.backfillState = const Value.absent(),
    this.lastBackfillAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  static Insertable<LibraryProjectionMeta> custom({
    Expression<int>? id,
    Expression<int>? revision,
    Expression<String>? backfillState,
    Expression<DateTime>? lastBackfillAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (backfillState != null) 'backfill_state': backfillState,
      if (lastBackfillAt != null) 'last_backfill_at': lastBackfillAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  LibraryProjectionMetasCompanion copyWith({
    Value<int>? id,
    Value<int>? revision,
    Value<String>? backfillState,
    Value<DateTime?>? lastBackfillAt,
    Value<String?>? lastError,
  }) {
    return LibraryProjectionMetasCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      backfillState: backfillState ?? this.backfillState,
      lastBackfillAt: lastBackfillAt ?? this.lastBackfillAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (backfillState.present) {
      map['backfill_state'] = Variable<String>(backfillState.value);
    }
    if (lastBackfillAt.present) {
      map['last_backfill_at'] = Variable<DateTime>(lastBackfillAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryProjectionMetasCompanion(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('backfillState: $backfillState, ')
          ..write('lastBackfillAt: $lastBackfillAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LibraryAlbumProjectionsTable extends LibraryAlbumProjections
    with TableInfo<$LibraryAlbumProjectionsTable, LibraryAlbumProjection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryAlbumProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stableIdMeta = const VerificationMeta(
    'stableId',
  );
  @override
  late final GeneratedColumn<String> stableId = GeneratedColumn<String>(
    'stable_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleSortMeta = const VerificationMeta(
    'titleSort',
  );
  @override
  late final GeneratedColumn<String> titleSort = GeneratedColumn<String>(
    'title_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistSortMeta = const VerificationMeta(
    'artistSort',
  );
  @override
  late final GeneratedColumn<String> artistSort = GeneratedColumn<String>(
    'artist_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stableId,
    album,
    albumArtist,
    titleSort,
    artistSort,
    year,
    artworkUri,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryAlbumProjection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stable_id')) {
      context.handle(
        _stableIdMeta,
        stableId.isAcceptableOrUnknown(data['stable_id']!, _stableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stableIdMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_albumArtistMeta);
    }
    if (data.containsKey('title_sort')) {
      context.handle(
        _titleSortMeta,
        titleSort.isAcceptableOrUnknown(data['title_sort']!, _titleSortMeta),
      );
    } else if (isInserting) {
      context.missing(_titleSortMeta);
    }
    if (data.containsKey('artist_sort')) {
      context.handle(
        _artistSortMeta,
        artistSort.isAcceptableOrUnknown(data['artist_sort']!, _artistSortMeta),
      );
    } else if (isInserting) {
      context.missing(_artistSortMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
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
  Set<GeneratedColumn> get $primaryKey => {stableId};
  @override
  LibraryAlbumProjection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryAlbumProjection(
      stableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_id'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      )!,
      titleSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_sort'],
      )!,
      artistSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_sort'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryAlbumProjectionsTable createAlias(String alias) {
    return $LibraryAlbumProjectionsTable(attachedDatabase, alias);
  }
}

class LibraryAlbumProjection extends DataClass
    implements Insertable<LibraryAlbumProjection> {
  final String stableId;
  final String album;
  final String albumArtist;
  final String titleSort;
  final String artistSort;
  final int year;
  final String artworkUri;
  final DateTime updatedAt;
  const LibraryAlbumProjection({
    required this.stableId,
    required this.album,
    required this.albumArtist,
    required this.titleSort,
    required this.artistSort,
    required this.year,
    required this.artworkUri,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stable_id'] = Variable<String>(stableId);
    map['album'] = Variable<String>(album);
    map['album_artist'] = Variable<String>(albumArtist);
    map['title_sort'] = Variable<String>(titleSort);
    map['artist_sort'] = Variable<String>(artistSort);
    map['year'] = Variable<int>(year);
    map['artwork_uri'] = Variable<String>(artworkUri);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryAlbumProjectionsCompanion toCompanion(bool nullToAbsent) {
    return LibraryAlbumProjectionsCompanion(
      stableId: Value(stableId),
      album: Value(album),
      albumArtist: Value(albumArtist),
      titleSort: Value(titleSort),
      artistSort: Value(artistSort),
      year: Value(year),
      artworkUri: Value(artworkUri),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryAlbumProjection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryAlbumProjection(
      stableId: serializer.fromJson<String>(json['stableId']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String>(json['albumArtist']),
      titleSort: serializer.fromJson<String>(json['titleSort']),
      artistSort: serializer.fromJson<String>(json['artistSort']),
      year: serializer.fromJson<int>(json['year']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stableId': serializer.toJson<String>(stableId),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String>(albumArtist),
      'titleSort': serializer.toJson<String>(titleSort),
      'artistSort': serializer.toJson<String>(artistSort),
      'year': serializer.toJson<int>(year),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryAlbumProjection copyWith({
    String? stableId,
    String? album,
    String? albumArtist,
    String? titleSort,
    String? artistSort,
    int? year,
    String? artworkUri,
    DateTime? updatedAt,
  }) => LibraryAlbumProjection(
    stableId: stableId ?? this.stableId,
    album: album ?? this.album,
    albumArtist: albumArtist ?? this.albumArtist,
    titleSort: titleSort ?? this.titleSort,
    artistSort: artistSort ?? this.artistSort,
    year: year ?? this.year,
    artworkUri: artworkUri ?? this.artworkUri,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryAlbumProjection copyWithCompanion(
    LibraryAlbumProjectionsCompanion data,
  ) {
    return LibraryAlbumProjection(
      stableId: data.stableId.present ? data.stableId.value : this.stableId,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      titleSort: data.titleSort.present ? data.titleSort.value : this.titleSort,
      artistSort: data.artistSort.present
          ? data.artistSort.value
          : this.artistSort,
      year: data.year.present ? data.year.value : this.year,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryAlbumProjection(')
          ..write('stableId: $stableId, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('titleSort: $titleSort, ')
          ..write('artistSort: $artistSort, ')
          ..write('year: $year, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stableId,
    album,
    albumArtist,
    titleSort,
    artistSort,
    year,
    artworkUri,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryAlbumProjection &&
          other.stableId == this.stableId &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.titleSort == this.titleSort &&
          other.artistSort == this.artistSort &&
          other.year == this.year &&
          other.artworkUri == this.artworkUri &&
          other.updatedAt == this.updatedAt);
}

class LibraryAlbumProjectionsCompanion
    extends UpdateCompanion<LibraryAlbumProjection> {
  final Value<String> stableId;
  final Value<String> album;
  final Value<String> albumArtist;
  final Value<String> titleSort;
  final Value<String> artistSort;
  final Value<int> year;
  final Value<String> artworkUri;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LibraryAlbumProjectionsCompanion({
    this.stableId = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.titleSort = const Value.absent(),
    this.artistSort = const Value.absent(),
    this.year = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryAlbumProjectionsCompanion.insert({
    required String stableId,
    required String album,
    required String albumArtist,
    required String titleSort,
    required String artistSort,
    this.year = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stableId = Value(stableId),
       album = Value(album),
       albumArtist = Value(albumArtist),
       titleSort = Value(titleSort),
       artistSort = Value(artistSort);
  static Insertable<LibraryAlbumProjection> custom({
    Expression<String>? stableId,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<String>? titleSort,
    Expression<String>? artistSort,
    Expression<int>? year,
    Expression<String>? artworkUri,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stableId != null) 'stable_id': stableId,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (titleSort != null) 'title_sort': titleSort,
      if (artistSort != null) 'artist_sort': artistSort,
      if (year != null) 'year': year,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryAlbumProjectionsCompanion copyWith({
    Value<String>? stableId,
    Value<String>? album,
    Value<String>? albumArtist,
    Value<String>? titleSort,
    Value<String>? artistSort,
    Value<int>? year,
    Value<String>? artworkUri,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryAlbumProjectionsCompanion(
      stableId: stableId ?? this.stableId,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      titleSort: titleSort ?? this.titleSort,
      artistSort: artistSort ?? this.artistSort,
      year: year ?? this.year,
      artworkUri: artworkUri ?? this.artworkUri,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stableId.present) {
      map['stable_id'] = Variable<String>(stableId.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (titleSort.present) {
      map['title_sort'] = Variable<String>(titleSort.value);
    }
    if (artistSort.present) {
      map['artist_sort'] = Variable<String>(artistSort.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
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
    return (StringBuffer('LibraryAlbumProjectionsCompanion(')
          ..write('stableId: $stableId, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('titleSort: $titleSort, ')
          ..write('artistSort: $artistSort, ')
          ..write('year: $year, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryArtistProjectionsTable extends LibraryArtistProjections
    with TableInfo<$LibraryArtistProjectionsTable, LibraryArtistProjection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryArtistProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stableIdMeta = const VerificationMeta(
    'stableId',
  );
  @override
  late final GeneratedColumn<String> stableId = GeneratedColumn<String>(
    'stable_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSortMeta = const VerificationMeta(
    'nameSort',
  );
  @override
  late final GeneratedColumn<String> nameSort = GeneratedColumn<String>(
    'name_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stableId,
    name,
    nameSort,
    songCount,
    artworkUri,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryArtistProjection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stable_id')) {
      context.handle(
        _stableIdMeta,
        stableId.isAcceptableOrUnknown(data['stable_id']!, _stableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stableIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_sort')) {
      context.handle(
        _nameSortMeta,
        nameSort.isAcceptableOrUnknown(data['name_sort']!, _nameSortMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSortMeta);
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
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
  Set<GeneratedColumn> get $primaryKey => {stableId};
  @override
  LibraryArtistProjection map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryArtistProjection(
      stableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_sort'],
      )!,
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryArtistProjectionsTable createAlias(String alias) {
    return $LibraryArtistProjectionsTable(attachedDatabase, alias);
  }
}

class LibraryArtistProjection extends DataClass
    implements Insertable<LibraryArtistProjection> {
  final String stableId;
  final String name;
  final String nameSort;
  final int songCount;
  final String artworkUri;
  final DateTime updatedAt;
  const LibraryArtistProjection({
    required this.stableId,
    required this.name,
    required this.nameSort,
    required this.songCount,
    required this.artworkUri,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stable_id'] = Variable<String>(stableId);
    map['name'] = Variable<String>(name);
    map['name_sort'] = Variable<String>(nameSort);
    map['song_count'] = Variable<int>(songCount);
    map['artwork_uri'] = Variable<String>(artworkUri);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryArtistProjectionsCompanion toCompanion(bool nullToAbsent) {
    return LibraryArtistProjectionsCompanion(
      stableId: Value(stableId),
      name: Value(name),
      nameSort: Value(nameSort),
      songCount: Value(songCount),
      artworkUri: Value(artworkUri),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryArtistProjection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryArtistProjection(
      stableId: serializer.fromJson<String>(json['stableId']),
      name: serializer.fromJson<String>(json['name']),
      nameSort: serializer.fromJson<String>(json['nameSort']),
      songCount: serializer.fromJson<int>(json['songCount']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stableId': serializer.toJson<String>(stableId),
      'name': serializer.toJson<String>(name),
      'nameSort': serializer.toJson<String>(nameSort),
      'songCount': serializer.toJson<int>(songCount),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryArtistProjection copyWith({
    String? stableId,
    String? name,
    String? nameSort,
    int? songCount,
    String? artworkUri,
    DateTime? updatedAt,
  }) => LibraryArtistProjection(
    stableId: stableId ?? this.stableId,
    name: name ?? this.name,
    nameSort: nameSort ?? this.nameSort,
    songCount: songCount ?? this.songCount,
    artworkUri: artworkUri ?? this.artworkUri,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryArtistProjection copyWithCompanion(
    LibraryArtistProjectionsCompanion data,
  ) {
    return LibraryArtistProjection(
      stableId: data.stableId.present ? data.stableId.value : this.stableId,
      name: data.name.present ? data.name.value : this.name,
      nameSort: data.nameSort.present ? data.nameSort.value : this.nameSort,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryArtistProjection(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('songCount: $songCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stableId, name, nameSort, songCount, artworkUri, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryArtistProjection &&
          other.stableId == this.stableId &&
          other.name == this.name &&
          other.nameSort == this.nameSort &&
          other.songCount == this.songCount &&
          other.artworkUri == this.artworkUri &&
          other.updatedAt == this.updatedAt);
}

class LibraryArtistProjectionsCompanion
    extends UpdateCompanion<LibraryArtistProjection> {
  final Value<String> stableId;
  final Value<String> name;
  final Value<String> nameSort;
  final Value<int> songCount;
  final Value<String> artworkUri;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LibraryArtistProjectionsCompanion({
    this.stableId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameSort = const Value.absent(),
    this.songCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryArtistProjectionsCompanion.insert({
    required String stableId,
    required String name,
    required String nameSort,
    this.songCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stableId = Value(stableId),
       name = Value(name),
       nameSort = Value(nameSort);
  static Insertable<LibraryArtistProjection> custom({
    Expression<String>? stableId,
    Expression<String>? name,
    Expression<String>? nameSort,
    Expression<int>? songCount,
    Expression<String>? artworkUri,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stableId != null) 'stable_id': stableId,
      if (name != null) 'name': name,
      if (nameSort != null) 'name_sort': nameSort,
      if (songCount != null) 'song_count': songCount,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryArtistProjectionsCompanion copyWith({
    Value<String>? stableId,
    Value<String>? name,
    Value<String>? nameSort,
    Value<int>? songCount,
    Value<String>? artworkUri,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryArtistProjectionsCompanion(
      stableId: stableId ?? this.stableId,
      name: name ?? this.name,
      nameSort: nameSort ?? this.nameSort,
      songCount: songCount ?? this.songCount,
      artworkUri: artworkUri ?? this.artworkUri,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stableId.present) {
      map['stable_id'] = Variable<String>(stableId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameSort.present) {
      map['name_sort'] = Variable<String>(nameSort.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
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
    return (StringBuffer('LibraryArtistProjectionsCompanion(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('songCount: $songCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryAlbumArtistProjectionsTable extends LibraryAlbumArtistProjections
    with
        TableInfo<
          $LibraryAlbumArtistProjectionsTable,
          LibraryAlbumArtistProjection
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryAlbumArtistProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stableIdMeta = const VerificationMeta(
    'stableId',
  );
  @override
  late final GeneratedColumn<String> stableId = GeneratedColumn<String>(
    'stable_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSortMeta = const VerificationMeta(
    'nameSort',
  );
  @override
  late final GeneratedColumn<String> nameSort = GeneratedColumn<String>(
    'name_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stableId,
    name,
    nameSort,
    albumCount,
    artworkUri,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_album_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryAlbumArtistProjection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stable_id')) {
      context.handle(
        _stableIdMeta,
        stableId.isAcceptableOrUnknown(data['stable_id']!, _stableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stableIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_sort')) {
      context.handle(
        _nameSortMeta,
        nameSort.isAcceptableOrUnknown(data['name_sort']!, _nameSortMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSortMeta);
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
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
  Set<GeneratedColumn> get $primaryKey => {stableId};
  @override
  LibraryAlbumArtistProjection map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryAlbumArtistProjection(
      stableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_sort'],
      )!,
      albumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_count'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryAlbumArtistProjectionsTable createAlias(String alias) {
    return $LibraryAlbumArtistProjectionsTable(attachedDatabase, alias);
  }
}

class LibraryAlbumArtistProjection extends DataClass
    implements Insertable<LibraryAlbumArtistProjection> {
  final String stableId;
  final String name;
  final String nameSort;
  final int albumCount;
  final String artworkUri;
  final DateTime updatedAt;
  const LibraryAlbumArtistProjection({
    required this.stableId,
    required this.name,
    required this.nameSort,
    required this.albumCount,
    required this.artworkUri,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stable_id'] = Variable<String>(stableId);
    map['name'] = Variable<String>(name);
    map['name_sort'] = Variable<String>(nameSort);
    map['album_count'] = Variable<int>(albumCount);
    map['artwork_uri'] = Variable<String>(artworkUri);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryAlbumArtistProjectionsCompanion toCompanion(bool nullToAbsent) {
    return LibraryAlbumArtistProjectionsCompanion(
      stableId: Value(stableId),
      name: Value(name),
      nameSort: Value(nameSort),
      albumCount: Value(albumCount),
      artworkUri: Value(artworkUri),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryAlbumArtistProjection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryAlbumArtistProjection(
      stableId: serializer.fromJson<String>(json['stableId']),
      name: serializer.fromJson<String>(json['name']),
      nameSort: serializer.fromJson<String>(json['nameSort']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stableId': serializer.toJson<String>(stableId),
      'name': serializer.toJson<String>(name),
      'nameSort': serializer.toJson<String>(nameSort),
      'albumCount': serializer.toJson<int>(albumCount),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryAlbumArtistProjection copyWith({
    String? stableId,
    String? name,
    String? nameSort,
    int? albumCount,
    String? artworkUri,
    DateTime? updatedAt,
  }) => LibraryAlbumArtistProjection(
    stableId: stableId ?? this.stableId,
    name: name ?? this.name,
    nameSort: nameSort ?? this.nameSort,
    albumCount: albumCount ?? this.albumCount,
    artworkUri: artworkUri ?? this.artworkUri,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryAlbumArtistProjection copyWithCompanion(
    LibraryAlbumArtistProjectionsCompanion data,
  ) {
    return LibraryAlbumArtistProjection(
      stableId: data.stableId.present ? data.stableId.value : this.stableId,
      name: data.name.present ? data.name.value : this.name,
      nameSort: data.nameSort.present ? data.nameSort.value : this.nameSort,
      albumCount: data.albumCount.present
          ? data.albumCount.value
          : this.albumCount,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryAlbumArtistProjection(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('albumCount: $albumCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stableId, name, nameSort, albumCount, artworkUri, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryAlbumArtistProjection &&
          other.stableId == this.stableId &&
          other.name == this.name &&
          other.nameSort == this.nameSort &&
          other.albumCount == this.albumCount &&
          other.artworkUri == this.artworkUri &&
          other.updatedAt == this.updatedAt);
}

class LibraryAlbumArtistProjectionsCompanion
    extends UpdateCompanion<LibraryAlbumArtistProjection> {
  final Value<String> stableId;
  final Value<String> name;
  final Value<String> nameSort;
  final Value<int> albumCount;
  final Value<String> artworkUri;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LibraryAlbumArtistProjectionsCompanion({
    this.stableId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameSort = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryAlbumArtistProjectionsCompanion.insert({
    required String stableId,
    required String name,
    required String nameSort,
    this.albumCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stableId = Value(stableId),
       name = Value(name),
       nameSort = Value(nameSort);
  static Insertable<LibraryAlbumArtistProjection> custom({
    Expression<String>? stableId,
    Expression<String>? name,
    Expression<String>? nameSort,
    Expression<int>? albumCount,
    Expression<String>? artworkUri,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stableId != null) 'stable_id': stableId,
      if (name != null) 'name': name,
      if (nameSort != null) 'name_sort': nameSort,
      if (albumCount != null) 'album_count': albumCount,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryAlbumArtistProjectionsCompanion copyWith({
    Value<String>? stableId,
    Value<String>? name,
    Value<String>? nameSort,
    Value<int>? albumCount,
    Value<String>? artworkUri,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryAlbumArtistProjectionsCompanion(
      stableId: stableId ?? this.stableId,
      name: name ?? this.name,
      nameSort: nameSort ?? this.nameSort,
      albumCount: albumCount ?? this.albumCount,
      artworkUri: artworkUri ?? this.artworkUri,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stableId.present) {
      map['stable_id'] = Variable<String>(stableId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameSort.present) {
      map['name_sort'] = Variable<String>(nameSort.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
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
    return (StringBuffer('LibraryAlbumArtistProjectionsCompanion(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('albumCount: $albumCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryGenreProjectionsTable extends LibraryGenreProjections
    with TableInfo<$LibraryGenreProjectionsTable, LibraryGenreProjection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryGenreProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stableIdMeta = const VerificationMeta(
    'stableId',
  );
  @override
  late final GeneratedColumn<String> stableId = GeneratedColumn<String>(
    'stable_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSortMeta = const VerificationMeta(
    'nameSort',
  );
  @override
  late final GeneratedColumn<String> nameSort = GeneratedColumn<String>(
    'name_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stableId,
    name,
    nameSort,
    songCount,
    artworkUri,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryGenreProjection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stable_id')) {
      context.handle(
        _stableIdMeta,
        stableId.isAcceptableOrUnknown(data['stable_id']!, _stableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stableIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_sort')) {
      context.handle(
        _nameSortMeta,
        nameSort.isAcceptableOrUnknown(data['name_sort']!, _nameSortMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSortMeta);
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
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
  Set<GeneratedColumn> get $primaryKey => {stableId};
  @override
  LibraryGenreProjection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryGenreProjection(
      stableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_sort'],
      )!,
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryGenreProjectionsTable createAlias(String alias) {
    return $LibraryGenreProjectionsTable(attachedDatabase, alias);
  }
}

class LibraryGenreProjection extends DataClass
    implements Insertable<LibraryGenreProjection> {
  final String stableId;
  final String name;
  final String nameSort;
  final int songCount;
  final String artworkUri;
  final DateTime updatedAt;
  const LibraryGenreProjection({
    required this.stableId,
    required this.name,
    required this.nameSort,
    required this.songCount,
    required this.artworkUri,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stable_id'] = Variable<String>(stableId);
    map['name'] = Variable<String>(name);
    map['name_sort'] = Variable<String>(nameSort);
    map['song_count'] = Variable<int>(songCount);
    map['artwork_uri'] = Variable<String>(artworkUri);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryGenreProjectionsCompanion toCompanion(bool nullToAbsent) {
    return LibraryGenreProjectionsCompanion(
      stableId: Value(stableId),
      name: Value(name),
      nameSort: Value(nameSort),
      songCount: Value(songCount),
      artworkUri: Value(artworkUri),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryGenreProjection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryGenreProjection(
      stableId: serializer.fromJson<String>(json['stableId']),
      name: serializer.fromJson<String>(json['name']),
      nameSort: serializer.fromJson<String>(json['nameSort']),
      songCount: serializer.fromJson<int>(json['songCount']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stableId': serializer.toJson<String>(stableId),
      'name': serializer.toJson<String>(name),
      'nameSort': serializer.toJson<String>(nameSort),
      'songCount': serializer.toJson<int>(songCount),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryGenreProjection copyWith({
    String? stableId,
    String? name,
    String? nameSort,
    int? songCount,
    String? artworkUri,
    DateTime? updatedAt,
  }) => LibraryGenreProjection(
    stableId: stableId ?? this.stableId,
    name: name ?? this.name,
    nameSort: nameSort ?? this.nameSort,
    songCount: songCount ?? this.songCount,
    artworkUri: artworkUri ?? this.artworkUri,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryGenreProjection copyWithCompanion(
    LibraryGenreProjectionsCompanion data,
  ) {
    return LibraryGenreProjection(
      stableId: data.stableId.present ? data.stableId.value : this.stableId,
      name: data.name.present ? data.name.value : this.name,
      nameSort: data.nameSort.present ? data.nameSort.value : this.nameSort,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryGenreProjection(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('songCount: $songCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stableId, name, nameSort, songCount, artworkUri, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryGenreProjection &&
          other.stableId == this.stableId &&
          other.name == this.name &&
          other.nameSort == this.nameSort &&
          other.songCount == this.songCount &&
          other.artworkUri == this.artworkUri &&
          other.updatedAt == this.updatedAt);
}

class LibraryGenreProjectionsCompanion
    extends UpdateCompanion<LibraryGenreProjection> {
  final Value<String> stableId;
  final Value<String> name;
  final Value<String> nameSort;
  final Value<int> songCount;
  final Value<String> artworkUri;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LibraryGenreProjectionsCompanion({
    this.stableId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameSort = const Value.absent(),
    this.songCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryGenreProjectionsCompanion.insert({
    required String stableId,
    required String name,
    required String nameSort,
    this.songCount = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stableId = Value(stableId),
       name = Value(name),
       nameSort = Value(nameSort);
  static Insertable<LibraryGenreProjection> custom({
    Expression<String>? stableId,
    Expression<String>? name,
    Expression<String>? nameSort,
    Expression<int>? songCount,
    Expression<String>? artworkUri,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stableId != null) 'stable_id': stableId,
      if (name != null) 'name': name,
      if (nameSort != null) 'name_sort': nameSort,
      if (songCount != null) 'song_count': songCount,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryGenreProjectionsCompanion copyWith({
    Value<String>? stableId,
    Value<String>? name,
    Value<String>? nameSort,
    Value<int>? songCount,
    Value<String>? artworkUri,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryGenreProjectionsCompanion(
      stableId: stableId ?? this.stableId,
      name: name ?? this.name,
      nameSort: nameSort ?? this.nameSort,
      songCount: songCount ?? this.songCount,
      artworkUri: artworkUri ?? this.artworkUri,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stableId.present) {
      map['stable_id'] = Variable<String>(stableId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameSort.present) {
      map['name_sort'] = Variable<String>(nameSort.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
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
    return (StringBuffer('LibraryGenreProjectionsCompanion(')
          ..write('stableId: $stableId, ')
          ..write('name: $name, ')
          ..write('nameSort: $nameSort, ')
          ..write('songCount: $songCount, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DriveObjectsTable extends DriveObjects
    with TableInfo<$DriveObjectsTable, DriveObject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriveObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _driveIdMeta = const VerificationMeta(
    'driveId',
  );
  @override
  late final GeneratedColumn<String> driveId = GeneratedColumn<String>(
    'drive_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentDriveIdMeta = const VerificationMeta(
    'parentDriveId',
  );
  @override
  late final GeneratedColumn<String> parentDriveId = GeneratedColumn<String>(
    'parent_drive_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectKindMeta = const VerificationMeta(
    'objectKind',
  );
  @override
  late final GeneratedColumn<String> objectKind = GeneratedColumn<String>(
    'object_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceKeyMeta = const VerificationMeta(
    'resourceKey',
  );
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
    'resource_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _md5ChecksumMeta = const VerificationMeta(
    'md5Checksum',
  );
  @override
  late final GeneratedColumn<String> md5Checksum = GeneratedColumn<String>(
    'md5_checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedTimeMeta = const VerificationMeta(
    'modifiedTime',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedTime = GeneratedColumn<DateTime>(
    'modified_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootIdsJsonMeta = const VerificationMeta(
    'rootIdsJson',
  );
  @override
  late final GeneratedColumn<String> rootIdsJson = GeneratedColumn<String>(
    'root_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isTombstonedMeta = const VerificationMeta(
    'isTombstoned',
  );
  @override
  late final GeneratedColumn<bool> isTombstoned = GeneratedColumn<bool>(
    'is_tombstoned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tombstoned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSeenJobIdMeta = const VerificationMeta(
    'lastSeenJobId',
  );
  @override
  late final GeneratedColumn<int> lastSeenJobId = GeneratedColumn<int>(
    'last_seen_job_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    driveId,
    parentDriveId,
    name,
    mimeType,
    objectKind,
    resourceKey,
    sizeBytes,
    md5Checksum,
    modifiedTime,
    rootIdsJson,
    isTombstoned,
    lastSeenJobId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drive_objects';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriveObject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('drive_id')) {
      context.handle(
        _driveIdMeta,
        driveId.isAcceptableOrUnknown(data['drive_id']!, _driveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driveIdMeta);
    }
    if (data.containsKey('parent_drive_id')) {
      context.handle(
        _parentDriveIdMeta,
        parentDriveId.isAcceptableOrUnknown(
          data['parent_drive_id']!,
          _parentDriveIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('object_kind')) {
      context.handle(
        _objectKindMeta,
        objectKind.isAcceptableOrUnknown(data['object_kind']!, _objectKindMeta),
      );
    } else if (isInserting) {
      context.missing(_objectKindMeta);
    }
    if (data.containsKey('resource_key')) {
      context.handle(
        _resourceKeyMeta,
        resourceKey.isAcceptableOrUnknown(
          data['resource_key']!,
          _resourceKeyMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('md5_checksum')) {
      context.handle(
        _md5ChecksumMeta,
        md5Checksum.isAcceptableOrUnknown(
          data['md5_checksum']!,
          _md5ChecksumMeta,
        ),
      );
    }
    if (data.containsKey('modified_time')) {
      context.handle(
        _modifiedTimeMeta,
        modifiedTime.isAcceptableOrUnknown(
          data['modified_time']!,
          _modifiedTimeMeta,
        ),
      );
    }
    if (data.containsKey('root_ids_json')) {
      context.handle(
        _rootIdsJsonMeta,
        rootIdsJson.isAcceptableOrUnknown(
          data['root_ids_json']!,
          _rootIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_tombstoned')) {
      context.handle(
        _isTombstonedMeta,
        isTombstoned.isAcceptableOrUnknown(
          data['is_tombstoned']!,
          _isTombstonedMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_job_id')) {
      context.handle(
        _lastSeenJobIdMeta,
        lastSeenJobId.isAcceptableOrUnknown(
          data['last_seen_job_id']!,
          _lastSeenJobIdMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {driveId};
  @override
  DriveObject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriveObject(
      driveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_id'],
      )!,
      parentDriveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_drive_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      objectKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_kind'],
      )!,
      resourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_key'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      md5Checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}md5_checksum'],
      ),
      modifiedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_time'],
      ),
      rootIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_ids_json'],
      )!,
      isTombstoned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tombstoned'],
      )!,
      lastSeenJobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_job_id'],
      ),
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
  $DriveObjectsTable createAlias(String alias) {
    return $DriveObjectsTable(attachedDatabase, alias);
  }
}

class DriveObject extends DataClass implements Insertable<DriveObject> {
  final String driveId;
  final String? parentDriveId;
  final String name;
  final String mimeType;
  final String objectKind;
  final String? resourceKey;
  final int? sizeBytes;
  final String? md5Checksum;
  final DateTime? modifiedTime;
  final String rootIdsJson;
  final bool isTombstoned;
  final int? lastSeenJobId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriveObject({
    required this.driveId,
    this.parentDriveId,
    required this.name,
    required this.mimeType,
    required this.objectKind,
    this.resourceKey,
    this.sizeBytes,
    this.md5Checksum,
    this.modifiedTime,
    required this.rootIdsJson,
    required this.isTombstoned,
    this.lastSeenJobId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['drive_id'] = Variable<String>(driveId);
    if (!nullToAbsent || parentDriveId != null) {
      map['parent_drive_id'] = Variable<String>(parentDriveId);
    }
    map['name'] = Variable<String>(name);
    map['mime_type'] = Variable<String>(mimeType);
    map['object_kind'] = Variable<String>(objectKind);
    if (!nullToAbsent || resourceKey != null) {
      map['resource_key'] = Variable<String>(resourceKey);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || md5Checksum != null) {
      map['md5_checksum'] = Variable<String>(md5Checksum);
    }
    if (!nullToAbsent || modifiedTime != null) {
      map['modified_time'] = Variable<DateTime>(modifiedTime);
    }
    map['root_ids_json'] = Variable<String>(rootIdsJson);
    map['is_tombstoned'] = Variable<bool>(isTombstoned);
    if (!nullToAbsent || lastSeenJobId != null) {
      map['last_seen_job_id'] = Variable<int>(lastSeenJobId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DriveObjectsCompanion toCompanion(bool nullToAbsent) {
    return DriveObjectsCompanion(
      driveId: Value(driveId),
      parentDriveId: parentDriveId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentDriveId),
      name: Value(name),
      mimeType: Value(mimeType),
      objectKind: Value(objectKind),
      resourceKey: resourceKey == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceKey),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      md5Checksum: md5Checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(md5Checksum),
      modifiedTime: modifiedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedTime),
      rootIdsJson: Value(rootIdsJson),
      isTombstoned: Value(isTombstoned),
      lastSeenJobId: lastSeenJobId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenJobId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriveObject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriveObject(
      driveId: serializer.fromJson<String>(json['driveId']),
      parentDriveId: serializer.fromJson<String?>(json['parentDriveId']),
      name: serializer.fromJson<String>(json['name']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      objectKind: serializer.fromJson<String>(json['objectKind']),
      resourceKey: serializer.fromJson<String?>(json['resourceKey']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      md5Checksum: serializer.fromJson<String?>(json['md5Checksum']),
      modifiedTime: serializer.fromJson<DateTime?>(json['modifiedTime']),
      rootIdsJson: serializer.fromJson<String>(json['rootIdsJson']),
      isTombstoned: serializer.fromJson<bool>(json['isTombstoned']),
      lastSeenJobId: serializer.fromJson<int?>(json['lastSeenJobId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'driveId': serializer.toJson<String>(driveId),
      'parentDriveId': serializer.toJson<String?>(parentDriveId),
      'name': serializer.toJson<String>(name),
      'mimeType': serializer.toJson<String>(mimeType),
      'objectKind': serializer.toJson<String>(objectKind),
      'resourceKey': serializer.toJson<String?>(resourceKey),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'md5Checksum': serializer.toJson<String?>(md5Checksum),
      'modifiedTime': serializer.toJson<DateTime?>(modifiedTime),
      'rootIdsJson': serializer.toJson<String>(rootIdsJson),
      'isTombstoned': serializer.toJson<bool>(isTombstoned),
      'lastSeenJobId': serializer.toJson<int?>(lastSeenJobId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriveObject copyWith({
    String? driveId,
    Value<String?> parentDriveId = const Value.absent(),
    String? name,
    String? mimeType,
    String? objectKind,
    Value<String?> resourceKey = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> md5Checksum = const Value.absent(),
    Value<DateTime?> modifiedTime = const Value.absent(),
    String? rootIdsJson,
    bool? isTombstoned,
    Value<int?> lastSeenJobId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriveObject(
    driveId: driveId ?? this.driveId,
    parentDriveId: parentDriveId.present
        ? parentDriveId.value
        : this.parentDriveId,
    name: name ?? this.name,
    mimeType: mimeType ?? this.mimeType,
    objectKind: objectKind ?? this.objectKind,
    resourceKey: resourceKey.present ? resourceKey.value : this.resourceKey,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    md5Checksum: md5Checksum.present ? md5Checksum.value : this.md5Checksum,
    modifiedTime: modifiedTime.present ? modifiedTime.value : this.modifiedTime,
    rootIdsJson: rootIdsJson ?? this.rootIdsJson,
    isTombstoned: isTombstoned ?? this.isTombstoned,
    lastSeenJobId: lastSeenJobId.present
        ? lastSeenJobId.value
        : this.lastSeenJobId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriveObject copyWithCompanion(DriveObjectsCompanion data) {
    return DriveObject(
      driveId: data.driveId.present ? data.driveId.value : this.driveId,
      parentDriveId: data.parentDriveId.present
          ? data.parentDriveId.value
          : this.parentDriveId,
      name: data.name.present ? data.name.value : this.name,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      objectKind: data.objectKind.present
          ? data.objectKind.value
          : this.objectKind,
      resourceKey: data.resourceKey.present
          ? data.resourceKey.value
          : this.resourceKey,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      md5Checksum: data.md5Checksum.present
          ? data.md5Checksum.value
          : this.md5Checksum,
      modifiedTime: data.modifiedTime.present
          ? data.modifiedTime.value
          : this.modifiedTime,
      rootIdsJson: data.rootIdsJson.present
          ? data.rootIdsJson.value
          : this.rootIdsJson,
      isTombstoned: data.isTombstoned.present
          ? data.isTombstoned.value
          : this.isTombstoned,
      lastSeenJobId: data.lastSeenJobId.present
          ? data.lastSeenJobId.value
          : this.lastSeenJobId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriveObject(')
          ..write('driveId: $driveId, ')
          ..write('parentDriveId: $parentDriveId, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('objectKind: $objectKind, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('md5Checksum: $md5Checksum, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('rootIdsJson: $rootIdsJson, ')
          ..write('isTombstoned: $isTombstoned, ')
          ..write('lastSeenJobId: $lastSeenJobId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    driveId,
    parentDriveId,
    name,
    mimeType,
    objectKind,
    resourceKey,
    sizeBytes,
    md5Checksum,
    modifiedTime,
    rootIdsJson,
    isTombstoned,
    lastSeenJobId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriveObject &&
          other.driveId == this.driveId &&
          other.parentDriveId == this.parentDriveId &&
          other.name == this.name &&
          other.mimeType == this.mimeType &&
          other.objectKind == this.objectKind &&
          other.resourceKey == this.resourceKey &&
          other.sizeBytes == this.sizeBytes &&
          other.md5Checksum == this.md5Checksum &&
          other.modifiedTime == this.modifiedTime &&
          other.rootIdsJson == this.rootIdsJson &&
          other.isTombstoned == this.isTombstoned &&
          other.lastSeenJobId == this.lastSeenJobId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DriveObjectsCompanion extends UpdateCompanion<DriveObject> {
  final Value<String> driveId;
  final Value<String?> parentDriveId;
  final Value<String> name;
  final Value<String> mimeType;
  final Value<String> objectKind;
  final Value<String?> resourceKey;
  final Value<int?> sizeBytes;
  final Value<String?> md5Checksum;
  final Value<DateTime?> modifiedTime;
  final Value<String> rootIdsJson;
  final Value<bool> isTombstoned;
  final Value<int?> lastSeenJobId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DriveObjectsCompanion({
    this.driveId = const Value.absent(),
    this.parentDriveId = const Value.absent(),
    this.name = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.objectKind = const Value.absent(),
    this.resourceKey = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.md5Checksum = const Value.absent(),
    this.modifiedTime = const Value.absent(),
    this.rootIdsJson = const Value.absent(),
    this.isTombstoned = const Value.absent(),
    this.lastSeenJobId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DriveObjectsCompanion.insert({
    required String driveId,
    this.parentDriveId = const Value.absent(),
    required String name,
    required String mimeType,
    required String objectKind,
    this.resourceKey = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.md5Checksum = const Value.absent(),
    this.modifiedTime = const Value.absent(),
    this.rootIdsJson = const Value.absent(),
    this.isTombstoned = const Value.absent(),
    this.lastSeenJobId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : driveId = Value(driveId),
       name = Value(name),
       mimeType = Value(mimeType),
       objectKind = Value(objectKind);
  static Insertable<DriveObject> custom({
    Expression<String>? driveId,
    Expression<String>? parentDriveId,
    Expression<String>? name,
    Expression<String>? mimeType,
    Expression<String>? objectKind,
    Expression<String>? resourceKey,
    Expression<int>? sizeBytes,
    Expression<String>? md5Checksum,
    Expression<DateTime>? modifiedTime,
    Expression<String>? rootIdsJson,
    Expression<bool>? isTombstoned,
    Expression<int>? lastSeenJobId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (driveId != null) 'drive_id': driveId,
      if (parentDriveId != null) 'parent_drive_id': parentDriveId,
      if (name != null) 'name': name,
      if (mimeType != null) 'mime_type': mimeType,
      if (objectKind != null) 'object_kind': objectKind,
      if (resourceKey != null) 'resource_key': resourceKey,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (md5Checksum != null) 'md5_checksum': md5Checksum,
      if (modifiedTime != null) 'modified_time': modifiedTime,
      if (rootIdsJson != null) 'root_ids_json': rootIdsJson,
      if (isTombstoned != null) 'is_tombstoned': isTombstoned,
      if (lastSeenJobId != null) 'last_seen_job_id': lastSeenJobId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DriveObjectsCompanion copyWith({
    Value<String>? driveId,
    Value<String?>? parentDriveId,
    Value<String>? name,
    Value<String>? mimeType,
    Value<String>? objectKind,
    Value<String?>? resourceKey,
    Value<int?>? sizeBytes,
    Value<String?>? md5Checksum,
    Value<DateTime?>? modifiedTime,
    Value<String>? rootIdsJson,
    Value<bool>? isTombstoned,
    Value<int?>? lastSeenJobId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DriveObjectsCompanion(
      driveId: driveId ?? this.driveId,
      parentDriveId: parentDriveId ?? this.parentDriveId,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      objectKind: objectKind ?? this.objectKind,
      resourceKey: resourceKey ?? this.resourceKey,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      md5Checksum: md5Checksum ?? this.md5Checksum,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      rootIdsJson: rootIdsJson ?? this.rootIdsJson,
      isTombstoned: isTombstoned ?? this.isTombstoned,
      lastSeenJobId: lastSeenJobId ?? this.lastSeenJobId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (driveId.present) {
      map['drive_id'] = Variable<String>(driveId.value);
    }
    if (parentDriveId.present) {
      map['parent_drive_id'] = Variable<String>(parentDriveId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (objectKind.present) {
      map['object_kind'] = Variable<String>(objectKind.value);
    }
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (md5Checksum.present) {
      map['md5_checksum'] = Variable<String>(md5Checksum.value);
    }
    if (modifiedTime.present) {
      map['modified_time'] = Variable<DateTime>(modifiedTime.value);
    }
    if (rootIdsJson.present) {
      map['root_ids_json'] = Variable<String>(rootIdsJson.value);
    }
    if (isTombstoned.present) {
      map['is_tombstoned'] = Variable<bool>(isTombstoned.value);
    }
    if (lastSeenJobId.present) {
      map['last_seen_job_id'] = Variable<int>(lastSeenJobId.value);
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
    return (StringBuffer('DriveObjectsCompanion(')
          ..write('driveId: $driveId, ')
          ..write('parentDriveId: $parentDriveId, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('objectKind: $objectKind, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('md5Checksum: $md5Checksum, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('rootIdsJson: $rootIdsJson, ')
          ..write('isTombstoned: $isTombstoned, ')
          ..write('lastSeenJobId: $lastSeenJobId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanJobsTable extends ScanJobs with TableInfo<$ScanJobsTable, ScanJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_accounts (id)',
    ),
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<int> rootId = GeneratedColumn<int>(
    'root_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkpointTokenMeta = const VerificationMeta(
    'checkpointToken',
  );
  @override
  late final GeneratedColumn<String> checkpointToken = GeneratedColumn<String>(
    'checkpoint_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startPageTokenMeta = const VerificationMeta(
    'startPageToken',
  );
  @override
  late final GeneratedColumn<String> startPageToken = GeneratedColumn<String>(
    'start_page_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedCountMeta = const VerificationMeta(
    'indexedCount',
  );
  @override
  late final GeneratedColumn<int> indexedCount = GeneratedColumn<int>(
    'indexed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metadataReadyCountMeta =
      const VerificationMeta('metadataReadyCount');
  @override
  late final GeneratedColumn<int> metadataReadyCount = GeneratedColumn<int>(
    'metadata_ready_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkReadyCountMeta = const VerificationMeta(
    'artworkReadyCount',
  );
  @override
  late final GeneratedColumn<int> artworkReadyCount = GeneratedColumn<int>(
    'artwork_ready_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    rootId,
    kind,
    state,
    phase,
    checkpointToken,
    startPageToken,
    indexedCount,
    metadataReadyCount,
    artworkReadyCount,
    failedCount,
    lastError,
    createdAt,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('checkpoint_token')) {
      context.handle(
        _checkpointTokenMeta,
        checkpointToken.isAcceptableOrUnknown(
          data['checkpoint_token']!,
          _checkpointTokenMeta,
        ),
      );
    }
    if (data.containsKey('start_page_token')) {
      context.handle(
        _startPageTokenMeta,
        startPageToken.isAcceptableOrUnknown(
          data['start_page_token']!,
          _startPageTokenMeta,
        ),
      );
    }
    if (data.containsKey('indexed_count')) {
      context.handle(
        _indexedCountMeta,
        indexedCount.isAcceptableOrUnknown(
          data['indexed_count']!,
          _indexedCountMeta,
        ),
      );
    }
    if (data.containsKey('metadata_ready_count')) {
      context.handle(
        _metadataReadyCountMeta,
        metadataReadyCount.isAcceptableOrUnknown(
          data['metadata_ready_count']!,
          _metadataReadyCountMeta,
        ),
      );
    }
    if (data.containsKey('artwork_ready_count')) {
      context.handle(
        _artworkReadyCountMeta,
        artworkReadyCount.isAcceptableOrUnknown(
          data['artwork_ready_count']!,
          _artworkReadyCountMeta,
        ),
      );
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      checkpointToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checkpoint_token'],
      ),
      startPageToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_page_token'],
      ),
      indexedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indexed_count'],
      )!,
      metadataReadyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_ready_count'],
      )!,
      artworkReadyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artwork_ready_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $ScanJobsTable createAlias(String alias) {
    return $ScanJobsTable(attachedDatabase, alias);
  }
}

class ScanJob extends DataClass implements Insertable<ScanJob> {
  final int id;
  final int accountId;
  final int? rootId;
  final String kind;
  final String state;
  final String phase;
  final String? checkpointToken;
  final String? startPageToken;
  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  const ScanJob({
    required this.id,
    required this.accountId,
    this.rootId,
    required this.kind,
    required this.state,
    required this.phase,
    this.checkpointToken,
    this.startPageToken,
    required this.indexedCount,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
    this.lastError,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || rootId != null) {
      map['root_id'] = Variable<int>(rootId);
    }
    map['kind'] = Variable<String>(kind);
    map['state'] = Variable<String>(state);
    map['phase'] = Variable<String>(phase);
    if (!nullToAbsent || checkpointToken != null) {
      map['checkpoint_token'] = Variable<String>(checkpointToken);
    }
    if (!nullToAbsent || startPageToken != null) {
      map['start_page_token'] = Variable<String>(startPageToken);
    }
    map['indexed_count'] = Variable<int>(indexedCount);
    map['metadata_ready_count'] = Variable<int>(metadataReadyCount);
    map['artwork_ready_count'] = Variable<int>(artworkReadyCount);
    map['failed_count'] = Variable<int>(failedCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  ScanJobsCompanion toCompanion(bool nullToAbsent) {
    return ScanJobsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      rootId: rootId == null && nullToAbsent
          ? const Value.absent()
          : Value(rootId),
      kind: Value(kind),
      state: Value(state),
      phase: Value(phase),
      checkpointToken: checkpointToken == null && nullToAbsent
          ? const Value.absent()
          : Value(checkpointToken),
      startPageToken: startPageToken == null && nullToAbsent
          ? const Value.absent()
          : Value(startPageToken),
      indexedCount: Value(indexedCount),
      metadataReadyCount: Value(metadataReadyCount),
      artworkReadyCount: Value(artworkReadyCount),
      failedCount: Value(failedCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory ScanJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanJob(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      rootId: serializer.fromJson<int?>(json['rootId']),
      kind: serializer.fromJson<String>(json['kind']),
      state: serializer.fromJson<String>(json['state']),
      phase: serializer.fromJson<String>(json['phase']),
      checkpointToken: serializer.fromJson<String?>(json['checkpointToken']),
      startPageToken: serializer.fromJson<String?>(json['startPageToken']),
      indexedCount: serializer.fromJson<int>(json['indexedCount']),
      metadataReadyCount: serializer.fromJson<int>(json['metadataReadyCount']),
      artworkReadyCount: serializer.fromJson<int>(json['artworkReadyCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'rootId': serializer.toJson<int?>(rootId),
      'kind': serializer.toJson<String>(kind),
      'state': serializer.toJson<String>(state),
      'phase': serializer.toJson<String>(phase),
      'checkpointToken': serializer.toJson<String?>(checkpointToken),
      'startPageToken': serializer.toJson<String?>(startPageToken),
      'indexedCount': serializer.toJson<int>(indexedCount),
      'metadataReadyCount': serializer.toJson<int>(metadataReadyCount),
      'artworkReadyCount': serializer.toJson<int>(artworkReadyCount),
      'failedCount': serializer.toJson<int>(failedCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  ScanJob copyWith({
    int? id,
    int? accountId,
    Value<int?> rootId = const Value.absent(),
    String? kind,
    String? state,
    String? phase,
    Value<String?> checkpointToken = const Value.absent(),
    Value<String?> startPageToken = const Value.absent(),
    int? indexedCount,
    int? metadataReadyCount,
    int? artworkReadyCount,
    int? failedCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => ScanJob(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    rootId: rootId.present ? rootId.value : this.rootId,
    kind: kind ?? this.kind,
    state: state ?? this.state,
    phase: phase ?? this.phase,
    checkpointToken: checkpointToken.present
        ? checkpointToken.value
        : this.checkpointToken,
    startPageToken: startPageToken.present
        ? startPageToken.value
        : this.startPageToken,
    indexedCount: indexedCount ?? this.indexedCount,
    metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
    artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
    failedCount: failedCount ?? this.failedCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  ScanJob copyWithCompanion(ScanJobsCompanion data) {
    return ScanJob(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      kind: data.kind.present ? data.kind.value : this.kind,
      state: data.state.present ? data.state.value : this.state,
      phase: data.phase.present ? data.phase.value : this.phase,
      checkpointToken: data.checkpointToken.present
          ? data.checkpointToken.value
          : this.checkpointToken,
      startPageToken: data.startPageToken.present
          ? data.startPageToken.value
          : this.startPageToken,
      indexedCount: data.indexedCount.present
          ? data.indexedCount.value
          : this.indexedCount,
      metadataReadyCount: data.metadataReadyCount.present
          ? data.metadataReadyCount.value
          : this.metadataReadyCount,
      artworkReadyCount: data.artworkReadyCount.present
          ? data.artworkReadyCount.value
          : this.artworkReadyCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanJob(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('rootId: $rootId, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('phase: $phase, ')
          ..write('checkpointToken: $checkpointToken, ')
          ..write('startPageToken: $startPageToken, ')
          ..write('indexedCount: $indexedCount, ')
          ..write('metadataReadyCount: $metadataReadyCount, ')
          ..write('artworkReadyCount: $artworkReadyCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    rootId,
    kind,
    state,
    phase,
    checkpointToken,
    startPageToken,
    indexedCount,
    metadataReadyCount,
    artworkReadyCount,
    failedCount,
    lastError,
    createdAt,
    startedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanJob &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.rootId == this.rootId &&
          other.kind == this.kind &&
          other.state == this.state &&
          other.phase == this.phase &&
          other.checkpointToken == this.checkpointToken &&
          other.startPageToken == this.startPageToken &&
          other.indexedCount == this.indexedCount &&
          other.metadataReadyCount == this.metadataReadyCount &&
          other.artworkReadyCount == this.artworkReadyCount &&
          other.failedCount == this.failedCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class ScanJobsCompanion extends UpdateCompanion<ScanJob> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int?> rootId;
  final Value<String> kind;
  final Value<String> state;
  final Value<String> phase;
  final Value<String?> checkpointToken;
  final Value<String?> startPageToken;
  final Value<int> indexedCount;
  final Value<int> metadataReadyCount;
  final Value<int> artworkReadyCount;
  final Value<int> failedCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  const ScanJobsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.kind = const Value.absent(),
    this.state = const Value.absent(),
    this.phase = const Value.absent(),
    this.checkpointToken = const Value.absent(),
    this.startPageToken = const Value.absent(),
    this.indexedCount = const Value.absent(),
    this.metadataReadyCount = const Value.absent(),
    this.artworkReadyCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  ScanJobsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    this.rootId = const Value.absent(),
    required String kind,
    required String state,
    required String phase,
    this.checkpointToken = const Value.absent(),
    this.startPageToken = const Value.absent(),
    this.indexedCount = const Value.absent(),
    this.metadataReadyCount = const Value.absent(),
    this.artworkReadyCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  }) : accountId = Value(accountId),
       kind = Value(kind),
       state = Value(state),
       phase = Value(phase);
  static Insertable<ScanJob> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? rootId,
    Expression<String>? kind,
    Expression<String>? state,
    Expression<String>? phase,
    Expression<String>? checkpointToken,
    Expression<String>? startPageToken,
    Expression<int>? indexedCount,
    Expression<int>? metadataReadyCount,
    Expression<int>? artworkReadyCount,
    Expression<int>? failedCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (rootId != null) 'root_id': rootId,
      if (kind != null) 'kind': kind,
      if (state != null) 'state': state,
      if (phase != null) 'phase': phase,
      if (checkpointToken != null) 'checkpoint_token': checkpointToken,
      if (startPageToken != null) 'start_page_token': startPageToken,
      if (indexedCount != null) 'indexed_count': indexedCount,
      if (metadataReadyCount != null)
        'metadata_ready_count': metadataReadyCount,
      if (artworkReadyCount != null) 'artwork_ready_count': artworkReadyCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  ScanJobsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int?>? rootId,
    Value<String>? kind,
    Value<String>? state,
    Value<String>? phase,
    Value<String?>? checkpointToken,
    Value<String?>? startPageToken,
    Value<int>? indexedCount,
    Value<int>? metadataReadyCount,
    Value<int>? artworkReadyCount,
    Value<int>? failedCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
  }) {
    return ScanJobsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      rootId: rootId ?? this.rootId,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      phase: phase ?? this.phase,
      checkpointToken: checkpointToken ?? this.checkpointToken,
      startPageToken: startPageToken ?? this.startPageToken,
      indexedCount: indexedCount ?? this.indexedCount,
      metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
      artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
      failedCount: failedCount ?? this.failedCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<int>(rootId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (checkpointToken.present) {
      map['checkpoint_token'] = Variable<String>(checkpointToken.value);
    }
    if (startPageToken.present) {
      map['start_page_token'] = Variable<String>(startPageToken.value);
    }
    if (indexedCount.present) {
      map['indexed_count'] = Variable<int>(indexedCount.value);
    }
    if (metadataReadyCount.present) {
      map['metadata_ready_count'] = Variable<int>(metadataReadyCount.value);
    }
    if (artworkReadyCount.present) {
      map['artwork_ready_count'] = Variable<int>(artworkReadyCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanJobsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('rootId: $rootId, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('phase: $phase, ')
          ..write('checkpointToken: $checkpointToken, ')
          ..write('startPageToken: $startPageToken, ')
          ..write('indexedCount: $indexedCount, ')
          ..write('metadataReadyCount: $metadataReadyCount, ')
          ..write('artworkReadyCount: $artworkReadyCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $ScanTasksTable extends ScanTasks
    with TableInfo<$ScanTasksTable, ScanTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scan_jobs (id)',
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
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DriveScanTaskState.queued.value),
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<int> rootId = GeneratedColumn<int>(
    'root_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDriveIdMeta = const VerificationMeta(
    'targetDriveId',
  );
  @override
  late final GeneratedColumn<String> targetDriveId = GeneratedColumn<String>(
    'target_drive_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedAtMeta = const VerificationMeta(
    'lockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lockedAt = GeneratedColumn<DateTime>(
    'locked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    kind,
    state,
    rootId,
    targetDriveId,
    dedupeKey,
    payloadJson,
    attempts,
    priority,
    lockedAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    }
    if (data.containsKey('target_drive_id')) {
      context.handle(
        _targetDriveIdMeta,
        targetDriveId.isAcceptableOrUnknown(
          data['target_drive_id']!,
          _targetDriveIdMeta,
        ),
      );
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('locked_at')) {
      context.handle(
        _lockedAtMeta,
        lockedAt.isAcceptableOrUnknown(data['locked_at']!, _lockedAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {jobId, dedupeKey},
  ];
  @override
  ScanTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_id'],
      ),
      targetDriveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_drive_id'],
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      lockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
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
  $ScanTasksTable createAlias(String alias) {
    return $ScanTasksTable(attachedDatabase, alias);
  }
}

class ScanTask extends DataClass implements Insertable<ScanTask> {
  final int id;
  final int jobId;
  final String kind;
  final String state;
  final int? rootId;
  final String? targetDriveId;
  final String? dedupeKey;
  final String payloadJson;
  final int attempts;
  final int priority;
  final DateTime? lockedAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ScanTask({
    required this.id,
    required this.jobId,
    required this.kind,
    required this.state,
    this.rootId,
    this.targetDriveId,
    this.dedupeKey,
    required this.payloadJson,
    required this.attempts,
    required this.priority,
    this.lockedAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['kind'] = Variable<String>(kind);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || rootId != null) {
      map['root_id'] = Variable<int>(rootId);
    }
    if (!nullToAbsent || targetDriveId != null) {
      map['target_drive_id'] = Variable<String>(targetDriveId);
    }
    if (!nullToAbsent || dedupeKey != null) {
      map['dedupe_key'] = Variable<String>(dedupeKey);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || lockedAt != null) {
      map['locked_at'] = Variable<DateTime>(lockedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScanTasksCompanion toCompanion(bool nullToAbsent) {
    return ScanTasksCompanion(
      id: Value(id),
      jobId: Value(jobId),
      kind: Value(kind),
      state: Value(state),
      rootId: rootId == null && nullToAbsent
          ? const Value.absent()
          : Value(rootId),
      targetDriveId: targetDriveId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDriveId),
      dedupeKey: dedupeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dedupeKey),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      priority: Value(priority),
      lockedAt: lockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanTask(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      kind: serializer.fromJson<String>(json['kind']),
      state: serializer.fromJson<String>(json['state']),
      rootId: serializer.fromJson<int?>(json['rootId']),
      targetDriveId: serializer.fromJson<String?>(json['targetDriveId']),
      dedupeKey: serializer.fromJson<String?>(json['dedupeKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      priority: serializer.fromJson<int>(json['priority']),
      lockedAt: serializer.fromJson<DateTime?>(json['lockedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'kind': serializer.toJson<String>(kind),
      'state': serializer.toJson<String>(state),
      'rootId': serializer.toJson<int?>(rootId),
      'targetDriveId': serializer.toJson<String?>(targetDriveId),
      'dedupeKey': serializer.toJson<String?>(dedupeKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'priority': serializer.toJson<int>(priority),
      'lockedAt': serializer.toJson<DateTime?>(lockedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScanTask copyWith({
    int? id,
    int? jobId,
    String? kind,
    String? state,
    Value<int?> rootId = const Value.absent(),
    Value<String?> targetDriveId = const Value.absent(),
    Value<String?> dedupeKey = const Value.absent(),
    String? payloadJson,
    int? attempts,
    int? priority,
    Value<DateTime?> lockedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ScanTask(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    kind: kind ?? this.kind,
    state: state ?? this.state,
    rootId: rootId.present ? rootId.value : this.rootId,
    targetDriveId: targetDriveId.present
        ? targetDriveId.value
        : this.targetDriveId,
    dedupeKey: dedupeKey.present ? dedupeKey.value : this.dedupeKey,
    payloadJson: payloadJson ?? this.payloadJson,
    attempts: attempts ?? this.attempts,
    priority: priority ?? this.priority,
    lockedAt: lockedAt.present ? lockedAt.value : this.lockedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScanTask copyWithCompanion(ScanTasksCompanion data) {
    return ScanTask(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      kind: data.kind.present ? data.kind.value : this.kind,
      state: data.state.present ? data.state.value : this.state,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      targetDriveId: data.targetDriveId.present
          ? data.targetDriveId.value
          : this.targetDriveId,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      priority: data.priority.present ? data.priority.value : this.priority,
      lockedAt: data.lockedAt.present ? data.lockedAt.value : this.lockedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanTask(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('rootId: $rootId, ')
          ..write('targetDriveId: $targetDriveId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('priority: $priority, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    kind,
    state,
    rootId,
    targetDriveId,
    dedupeKey,
    payloadJson,
    attempts,
    priority,
    lockedAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanTask &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.kind == this.kind &&
          other.state == this.state &&
          other.rootId == this.rootId &&
          other.targetDriveId == this.targetDriveId &&
          other.dedupeKey == this.dedupeKey &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.priority == this.priority &&
          other.lockedAt == this.lockedAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScanTasksCompanion extends UpdateCompanion<ScanTask> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<String> kind;
  final Value<String> state;
  final Value<int?> rootId;
  final Value<String?> targetDriveId;
  final Value<String?> dedupeKey;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<int> priority;
  final Value<DateTime?> lockedAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ScanTasksCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.kind = const Value.absent(),
    this.state = const Value.absent(),
    this.rootId = const Value.absent(),
    this.targetDriveId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.priority = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScanTasksCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required String kind,
    this.state = const Value.absent(),
    this.rootId = const Value.absent(),
    this.targetDriveId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.priority = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : jobId = Value(jobId),
       kind = Value(kind);
  static Insertable<ScanTask> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<String>? kind,
    Expression<String>? state,
    Expression<int>? rootId,
    Expression<String>? targetDriveId,
    Expression<String>? dedupeKey,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<int>? priority,
    Expression<DateTime>? lockedAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (kind != null) 'kind': kind,
      if (state != null) 'state': state,
      if (rootId != null) 'root_id': rootId,
      if (targetDriveId != null) 'target_drive_id': targetDriveId,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (priority != null) 'priority': priority,
      if (lockedAt != null) 'locked_at': lockedAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScanTasksCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<String>? kind,
    Value<String>? state,
    Value<int?>? rootId,
    Value<String?>? targetDriveId,
    Value<String?>? dedupeKey,
    Value<String>? payloadJson,
    Value<int>? attempts,
    Value<int>? priority,
    Value<DateTime?>? lockedAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ScanTasksCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      rootId: rootId ?? this.rootId,
      targetDriveId: targetDriveId ?? this.targetDriveId,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      priority: priority ?? this.priority,
      lockedAt: lockedAt ?? this.lockedAt,
      lastError: lastError ?? this.lastError,
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
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<int>(rootId.value);
    }
    if (targetDriveId.present) {
      map['target_drive_id'] = Variable<String>(targetDriveId.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (lockedAt.present) {
      map['locked_at'] = Variable<DateTime>(lockedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
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
    return (StringBuffer('ScanTasksCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('rootId: $rootId, ')
          ..write('targetDriveId: $targetDriveId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('priority: $priority, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ArtworkBlobsTable extends ArtworkBlobs
    with TableInfo<$ArtworkBlobsTable, ArtworkBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworkBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileExtensionMeta = const VerificationMeta(
    'fileExtension',
  );
  @override
  late final GeneratedColumn<String> fileExtension = GeneratedColumn<String>(
    'file_extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    mimeType,
    fileExtension,
    filePath,
    byteSize,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artwork_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworkBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('file_extension')) {
      context.handle(
        _fileExtensionMeta,
        fileExtension.isAcceptableOrUnknown(
          data['file_extension']!,
          _fileExtensionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileExtensionMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {contentHash},
  ];
  @override
  ArtworkBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworkBlob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      fileExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_extension'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ArtworkBlobsTable createAlias(String alias) {
    return $ArtworkBlobsTable(attachedDatabase, alias);
  }
}

class ArtworkBlob extends DataClass implements Insertable<ArtworkBlob> {
  final int id;
  final String contentHash;
  final String mimeType;
  final String fileExtension;
  final String filePath;
  final int byteSize;
  final DateTime createdAt;
  const ArtworkBlob({
    required this.id,
    required this.contentHash,
    required this.mimeType,
    required this.fileExtension,
    required this.filePath,
    required this.byteSize,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['mime_type'] = Variable<String>(mimeType);
    map['file_extension'] = Variable<String>(fileExtension);
    map['file_path'] = Variable<String>(filePath);
    map['byte_size'] = Variable<int>(byteSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ArtworkBlobsCompanion toCompanion(bool nullToAbsent) {
    return ArtworkBlobsCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      mimeType: Value(mimeType),
      fileExtension: Value(fileExtension),
      filePath: Value(filePath),
      byteSize: Value(byteSize),
      createdAt: Value(createdAt),
    );
  }

  factory ArtworkBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworkBlob(
      id: serializer.fromJson<int>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileExtension: serializer.fromJson<String>(json['fileExtension']),
      filePath: serializer.fromJson<String>(json['filePath']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileExtension': serializer.toJson<String>(fileExtension),
      'filePath': serializer.toJson<String>(filePath),
      'byteSize': serializer.toJson<int>(byteSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ArtworkBlob copyWith({
    int? id,
    String? contentHash,
    String? mimeType,
    String? fileExtension,
    String? filePath,
    int? byteSize,
    DateTime? createdAt,
  }) => ArtworkBlob(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    mimeType: mimeType ?? this.mimeType,
    fileExtension: fileExtension ?? this.fileExtension,
    filePath: filePath ?? this.filePath,
    byteSize: byteSize ?? this.byteSize,
    createdAt: createdAt ?? this.createdAt,
  );
  ArtworkBlob copyWithCompanion(ArtworkBlobsCompanion data) {
    return ArtworkBlob(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileExtension: data.fileExtension.present
          ? data.fileExtension.value
          : this.fileExtension,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkBlob(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('filePath: $filePath, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentHash,
    mimeType,
    fileExtension,
    filePath,
    byteSize,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworkBlob &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.mimeType == this.mimeType &&
          other.fileExtension == this.fileExtension &&
          other.filePath == this.filePath &&
          other.byteSize == this.byteSize &&
          other.createdAt == this.createdAt);
}

class ArtworkBlobsCompanion extends UpdateCompanion<ArtworkBlob> {
  final Value<int> id;
  final Value<String> contentHash;
  final Value<String> mimeType;
  final Value<String> fileExtension;
  final Value<String> filePath;
  final Value<int> byteSize;
  final Value<DateTime> createdAt;
  const ArtworkBlobsCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileExtension = const Value.absent(),
    this.filePath = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ArtworkBlobsCompanion.insert({
    this.id = const Value.absent(),
    required String contentHash,
    required String mimeType,
    required String fileExtension,
    required String filePath,
    required int byteSize,
    this.createdAt = const Value.absent(),
  }) : contentHash = Value(contentHash),
       mimeType = Value(mimeType),
       fileExtension = Value(fileExtension),
       filePath = Value(filePath),
       byteSize = Value(byteSize);
  static Insertable<ArtworkBlob> custom({
    Expression<int>? id,
    Expression<String>? contentHash,
    Expression<String>? mimeType,
    Expression<String>? fileExtension,
    Expression<String>? filePath,
    Expression<int>? byteSize,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileExtension != null) 'file_extension': fileExtension,
      if (filePath != null) 'file_path': filePath,
      if (byteSize != null) 'byte_size': byteSize,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ArtworkBlobsCompanion copyWith({
    Value<int>? id,
    Value<String>? contentHash,
    Value<String>? mimeType,
    Value<String>? fileExtension,
    Value<String>? filePath,
    Value<int>? byteSize,
    Value<DateTime>? createdAt,
  }) {
    return ArtworkBlobsCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      mimeType: mimeType ?? this.mimeType,
      fileExtension: fileExtension ?? this.fileExtension,
      filePath: filePath ?? this.filePath,
      byteSize: byteSize ?? this.byteSize,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileExtension.present) {
      map['file_extension'] = Variable<String>(fileExtension.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkBlobsCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('filePath: $filePath, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStatesTable extends PlaybackStates
    with TableInfo<$PlaybackStatesTable, PlaybackState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queueTrackIdsJsonMeta = const VerificationMeta(
    'queueTrackIdsJson',
  );
  @override
  late final GeneratedColumn<String> queueTrackIdsJson =
      GeneratedColumn<String>(
        'queue_track_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _currentTrackIdMeta = const VerificationMeta(
    'currentTrackId',
  );
  @override
  late final GeneratedColumn<int> currentTrackId = GeneratedColumn<int>(
    'current_track_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPlayingMeta = const VerificationMeta(
    'isPlaying',
  );
  @override
  late final GeneratedColumn<bool> isPlaying = GeneratedColumn<bool>(
    'is_playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_playing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    queueTrackIdsJson,
    currentTrackId,
    currentIndex,
    positionMs,
    isPlaying,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('queue_track_ids_json')) {
      context.handle(
        _queueTrackIdsJsonMeta,
        queueTrackIdsJson.isAcceptableOrUnknown(
          data['queue_track_ids_json']!,
          _queueTrackIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('current_track_id')) {
      context.handle(
        _currentTrackIdMeta,
        currentTrackId.isAcceptableOrUnknown(
          data['current_track_id']!,
          _currentTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('is_playing')) {
      context.handle(
        _isPlayingMeta,
        isPlaying.isAcceptableOrUnknown(data['is_playing']!, _isPlayingMeta),
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
  PlaybackState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      queueTrackIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_track_ids_json'],
      )!,
      currentTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_track_id'],
      ),
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      isPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_playing'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackStatesTable createAlias(String alias) {
    return $PlaybackStatesTable(attachedDatabase, alias);
  }
}

class PlaybackState extends DataClass implements Insertable<PlaybackState> {
  final int id;
  final String queueTrackIdsJson;
  final int? currentTrackId;
  final int currentIndex;
  final int positionMs;
  final bool isPlaying;
  final DateTime updatedAt;
  const PlaybackState({
    required this.id,
    required this.queueTrackIdsJson,
    this.currentTrackId,
    required this.currentIndex,
    required this.positionMs,
    required this.isPlaying,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['queue_track_ids_json'] = Variable<String>(queueTrackIdsJson);
    if (!nullToAbsent || currentTrackId != null) {
      map['current_track_id'] = Variable<int>(currentTrackId);
    }
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['is_playing'] = Variable<bool>(isPlaying);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackStatesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStatesCompanion(
      id: Value(id),
      queueTrackIdsJson: Value(queueTrackIdsJson),
      currentTrackId: currentTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTrackId),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      isPlaying: Value(isPlaying),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackState(
      id: serializer.fromJson<int>(json['id']),
      queueTrackIdsJson: serializer.fromJson<String>(json['queueTrackIdsJson']),
      currentTrackId: serializer.fromJson<int?>(json['currentTrackId']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      isPlaying: serializer.fromJson<bool>(json['isPlaying']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queueTrackIdsJson': serializer.toJson<String>(queueTrackIdsJson),
      'currentTrackId': serializer.toJson<int?>(currentTrackId),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'isPlaying': serializer.toJson<bool>(isPlaying),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackState copyWith({
    int? id,
    String? queueTrackIdsJson,
    Value<int?> currentTrackId = const Value.absent(),
    int? currentIndex,
    int? positionMs,
    bool? isPlaying,
    DateTime? updatedAt,
  }) => PlaybackState(
    id: id ?? this.id,
    queueTrackIdsJson: queueTrackIdsJson ?? this.queueTrackIdsJson,
    currentTrackId: currentTrackId.present
        ? currentTrackId.value
        : this.currentTrackId,
    currentIndex: currentIndex ?? this.currentIndex,
    positionMs: positionMs ?? this.positionMs,
    isPlaying: isPlaying ?? this.isPlaying,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackState copyWithCompanion(PlaybackStatesCompanion data) {
    return PlaybackState(
      id: data.id.present ? data.id.value : this.id,
      queueTrackIdsJson: data.queueTrackIdsJson.present
          ? data.queueTrackIdsJson.value
          : this.queueTrackIdsJson,
      currentTrackId: data.currentTrackId.present
          ? data.currentTrackId.value
          : this.currentTrackId,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      isPlaying: data.isPlaying.present ? data.isPlaying.value : this.isPlaying,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackState(')
          ..write('id: $id, ')
          ..write('queueTrackIdsJson: $queueTrackIdsJson, ')
          ..write('currentTrackId: $currentTrackId, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    queueTrackIdsJson,
    currentTrackId,
    currentIndex,
    positionMs,
    isPlaying,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackState &&
          other.id == this.id &&
          other.queueTrackIdsJson == this.queueTrackIdsJson &&
          other.currentTrackId == this.currentTrackId &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.isPlaying == this.isPlaying &&
          other.updatedAt == this.updatedAt);
}

class PlaybackStatesCompanion extends UpdateCompanion<PlaybackState> {
  final Value<int> id;
  final Value<String> queueTrackIdsJson;
  final Value<int?> currentTrackId;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<bool> isPlaying;
  final Value<DateTime> updatedAt;
  const PlaybackStatesCompanion({
    this.id = const Value.absent(),
    this.queueTrackIdsJson = const Value.absent(),
    this.currentTrackId = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaybackStatesCompanion.insert({
    this.id = const Value.absent(),
    this.queueTrackIdsJson = const Value.absent(),
    this.currentTrackId = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<PlaybackState> custom({
    Expression<int>? id,
    Expression<String>? queueTrackIdsJson,
    Expression<int>? currentTrackId,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<bool>? isPlaying,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueTrackIdsJson != null) 'queue_track_ids_json': queueTrackIdsJson,
      if (currentTrackId != null) 'current_track_id': currentTrackId,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (isPlaying != null) 'is_playing': isPlaying,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaybackStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? queueTrackIdsJson,
    Value<int?>? currentTrackId,
    Value<int>? currentIndex,
    Value<int>? positionMs,
    Value<bool>? isPlaying,
    Value<DateTime>? updatedAt,
  }) {
    return PlaybackStatesCompanion(
      id: id ?? this.id,
      queueTrackIdsJson: queueTrackIdsJson ?? this.queueTrackIdsJson,
      currentTrackId: currentTrackId ?? this.currentTrackId,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queueTrackIdsJson.present) {
      map['queue_track_ids_json'] = Variable<String>(queueTrackIdsJson.value);
    }
    if (currentTrackId.present) {
      map['current_track_id'] = Variable<int>(currentTrackId.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (isPlaying.present) {
      map['is_playing'] = Variable<bool>(isPlaying.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStatesCompanion(')
          ..write('id: $id, ')
          ..write('queueTrackIdsJson: $queueTrackIdsJson, ')
          ..write('currentTrackId: $currentTrackId, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncAccountsTable syncAccounts = $SyncAccountsTable(this);
  late final $SyncRootsTable syncRoots = $SyncRootsTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $LibraryProjectionMetasTable libraryProjectionMetas =
      $LibraryProjectionMetasTable(this);
  late final $LibraryAlbumProjectionsTable libraryAlbumProjections =
      $LibraryAlbumProjectionsTable(this);
  late final $LibraryArtistProjectionsTable libraryArtistProjections =
      $LibraryArtistProjectionsTable(this);
  late final $LibraryAlbumArtistProjectionsTable libraryAlbumArtistProjections =
      $LibraryAlbumArtistProjectionsTable(this);
  late final $LibraryGenreProjectionsTable libraryGenreProjections =
      $LibraryGenreProjectionsTable(this);
  late final $DriveObjectsTable driveObjects = $DriveObjectsTable(this);
  late final $ScanJobsTable scanJobs = $ScanJobsTable(this);
  late final $ScanTasksTable scanTasks = $ScanTasksTable(this);
  late final $ArtworkBlobsTable artworkBlobs = $ArtworkBlobsTable(this);
  late final $PlaybackStatesTable playbackStates = $PlaybackStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncAccounts,
    syncRoots,
    tracks,
    libraryProjectionMetas,
    libraryAlbumProjections,
    libraryArtistProjections,
    libraryAlbumArtistProjections,
    libraryGenreProjections,
    driveObjects,
    scanJobs,
    scanTasks,
    artworkBlobs,
    playbackStates,
  ];
}

typedef $$SyncAccountsTableCreateCompanionBuilder =
    SyncAccountsCompanion Function({
      Value<int> id,
      required String providerAccountId,
      required String email,
      required String displayName,
      required String authKind,
      Value<bool> isActive,
      required DateTime connectedAt,
      Value<String> authSessionState,
      Value<String?> authSessionError,
      Value<String?> driveStartPageToken,
      Value<String?> driveChangePageToken,
      Value<DateTime?> lastSuccessfulSyncAt,
    });
typedef $$SyncAccountsTableUpdateCompanionBuilder =
    SyncAccountsCompanion Function({
      Value<int> id,
      Value<String> providerAccountId,
      Value<String> email,
      Value<String> displayName,
      Value<String> authKind,
      Value<bool> isActive,
      Value<DateTime> connectedAt,
      Value<String> authSessionState,
      Value<String?> authSessionError,
      Value<String?> driveStartPageToken,
      Value<String?> driveChangePageToken,
      Value<DateTime?> lastSuccessfulSyncAt,
    });

final class $$SyncAccountsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncAccountsTable, SyncAccount> {
  $$SyncAccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SyncRootsTable, List<SyncRoot>>
  _syncRootsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncRoots,
    aliasName: $_aliasNameGenerator(db.syncAccounts.id, db.syncRoots.accountId),
  );

  $$SyncRootsTableProcessedTableManager get syncRootsRefs {
    final manager = $$SyncRootsTableTableManager(
      $_db,
      $_db.syncRoots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncRootsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanJobsTable, List<ScanJob>> _scanJobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scanJobs,
    aliasName: $_aliasNameGenerator(db.syncAccounts.id, db.scanJobs.accountId),
  );

  $$ScanJobsTableProcessedTableManager get scanJobsRefs {
    final manager = $$ScanJobsTableTableManager(
      $_db,
      $_db.scanJobs,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authKind => $composableBuilder(
    column: $table.authKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authSessionState => $composableBuilder(
    column: $table.authSessionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authSessionError => $composableBuilder(
    column: $table.authSessionError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveStartPageToken => $composableBuilder(
    column: $table.driveStartPageToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveChangePageToken => $composableBuilder(
    column: $table.driveChangePageToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> syncRootsRefs(
    Expression<bool> Function($$SyncRootsTableFilterComposer f) f,
  ) {
    final $$SyncRootsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRoots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRootsTableFilterComposer(
            $db: $db,
            $table: $db.syncRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanJobsRefs(
    Expression<bool> Function($$ScanJobsTableFilterComposer f) f,
  ) {
    final $$ScanJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanJobs,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanJobsTableFilterComposer(
            $db: $db,
            $table: $db.scanJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authKind => $composableBuilder(
    column: $table.authKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authSessionState => $composableBuilder(
    column: $table.authSessionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authSessionError => $composableBuilder(
    column: $table.authSessionError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveStartPageToken => $composableBuilder(
    column: $table.driveStartPageToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveChangePageToken => $composableBuilder(
    column: $table.driveChangePageToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authKind =>
      $composableBuilder(column: $table.authKind, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authSessionState => $composableBuilder(
    column: $table.authSessionState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authSessionError => $composableBuilder(
    column: $table.authSessionError,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driveStartPageToken => $composableBuilder(
    column: $table.driveStartPageToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driveChangePageToken => $composableBuilder(
    column: $table.driveChangePageToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );

  Expression<T> syncRootsRefs<T extends Object>(
    Expression<T> Function($$SyncRootsTableAnnotationComposer a) f,
  ) {
    final $$SyncRootsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRoots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRootsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scanJobsRefs<T extends Object>(
    Expression<T> Function($$ScanJobsTableAnnotationComposer a) f,
  ) {
    final $$ScanJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanJobs,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncAccountsTable,
          SyncAccount,
          $$SyncAccountsTableFilterComposer,
          $$SyncAccountsTableOrderingComposer,
          $$SyncAccountsTableAnnotationComposer,
          $$SyncAccountsTableCreateCompanionBuilder,
          $$SyncAccountsTableUpdateCompanionBuilder,
          (SyncAccount, $$SyncAccountsTableReferences),
          SyncAccount,
          PrefetchHooks Function({bool syncRootsRefs, bool scanJobsRefs})
        > {
  $$SyncAccountsTableTableManager(_$AppDatabase db, $SyncAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerAccountId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> authKind = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> connectedAt = const Value.absent(),
                Value<String> authSessionState = const Value.absent(),
                Value<String?> authSessionError = const Value.absent(),
                Value<String?> driveStartPageToken = const Value.absent(),
                Value<String?> driveChangePageToken = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
              }) => SyncAccountsCompanion(
                id: id,
                providerAccountId: providerAccountId,
                email: email,
                displayName: displayName,
                authKind: authKind,
                isActive: isActive,
                connectedAt: connectedAt,
                authSessionState: authSessionState,
                authSessionError: authSessionError,
                driveStartPageToken: driveStartPageToken,
                driveChangePageToken: driveChangePageToken,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerAccountId,
                required String email,
                required String displayName,
                required String authKind,
                Value<bool> isActive = const Value.absent(),
                required DateTime connectedAt,
                Value<String> authSessionState = const Value.absent(),
                Value<String?> authSessionError = const Value.absent(),
                Value<String?> driveStartPageToken = const Value.absent(),
                Value<String?> driveChangePageToken = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
              }) => SyncAccountsCompanion.insert(
                id: id,
                providerAccountId: providerAccountId,
                email: email,
                displayName: displayName,
                authKind: authKind,
                isActive: isActive,
                connectedAt: connectedAt,
                authSessionState: authSessionState,
                authSessionError: authSessionError,
                driveStartPageToken: driveStartPageToken,
                driveChangePageToken: driveChangePageToken,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({syncRootsRefs = false, scanJobsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (syncRootsRefs) db.syncRoots,
                    if (scanJobsRefs) db.scanJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (syncRootsRefs)
                        await $_getPrefetchedData<
                          SyncAccount,
                          $SyncAccountsTable,
                          SyncRoot
                        >(
                          currentTable: table,
                          referencedTable: $$SyncAccountsTableReferences
                              ._syncRootsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncRootsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scanJobsRefs)
                        await $_getPrefetchedData<
                          SyncAccount,
                          $SyncAccountsTable,
                          ScanJob
                        >(
                          currentTable: table,
                          referencedTable: $$SyncAccountsTableReferences
                              ._scanJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).scanJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
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

typedef $$SyncAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncAccountsTable,
      SyncAccount,
      $$SyncAccountsTableFilterComposer,
      $$SyncAccountsTableOrderingComposer,
      $$SyncAccountsTableAnnotationComposer,
      $$SyncAccountsTableCreateCompanionBuilder,
      $$SyncAccountsTableUpdateCompanionBuilder,
      (SyncAccount, $$SyncAccountsTableReferences),
      SyncAccount,
      PrefetchHooks Function({bool syncRootsRefs, bool scanJobsRefs})
    >;
typedef $$SyncRootsTableCreateCompanionBuilder =
    SyncRootsCompanion Function({
      Value<int> id,
      required int accountId,
      required String folderId,
      required String folderName,
      Value<String?> parentFolderId,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<int?> activeJobId,
      Value<int> indexedCount,
      Value<int> metadataReadyCount,
      Value<int> artworkReadyCount,
      Value<int> failedCount,
    });
typedef $$SyncRootsTableUpdateCompanionBuilder =
    SyncRootsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<String> folderId,
      Value<String> folderName,
      Value<String?> parentFolderId,
      Value<String> syncState,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<int?> activeJobId,
      Value<int> indexedCount,
      Value<int> metadataReadyCount,
      Value<int> artworkReadyCount,
      Value<int> failedCount,
    });

final class $$SyncRootsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncRootsTable, SyncRoot> {
  $$SyncRootsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.syncAccounts.createAlias(
        $_aliasNameGenerator(db.syncRoots.accountId, db.syncAccounts.id),
      );

  $$SyncAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$SyncAccountsTableTableManager(
      $_db,
      $_db.syncAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: $_aliasNameGenerator(db.syncRoots.id, db.tracks.rootId),
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.rootId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncRootsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRootsTable> {
  $$SyncRootsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeJobId => $composableBuilder(
    column: $table.activeJobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncAccountsTableFilterComposer get accountId {
    final $$SyncAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableFilterComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.rootId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncRootsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRootsTable> {
  $$SyncRootsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeJobId => $composableBuilder(
    column: $table.activeJobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncAccountsTableOrderingComposer get accountId {
    final $$SyncAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRootsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRootsTable> {
  $$SyncRootsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get activeJobId => $composableBuilder(
    column: $table.activeJobId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  $$SyncAccountsTableAnnotationComposer get accountId {
    final $$SyncAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.rootId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncRootsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRootsTable,
          SyncRoot,
          $$SyncRootsTableFilterComposer,
          $$SyncRootsTableOrderingComposer,
          $$SyncRootsTableAnnotationComposer,
          $$SyncRootsTableCreateCompanionBuilder,
          $$SyncRootsTableUpdateCompanionBuilder,
          (SyncRoot, $$SyncRootsTableReferences),
          SyncRoot,
          PrefetchHooks Function({bool accountId, bool tracksRefs})
        > {
  $$SyncRootsTableTableManager(_$AppDatabase db, $SyncRootsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRootsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRootsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRootsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> folderId = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<String?> parentFolderId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int?> activeJobId = const Value.absent(),
                Value<int> indexedCount = const Value.absent(),
                Value<int> metadataReadyCount = const Value.absent(),
                Value<int> artworkReadyCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
              }) => SyncRootsCompanion(
                id: id,
                accountId: accountId,
                folderId: folderId,
                folderName: folderName,
                parentFolderId: parentFolderId,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                activeJobId: activeJobId,
                indexedCount: indexedCount,
                metadataReadyCount: metadataReadyCount,
                artworkReadyCount: artworkReadyCount,
                failedCount: failedCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required String folderId,
                required String folderName,
                Value<String?> parentFolderId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int?> activeJobId = const Value.absent(),
                Value<int> indexedCount = const Value.absent(),
                Value<int> metadataReadyCount = const Value.absent(),
                Value<int> artworkReadyCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
              }) => SyncRootsCompanion.insert(
                id: id,
                accountId: accountId,
                folderId: folderId,
                folderName: folderName,
                parentFolderId: parentFolderId,
                syncState: syncState,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                activeJobId: activeJobId,
                indexedCount: indexedCount,
                metadataReadyCount: metadataReadyCount,
                artworkReadyCount: artworkReadyCount,
                failedCount: failedCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncRootsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, tracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksRefs) db.tracks],
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$SyncRootsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$SyncRootsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedData<SyncRoot, $SyncRootsTable, Track>(
                      currentTable: table,
                      referencedTable: $$SyncRootsTableReferences
                          ._tracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SyncRootsTableReferences(db, table, p0).tracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rootId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SyncRootsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRootsTable,
      SyncRoot,
      $$SyncRootsTableFilterComposer,
      $$SyncRootsTableOrderingComposer,
      $$SyncRootsTableAnnotationComposer,
      $$SyncRootsTableCreateCompanionBuilder,
      $$SyncRootsTableUpdateCompanionBuilder,
      (SyncRoot, $$SyncRootsTableReferences),
      SyncRoot,
      PrefetchHooks Function({bool accountId, bool tracksRefs})
    >;
typedef $$TracksTableCreateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      required int rootId,
      required String driveFileId,
      Value<String?> resourceKey,
      required String fileName,
      required String title,
      Value<String> titleSort,
      required String artist,
      Value<String> artistSort,
      required String album,
      required String albumArtist,
      required String genre,
      Value<int?> year,
      Value<int> trackNumber,
      Value<int> discNumber,
      Value<int> durationMs,
      required String mimeType,
      Value<int?> sizeBytes,
      Value<String?> md5Checksum,
      Value<DateTime?> modifiedTime,
      Value<String?> artworkUri,
      Value<int?> artworkBlobId,
      Value<String> artworkStatus,
      Value<String?> cachePath,
      Value<String> cacheStatus,
      Value<String> metadataStatus,
      Value<String> indexStatus,
      Value<int> metadataSchemaVersion,
      Value<String?> contentFingerprint,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<bool> isFavorite,
      Value<DateTime> insertedAt,
      Value<DateTime> discoveredAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> removedAt,
    });
typedef $$TracksTableUpdateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      Value<int> rootId,
      Value<String> driveFileId,
      Value<String?> resourceKey,
      Value<String> fileName,
      Value<String> title,
      Value<String> titleSort,
      Value<String> artist,
      Value<String> artistSort,
      Value<String> album,
      Value<String> albumArtist,
      Value<String> genre,
      Value<int?> year,
      Value<int> trackNumber,
      Value<int> discNumber,
      Value<int> durationMs,
      Value<String> mimeType,
      Value<int?> sizeBytes,
      Value<String?> md5Checksum,
      Value<DateTime?> modifiedTime,
      Value<String?> artworkUri,
      Value<int?> artworkBlobId,
      Value<String> artworkStatus,
      Value<String?> cachePath,
      Value<String> cacheStatus,
      Value<String> metadataStatus,
      Value<String> indexStatus,
      Value<int> metadataSchemaVersion,
      Value<String?> contentFingerprint,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<bool> isFavorite,
      Value<DateTime> insertedAt,
      Value<DateTime> discoveredAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> removedAt,
    });

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncRootsTable _rootIdTable(_$AppDatabase db) => db.syncRoots
      .createAlias($_aliasNameGenerator(db.tracks.rootId, db.syncRoots.id));

  $$SyncRootsTableProcessedTableManager get rootId {
    final $_column = $_itemColumn<int>('root_id')!;

    final manager = $$SyncRootsTableTableManager(
      $_db,
      $_db.syncRoots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rootIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkBlobId => $composableBuilder(
    column: $table.artworkBlobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkStatus => $composableBuilder(
    column: $table.artworkStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheStatus => $composableBuilder(
    column: $table.cacheStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataStatus => $composableBuilder(
    column: $table.metadataStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get indexStatus => $composableBuilder(
    column: $table.indexStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataSchemaVersion => $composableBuilder(
    column: $table.metadataSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncRootsTableFilterComposer get rootId {
    final $$SyncRootsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.syncRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRootsTableFilterComposer(
            $db: $db,
            $table: $db.syncRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkBlobId => $composableBuilder(
    column: $table.artworkBlobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkStatus => $composableBuilder(
    column: $table.artworkStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheStatus => $composableBuilder(
    column: $table.cacheStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataStatus => $composableBuilder(
    column: $table.metadataStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indexStatus => $composableBuilder(
    column: $table.indexStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataSchemaVersion => $composableBuilder(
    column: $table.metadataSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncRootsTableOrderingComposer get rootId {
    final $$SyncRootsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.syncRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRootsTableOrderingComposer(
            $db: $db,
            $table: $db.syncRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleSort =>
      $composableBuilder(column: $table.titleSort, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => column,
  );

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkBlobId => $composableBuilder(
    column: $table.artworkBlobId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkStatus => $composableBuilder(
    column: $table.artworkStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachePath =>
      $composableBuilder(column: $table.cachePath, builder: (column) => column);

  GeneratedColumn<String> get cacheStatus => $composableBuilder(
    column: $table.cacheStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataStatus => $composableBuilder(
    column: $table.metadataStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get indexStatus => $composableBuilder(
    column: $table.indexStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataSchemaVersion => $composableBuilder(
    column: $table.metadataSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  $$SyncRootsTableAnnotationComposer get rootId {
    final $$SyncRootsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.syncRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRootsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({bool rootId})
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rootId = const Value.absent(),
                Value<String> driveFileId = const Value.absent(),
                Value<String?> resourceKey = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleSort = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> artistSort = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> md5Checksum = const Value.absent(),
                Value<DateTime?> modifiedTime = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<int?> artworkBlobId = const Value.absent(),
                Value<String> artworkStatus = const Value.absent(),
                Value<String?> cachePath = const Value.absent(),
                Value<String> cacheStatus = const Value.absent(),
                Value<String> metadataStatus = const Value.absent(),
                Value<String> indexStatus = const Value.absent(),
                Value<int> metadataSchemaVersion = const Value.absent(),
                Value<String?> contentFingerprint = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> insertedAt = const Value.absent(),
                Value<DateTime> discoveredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                rootId: rootId,
                driveFileId: driveFileId,
                resourceKey: resourceKey,
                fileName: fileName,
                title: title,
                titleSort: titleSort,
                artist: artist,
                artistSort: artistSort,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                discNumber: discNumber,
                durationMs: durationMs,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                md5Checksum: md5Checksum,
                modifiedTime: modifiedTime,
                artworkUri: artworkUri,
                artworkBlobId: artworkBlobId,
                artworkStatus: artworkStatus,
                cachePath: cachePath,
                cacheStatus: cacheStatus,
                metadataStatus: metadataStatus,
                indexStatus: indexStatus,
                metadataSchemaVersion: metadataSchemaVersion,
                contentFingerprint: contentFingerprint,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                isFavorite: isFavorite,
                insertedAt: insertedAt,
                discoveredAt: discoveredAt,
                updatedAt: updatedAt,
                removedAt: removedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rootId,
                required String driveFileId,
                Value<String?> resourceKey = const Value.absent(),
                required String fileName,
                required String title,
                Value<String> titleSort = const Value.absent(),
                required String artist,
                Value<String> artistSort = const Value.absent(),
                required String album,
                required String albumArtist,
                required String genre,
                Value<int?> year = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required String mimeType,
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> md5Checksum = const Value.absent(),
                Value<DateTime?> modifiedTime = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<int?> artworkBlobId = const Value.absent(),
                Value<String> artworkStatus = const Value.absent(),
                Value<String?> cachePath = const Value.absent(),
                Value<String> cacheStatus = const Value.absent(),
                Value<String> metadataStatus = const Value.absent(),
                Value<String> indexStatus = const Value.absent(),
                Value<int> metadataSchemaVersion = const Value.absent(),
                Value<String?> contentFingerprint = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> insertedAt = const Value.absent(),
                Value<DateTime> discoveredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                rootId: rootId,
                driveFileId: driveFileId,
                resourceKey: resourceKey,
                fileName: fileName,
                title: title,
                titleSort: titleSort,
                artist: artist,
                artistSort: artistSort,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                discNumber: discNumber,
                durationMs: durationMs,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                md5Checksum: md5Checksum,
                modifiedTime: modifiedTime,
                artworkUri: artworkUri,
                artworkBlobId: artworkBlobId,
                artworkStatus: artworkStatus,
                cachePath: cachePath,
                cacheStatus: cacheStatus,
                metadataStatus: metadataStatus,
                indexStatus: indexStatus,
                metadataSchemaVersion: metadataSchemaVersion,
                contentFingerprint: contentFingerprint,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                isFavorite: isFavorite,
                insertedAt: insertedAt,
                discoveredAt: discoveredAt,
                updatedAt: updatedAt,
                removedAt: removedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TracksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({rootId = false}) {
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
                    if (rootId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rootId,
                                referencedTable: $$TracksTableReferences
                                    ._rootIdTable(db),
                                referencedColumn: $$TracksTableReferences
                                    ._rootIdTable(db)
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

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({bool rootId})
    >;
typedef $$LibraryProjectionMetasTableCreateCompanionBuilder =
    LibraryProjectionMetasCompanion Function({
      Value<int> id,
      Value<int> revision,
      Value<String> backfillState,
      Value<DateTime?> lastBackfillAt,
      Value<String?> lastError,
    });
typedef $$LibraryProjectionMetasTableUpdateCompanionBuilder =
    LibraryProjectionMetasCompanion Function({
      Value<int> id,
      Value<int> revision,
      Value<String> backfillState,
      Value<DateTime?> lastBackfillAt,
      Value<String?> lastError,
    });

class $$LibraryProjectionMetasTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryProjectionMetasTable> {
  $$LibraryProjectionMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backfillState => $composableBuilder(
    column: $table.backfillState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBackfillAt => $composableBuilder(
    column: $table.lastBackfillAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryProjectionMetasTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryProjectionMetasTable> {
  $$LibraryProjectionMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backfillState => $composableBuilder(
    column: $table.backfillState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBackfillAt => $composableBuilder(
    column: $table.lastBackfillAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryProjectionMetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryProjectionMetasTable> {
  $$LibraryProjectionMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get backfillState => $composableBuilder(
    column: $table.backfillState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBackfillAt => $composableBuilder(
    column: $table.lastBackfillAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$LibraryProjectionMetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryProjectionMetasTable,
          LibraryProjectionMeta,
          $$LibraryProjectionMetasTableFilterComposer,
          $$LibraryProjectionMetasTableOrderingComposer,
          $$LibraryProjectionMetasTableAnnotationComposer,
          $$LibraryProjectionMetasTableCreateCompanionBuilder,
          $$LibraryProjectionMetasTableUpdateCompanionBuilder,
          (
            LibraryProjectionMeta,
            BaseReferences<
              _$AppDatabase,
              $LibraryProjectionMetasTable,
              LibraryProjectionMeta
            >,
          ),
          LibraryProjectionMeta,
          PrefetchHooks Function()
        > {
  $$LibraryProjectionMetasTableTableManager(
    _$AppDatabase db,
    $LibraryProjectionMetasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryProjectionMetasTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LibraryProjectionMetasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryProjectionMetasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> backfillState = const Value.absent(),
                Value<DateTime?> lastBackfillAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => LibraryProjectionMetasCompanion(
                id: id,
                revision: revision,
                backfillState: backfillState,
                lastBackfillAt: lastBackfillAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> backfillState = const Value.absent(),
                Value<DateTime?> lastBackfillAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => LibraryProjectionMetasCompanion.insert(
                id: id,
                revision: revision,
                backfillState: backfillState,
                lastBackfillAt: lastBackfillAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryProjectionMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryProjectionMetasTable,
      LibraryProjectionMeta,
      $$LibraryProjectionMetasTableFilterComposer,
      $$LibraryProjectionMetasTableOrderingComposer,
      $$LibraryProjectionMetasTableAnnotationComposer,
      $$LibraryProjectionMetasTableCreateCompanionBuilder,
      $$LibraryProjectionMetasTableUpdateCompanionBuilder,
      (
        LibraryProjectionMeta,
        BaseReferences<
          _$AppDatabase,
          $LibraryProjectionMetasTable,
          LibraryProjectionMeta
        >,
      ),
      LibraryProjectionMeta,
      PrefetchHooks Function()
    >;
typedef $$LibraryAlbumProjectionsTableCreateCompanionBuilder =
    LibraryAlbumProjectionsCompanion Function({
      required String stableId,
      required String album,
      required String albumArtist,
      required String titleSort,
      required String artistSort,
      Value<int> year,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryAlbumProjectionsTableUpdateCompanionBuilder =
    LibraryAlbumProjectionsCompanion Function({
      Value<String> stableId,
      Value<String> album,
      Value<String> albumArtist,
      Value<String> titleSort,
      Value<String> artistSort,
      Value<int> year,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LibraryAlbumProjectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryAlbumProjectionsTable> {
  $$LibraryAlbumProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryAlbumProjectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryAlbumProjectionsTable> {
  $$LibraryAlbumProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryAlbumProjectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryAlbumProjectionsTable> {
  $$LibraryAlbumProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stableId =>
      $composableBuilder(column: $table.stableId, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleSort =>
      $composableBuilder(column: $table.titleSort, builder: (column) => column);

  GeneratedColumn<String> get artistSort => $composableBuilder(
    column: $table.artistSort,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryAlbumProjectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryAlbumProjectionsTable,
          LibraryAlbumProjection,
          $$LibraryAlbumProjectionsTableFilterComposer,
          $$LibraryAlbumProjectionsTableOrderingComposer,
          $$LibraryAlbumProjectionsTableAnnotationComposer,
          $$LibraryAlbumProjectionsTableCreateCompanionBuilder,
          $$LibraryAlbumProjectionsTableUpdateCompanionBuilder,
          (
            LibraryAlbumProjection,
            BaseReferences<
              _$AppDatabase,
              $LibraryAlbumProjectionsTable,
              LibraryAlbumProjection
            >,
          ),
          LibraryAlbumProjection,
          PrefetchHooks Function()
        > {
  $$LibraryAlbumProjectionsTableTableManager(
    _$AppDatabase db,
    $LibraryAlbumProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryAlbumProjectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LibraryAlbumProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryAlbumProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> stableId = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<String> titleSort = const Value.absent(),
                Value<String> artistSort = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAlbumProjectionsCompanion(
                stableId: stableId,
                album: album,
                albumArtist: albumArtist,
                titleSort: titleSort,
                artistSort: artistSort,
                year: year,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stableId,
                required String album,
                required String albumArtist,
                required String titleSort,
                required String artistSort,
                Value<int> year = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAlbumProjectionsCompanion.insert(
                stableId: stableId,
                album: album,
                albumArtist: albumArtist,
                titleSort: titleSort,
                artistSort: artistSort,
                year: year,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryAlbumProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryAlbumProjectionsTable,
      LibraryAlbumProjection,
      $$LibraryAlbumProjectionsTableFilterComposer,
      $$LibraryAlbumProjectionsTableOrderingComposer,
      $$LibraryAlbumProjectionsTableAnnotationComposer,
      $$LibraryAlbumProjectionsTableCreateCompanionBuilder,
      $$LibraryAlbumProjectionsTableUpdateCompanionBuilder,
      (
        LibraryAlbumProjection,
        BaseReferences<
          _$AppDatabase,
          $LibraryAlbumProjectionsTable,
          LibraryAlbumProjection
        >,
      ),
      LibraryAlbumProjection,
      PrefetchHooks Function()
    >;
typedef $$LibraryArtistProjectionsTableCreateCompanionBuilder =
    LibraryArtistProjectionsCompanion Function({
      required String stableId,
      required String name,
      required String nameSort,
      Value<int> songCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryArtistProjectionsTableUpdateCompanionBuilder =
    LibraryArtistProjectionsCompanion Function({
      Value<String> stableId,
      Value<String> name,
      Value<String> nameSort,
      Value<int> songCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LibraryArtistProjectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryArtistProjectionsTable> {
  $$LibraryArtistProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryArtistProjectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryArtistProjectionsTable> {
  $$LibraryArtistProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryArtistProjectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryArtistProjectionsTable> {
  $$LibraryArtistProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stableId =>
      $composableBuilder(column: $table.stableId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameSort =>
      $composableBuilder(column: $table.nameSort, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryArtistProjectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryArtistProjectionsTable,
          LibraryArtistProjection,
          $$LibraryArtistProjectionsTableFilterComposer,
          $$LibraryArtistProjectionsTableOrderingComposer,
          $$LibraryArtistProjectionsTableAnnotationComposer,
          $$LibraryArtistProjectionsTableCreateCompanionBuilder,
          $$LibraryArtistProjectionsTableUpdateCompanionBuilder,
          (
            LibraryArtistProjection,
            BaseReferences<
              _$AppDatabase,
              $LibraryArtistProjectionsTable,
              LibraryArtistProjection
            >,
          ),
          LibraryArtistProjection,
          PrefetchHooks Function()
        > {
  $$LibraryArtistProjectionsTableTableManager(
    _$AppDatabase db,
    $LibraryArtistProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryArtistProjectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LibraryArtistProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryArtistProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> stableId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameSort = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryArtistProjectionsCompanion(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                songCount: songCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stableId,
                required String name,
                required String nameSort,
                Value<int> songCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryArtistProjectionsCompanion.insert(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                songCount: songCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryArtistProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryArtistProjectionsTable,
      LibraryArtistProjection,
      $$LibraryArtistProjectionsTableFilterComposer,
      $$LibraryArtistProjectionsTableOrderingComposer,
      $$LibraryArtistProjectionsTableAnnotationComposer,
      $$LibraryArtistProjectionsTableCreateCompanionBuilder,
      $$LibraryArtistProjectionsTableUpdateCompanionBuilder,
      (
        LibraryArtistProjection,
        BaseReferences<
          _$AppDatabase,
          $LibraryArtistProjectionsTable,
          LibraryArtistProjection
        >,
      ),
      LibraryArtistProjection,
      PrefetchHooks Function()
    >;
typedef $$LibraryAlbumArtistProjectionsTableCreateCompanionBuilder =
    LibraryAlbumArtistProjectionsCompanion Function({
      required String stableId,
      required String name,
      required String nameSort,
      Value<int> albumCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryAlbumArtistProjectionsTableUpdateCompanionBuilder =
    LibraryAlbumArtistProjectionsCompanion Function({
      Value<String> stableId,
      Value<String> name,
      Value<String> nameSort,
      Value<int> albumCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LibraryAlbumArtistProjectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryAlbumArtistProjectionsTable> {
  $$LibraryAlbumArtistProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryAlbumArtistProjectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryAlbumArtistProjectionsTable> {
  $$LibraryAlbumArtistProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryAlbumArtistProjectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryAlbumArtistProjectionsTable> {
  $$LibraryAlbumArtistProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stableId =>
      $composableBuilder(column: $table.stableId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameSort =>
      $composableBuilder(column: $table.nameSort, builder: (column) => column);

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryAlbumArtistProjectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryAlbumArtistProjectionsTable,
          LibraryAlbumArtistProjection,
          $$LibraryAlbumArtistProjectionsTableFilterComposer,
          $$LibraryAlbumArtistProjectionsTableOrderingComposer,
          $$LibraryAlbumArtistProjectionsTableAnnotationComposer,
          $$LibraryAlbumArtistProjectionsTableCreateCompanionBuilder,
          $$LibraryAlbumArtistProjectionsTableUpdateCompanionBuilder,
          (
            LibraryAlbumArtistProjection,
            BaseReferences<
              _$AppDatabase,
              $LibraryAlbumArtistProjectionsTable,
              LibraryAlbumArtistProjection
            >,
          ),
          LibraryAlbumArtistProjection,
          PrefetchHooks Function()
        > {
  $$LibraryAlbumArtistProjectionsTableTableManager(
    _$AppDatabase db,
    $LibraryAlbumArtistProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryAlbumArtistProjectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LibraryAlbumArtistProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryAlbumArtistProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> stableId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameSort = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAlbumArtistProjectionsCompanion(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                albumCount: albumCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stableId,
                required String name,
                required String nameSort,
                Value<int> albumCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAlbumArtistProjectionsCompanion.insert(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                albumCount: albumCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryAlbumArtistProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryAlbumArtistProjectionsTable,
      LibraryAlbumArtistProjection,
      $$LibraryAlbumArtistProjectionsTableFilterComposer,
      $$LibraryAlbumArtistProjectionsTableOrderingComposer,
      $$LibraryAlbumArtistProjectionsTableAnnotationComposer,
      $$LibraryAlbumArtistProjectionsTableCreateCompanionBuilder,
      $$LibraryAlbumArtistProjectionsTableUpdateCompanionBuilder,
      (
        LibraryAlbumArtistProjection,
        BaseReferences<
          _$AppDatabase,
          $LibraryAlbumArtistProjectionsTable,
          LibraryAlbumArtistProjection
        >,
      ),
      LibraryAlbumArtistProjection,
      PrefetchHooks Function()
    >;
typedef $$LibraryGenreProjectionsTableCreateCompanionBuilder =
    LibraryGenreProjectionsCompanion Function({
      required String stableId,
      required String name,
      required String nameSort,
      Value<int> songCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryGenreProjectionsTableUpdateCompanionBuilder =
    LibraryGenreProjectionsCompanion Function({
      Value<String> stableId,
      Value<String> name,
      Value<String> nameSort,
      Value<int> songCount,
      Value<String> artworkUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LibraryGenreProjectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryGenreProjectionsTable> {
  $$LibraryGenreProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryGenreProjectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryGenreProjectionsTable> {
  $$LibraryGenreProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stableId => $composableBuilder(
    column: $table.stableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSort => $composableBuilder(
    column: $table.nameSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryGenreProjectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryGenreProjectionsTable> {
  $$LibraryGenreProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stableId =>
      $composableBuilder(column: $table.stableId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameSort =>
      $composableBuilder(column: $table.nameSort, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryGenreProjectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryGenreProjectionsTable,
          LibraryGenreProjection,
          $$LibraryGenreProjectionsTableFilterComposer,
          $$LibraryGenreProjectionsTableOrderingComposer,
          $$LibraryGenreProjectionsTableAnnotationComposer,
          $$LibraryGenreProjectionsTableCreateCompanionBuilder,
          $$LibraryGenreProjectionsTableUpdateCompanionBuilder,
          (
            LibraryGenreProjection,
            BaseReferences<
              _$AppDatabase,
              $LibraryGenreProjectionsTable,
              LibraryGenreProjection
            >,
          ),
          LibraryGenreProjection,
          PrefetchHooks Function()
        > {
  $$LibraryGenreProjectionsTableTableManager(
    _$AppDatabase db,
    $LibraryGenreProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryGenreProjectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LibraryGenreProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryGenreProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> stableId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameSort = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryGenreProjectionsCompanion(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                songCount: songCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stableId,
                required String name,
                required String nameSort,
                Value<int> songCount = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryGenreProjectionsCompanion.insert(
                stableId: stableId,
                name: name,
                nameSort: nameSort,
                songCount: songCount,
                artworkUri: artworkUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryGenreProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryGenreProjectionsTable,
      LibraryGenreProjection,
      $$LibraryGenreProjectionsTableFilterComposer,
      $$LibraryGenreProjectionsTableOrderingComposer,
      $$LibraryGenreProjectionsTableAnnotationComposer,
      $$LibraryGenreProjectionsTableCreateCompanionBuilder,
      $$LibraryGenreProjectionsTableUpdateCompanionBuilder,
      (
        LibraryGenreProjection,
        BaseReferences<
          _$AppDatabase,
          $LibraryGenreProjectionsTable,
          LibraryGenreProjection
        >,
      ),
      LibraryGenreProjection,
      PrefetchHooks Function()
    >;
typedef $$DriveObjectsTableCreateCompanionBuilder =
    DriveObjectsCompanion Function({
      required String driveId,
      Value<String?> parentDriveId,
      required String name,
      required String mimeType,
      required String objectKind,
      Value<String?> resourceKey,
      Value<int?> sizeBytes,
      Value<String?> md5Checksum,
      Value<DateTime?> modifiedTime,
      Value<String> rootIdsJson,
      Value<bool> isTombstoned,
      Value<int?> lastSeenJobId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DriveObjectsTableUpdateCompanionBuilder =
    DriveObjectsCompanion Function({
      Value<String> driveId,
      Value<String?> parentDriveId,
      Value<String> name,
      Value<String> mimeType,
      Value<String> objectKind,
      Value<String?> resourceKey,
      Value<int?> sizeBytes,
      Value<String?> md5Checksum,
      Value<DateTime?> modifiedTime,
      Value<String> rootIdsJson,
      Value<bool> isTombstoned,
      Value<int?> lastSeenJobId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DriveObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $DriveObjectsTable> {
  $$DriveObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get driveId => $composableBuilder(
    column: $table.driveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentDriveId => $composableBuilder(
    column: $table.parentDriveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectKind => $composableBuilder(
    column: $table.objectKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootIdsJson => $composableBuilder(
    column: $table.rootIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTombstoned => $composableBuilder(
    column: $table.isTombstoned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenJobId => $composableBuilder(
    column: $table.lastSeenJobId,
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
}

class $$DriveObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriveObjectsTable> {
  $$DriveObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get driveId => $composableBuilder(
    column: $table.driveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentDriveId => $composableBuilder(
    column: $table.parentDriveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectKind => $composableBuilder(
    column: $table.objectKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootIdsJson => $composableBuilder(
    column: $table.rootIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTombstoned => $composableBuilder(
    column: $table.isTombstoned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenJobId => $composableBuilder(
    column: $table.lastSeenJobId,
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

class $$DriveObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriveObjectsTable> {
  $$DriveObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get driveId =>
      $composableBuilder(column: $table.driveId, builder: (column) => column);

  GeneratedColumn<String> get parentDriveId => $composableBuilder(
    column: $table.parentDriveId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get objectKind => $composableBuilder(
    column: $table.objectKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get md5Checksum => $composableBuilder(
    column: $table.md5Checksum,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootIdsJson => $composableBuilder(
    column: $table.rootIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTombstoned => $composableBuilder(
    column: $table.isTombstoned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenJobId => $composableBuilder(
    column: $table.lastSeenJobId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DriveObjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DriveObjectsTable,
          DriveObject,
          $$DriveObjectsTableFilterComposer,
          $$DriveObjectsTableOrderingComposer,
          $$DriveObjectsTableAnnotationComposer,
          $$DriveObjectsTableCreateCompanionBuilder,
          $$DriveObjectsTableUpdateCompanionBuilder,
          (
            DriveObject,
            BaseReferences<_$AppDatabase, $DriveObjectsTable, DriveObject>,
          ),
          DriveObject,
          PrefetchHooks Function()
        > {
  $$DriveObjectsTableTableManager(_$AppDatabase db, $DriveObjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriveObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriveObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriveObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> driveId = const Value.absent(),
                Value<String?> parentDriveId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String> objectKind = const Value.absent(),
                Value<String?> resourceKey = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> md5Checksum = const Value.absent(),
                Value<DateTime?> modifiedTime = const Value.absent(),
                Value<String> rootIdsJson = const Value.absent(),
                Value<bool> isTombstoned = const Value.absent(),
                Value<int?> lastSeenJobId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DriveObjectsCompanion(
                driveId: driveId,
                parentDriveId: parentDriveId,
                name: name,
                mimeType: mimeType,
                objectKind: objectKind,
                resourceKey: resourceKey,
                sizeBytes: sizeBytes,
                md5Checksum: md5Checksum,
                modifiedTime: modifiedTime,
                rootIdsJson: rootIdsJson,
                isTombstoned: isTombstoned,
                lastSeenJobId: lastSeenJobId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String driveId,
                Value<String?> parentDriveId = const Value.absent(),
                required String name,
                required String mimeType,
                required String objectKind,
                Value<String?> resourceKey = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> md5Checksum = const Value.absent(),
                Value<DateTime?> modifiedTime = const Value.absent(),
                Value<String> rootIdsJson = const Value.absent(),
                Value<bool> isTombstoned = const Value.absent(),
                Value<int?> lastSeenJobId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DriveObjectsCompanion.insert(
                driveId: driveId,
                parentDriveId: parentDriveId,
                name: name,
                mimeType: mimeType,
                objectKind: objectKind,
                resourceKey: resourceKey,
                sizeBytes: sizeBytes,
                md5Checksum: md5Checksum,
                modifiedTime: modifiedTime,
                rootIdsJson: rootIdsJson,
                isTombstoned: isTombstoned,
                lastSeenJobId: lastSeenJobId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DriveObjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DriveObjectsTable,
      DriveObject,
      $$DriveObjectsTableFilterComposer,
      $$DriveObjectsTableOrderingComposer,
      $$DriveObjectsTableAnnotationComposer,
      $$DriveObjectsTableCreateCompanionBuilder,
      $$DriveObjectsTableUpdateCompanionBuilder,
      (
        DriveObject,
        BaseReferences<_$AppDatabase, $DriveObjectsTable, DriveObject>,
      ),
      DriveObject,
      PrefetchHooks Function()
    >;
typedef $$ScanJobsTableCreateCompanionBuilder =
    ScanJobsCompanion Function({
      Value<int> id,
      required int accountId,
      Value<int?> rootId,
      required String kind,
      required String state,
      required String phase,
      Value<String?> checkpointToken,
      Value<String?> startPageToken,
      Value<int> indexedCount,
      Value<int> metadataReadyCount,
      Value<int> artworkReadyCount,
      Value<int> failedCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
    });
typedef $$ScanJobsTableUpdateCompanionBuilder =
    ScanJobsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int?> rootId,
      Value<String> kind,
      Value<String> state,
      Value<String> phase,
      Value<String?> checkpointToken,
      Value<String?> startPageToken,
      Value<int> indexedCount,
      Value<int> metadataReadyCount,
      Value<int> artworkReadyCount,
      Value<int> failedCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
    });

final class $$ScanJobsTableReferences
    extends BaseReferences<_$AppDatabase, $ScanJobsTable, ScanJob> {
  $$ScanJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.syncAccounts.createAlias(
        $_aliasNameGenerator(db.scanJobs.accountId, db.syncAccounts.id),
      );

  $$SyncAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$SyncAccountsTableTableManager(
      $_db,
      $_db.syncAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScanTasksTable, List<ScanTask>>
  _scanTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanTasks,
    aliasName: $_aliasNameGenerator(db.scanJobs.id, db.scanTasks.jobId),
  );

  $$ScanTasksTableProcessedTableManager get scanTasksRefs {
    final manager = $$ScanTasksTableTableManager(
      $_db,
      $_db.scanTasks,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScanJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanJobsTable> {
  $$ScanJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkpointToken => $composableBuilder(
    column: $table.checkpointToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startPageToken => $composableBuilder(
    column: $table.startPageToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncAccountsTableFilterComposer get accountId {
    final $$SyncAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableFilterComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scanTasksRefs(
    Expression<bool> Function($$ScanTasksTableFilterComposer f) f,
  ) {
    final $$ScanTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanTasks,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanTasksTableFilterComposer(
            $db: $db,
            $table: $db.scanTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScanJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanJobsTable> {
  $$ScanJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkpointToken => $composableBuilder(
    column: $table.checkpointToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startPageToken => $composableBuilder(
    column: $table.startPageToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncAccountsTableOrderingComposer get accountId {
    final $$SyncAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanJobsTable> {
  $$ScanJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get checkpointToken => $composableBuilder(
    column: $table.checkpointToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startPageToken => $composableBuilder(
    column: $table.startPageToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get indexedCount => $composableBuilder(
    column: $table.indexedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataReadyCount => $composableBuilder(
    column: $table.metadataReadyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkReadyCount => $composableBuilder(
    column: $table.artworkReadyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$SyncAccountsTableAnnotationComposer get accountId {
    final $$SyncAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.syncAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scanTasksRefs<T extends Object>(
    Expression<T> Function($$ScanTasksTableAnnotationComposer a) f,
  ) {
    final $$ScanTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanTasks,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.scanTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScanJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanJobsTable,
          ScanJob,
          $$ScanJobsTableFilterComposer,
          $$ScanJobsTableOrderingComposer,
          $$ScanJobsTableAnnotationComposer,
          $$ScanJobsTableCreateCompanionBuilder,
          $$ScanJobsTableUpdateCompanionBuilder,
          (ScanJob, $$ScanJobsTableReferences),
          ScanJob,
          PrefetchHooks Function({bool accountId, bool scanTasksRefs})
        > {
  $$ScanJobsTableTableManager(_$AppDatabase db, $ScanJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> rootId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String?> checkpointToken = const Value.absent(),
                Value<String?> startPageToken = const Value.absent(),
                Value<int> indexedCount = const Value.absent(),
                Value<int> metadataReadyCount = const Value.absent(),
                Value<int> artworkReadyCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => ScanJobsCompanion(
                id: id,
                accountId: accountId,
                rootId: rootId,
                kind: kind,
                state: state,
                phase: phase,
                checkpointToken: checkpointToken,
                startPageToken: startPageToken,
                indexedCount: indexedCount,
                metadataReadyCount: metadataReadyCount,
                artworkReadyCount: artworkReadyCount,
                failedCount: failedCount,
                lastError: lastError,
                createdAt: createdAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                Value<int?> rootId = const Value.absent(),
                required String kind,
                required String state,
                required String phase,
                Value<String?> checkpointToken = const Value.absent(),
                Value<String?> startPageToken = const Value.absent(),
                Value<int> indexedCount = const Value.absent(),
                Value<int> metadataReadyCount = const Value.absent(),
                Value<int> artworkReadyCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => ScanJobsCompanion.insert(
                id: id,
                accountId: accountId,
                rootId: rootId,
                kind: kind,
                state: state,
                phase: phase,
                checkpointToken: checkpointToken,
                startPageToken: startPageToken,
                indexedCount: indexedCount,
                metadataReadyCount: metadataReadyCount,
                artworkReadyCount: artworkReadyCount,
                failedCount: failedCount,
                lastError: lastError,
                createdAt: createdAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, scanTasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scanTasksRefs) db.scanTasks],
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$ScanJobsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$ScanJobsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scanTasksRefs)
                    await $_getPrefetchedData<
                      ScanJob,
                      $ScanJobsTable,
                      ScanTask
                    >(
                      currentTable: table,
                      referencedTable: $$ScanJobsTableReferences
                          ._scanTasksRefsTable(db),
                      managerFromTypedResult: (p0) => $$ScanJobsTableReferences(
                        db,
                        table,
                        p0,
                      ).scanTasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.jobId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScanJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanJobsTable,
      ScanJob,
      $$ScanJobsTableFilterComposer,
      $$ScanJobsTableOrderingComposer,
      $$ScanJobsTableAnnotationComposer,
      $$ScanJobsTableCreateCompanionBuilder,
      $$ScanJobsTableUpdateCompanionBuilder,
      (ScanJob, $$ScanJobsTableReferences),
      ScanJob,
      PrefetchHooks Function({bool accountId, bool scanTasksRefs})
    >;
typedef $$ScanTasksTableCreateCompanionBuilder =
    ScanTasksCompanion Function({
      Value<int> id,
      required int jobId,
      required String kind,
      Value<String> state,
      Value<int?> rootId,
      Value<String?> targetDriveId,
      Value<String?> dedupeKey,
      Value<String> payloadJson,
      Value<int> attempts,
      Value<int> priority,
      Value<DateTime?> lockedAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ScanTasksTableUpdateCompanionBuilder =
    ScanTasksCompanion Function({
      Value<int> id,
      Value<int> jobId,
      Value<String> kind,
      Value<String> state,
      Value<int?> rootId,
      Value<String?> targetDriveId,
      Value<String?> dedupeKey,
      Value<String> payloadJson,
      Value<int> attempts,
      Value<int> priority,
      Value<DateTime?> lockedAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ScanTasksTableReferences
    extends BaseReferences<_$AppDatabase, $ScanTasksTable, ScanTask> {
  $$ScanTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScanJobsTable _jobIdTable(_$AppDatabase db) => db.scanJobs
      .createAlias($_aliasNameGenerator(db.scanTasks.jobId, db.scanJobs.id));

  $$ScanJobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$ScanJobsTableTableManager(
      $_db,
      $_db.scanJobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ScanTasksTable> {
  $$ScanTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDriveId => $composableBuilder(
    column: $table.targetDriveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

  $$ScanJobsTableFilterComposer get jobId {
    final $$ScanJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.scanJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanJobsTableFilterComposer(
            $db: $db,
            $table: $db.scanJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanTasksTable> {
  $$ScanTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDriveId => $composableBuilder(
    column: $table.targetDriveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

  $$ScanJobsTableOrderingComposer get jobId {
    final $$ScanJobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.scanJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanJobsTableOrderingComposer(
            $db: $db,
            $table: $db.scanJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanTasksTable> {
  $$ScanTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get targetDriveId => $composableBuilder(
    column: $table.targetDriveId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedAt =>
      $composableBuilder(column: $table.lockedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScanJobsTableAnnotationComposer get jobId {
    final $$ScanJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.scanJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanTasksTable,
          ScanTask,
          $$ScanTasksTableFilterComposer,
          $$ScanTasksTableOrderingComposer,
          $$ScanTasksTableAnnotationComposer,
          $$ScanTasksTableCreateCompanionBuilder,
          $$ScanTasksTableUpdateCompanionBuilder,
          (ScanTask, $$ScanTasksTableReferences),
          ScanTask,
          PrefetchHooks Function({bool jobId})
        > {
  $$ScanTasksTableTableManager(_$AppDatabase db, $ScanTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int?> rootId = const Value.absent(),
                Value<String?> targetDriveId = const Value.absent(),
                Value<String?> dedupeKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> lockedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScanTasksCompanion(
                id: id,
                jobId: jobId,
                kind: kind,
                state: state,
                rootId: rootId,
                targetDriveId: targetDriveId,
                dedupeKey: dedupeKey,
                payloadJson: payloadJson,
                attempts: attempts,
                priority: priority,
                lockedAt: lockedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required String kind,
                Value<String> state = const Value.absent(),
                Value<int?> rootId = const Value.absent(),
                Value<String?> targetDriveId = const Value.absent(),
                Value<String?> dedupeKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> lockedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScanTasksCompanion.insert(
                id: id,
                jobId: jobId,
                kind: kind,
                state: state,
                rootId: rootId,
                targetDriveId: targetDriveId,
                dedupeKey: dedupeKey,
                payloadJson: payloadJson,
                attempts: attempts,
                priority: priority,
                lockedAt: lockedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
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
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$ScanTasksTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$ScanTasksTableReferences
                                    ._jobIdTable(db)
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

typedef $$ScanTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanTasksTable,
      ScanTask,
      $$ScanTasksTableFilterComposer,
      $$ScanTasksTableOrderingComposer,
      $$ScanTasksTableAnnotationComposer,
      $$ScanTasksTableCreateCompanionBuilder,
      $$ScanTasksTableUpdateCompanionBuilder,
      (ScanTask, $$ScanTasksTableReferences),
      ScanTask,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$ArtworkBlobsTableCreateCompanionBuilder =
    ArtworkBlobsCompanion Function({
      Value<int> id,
      required String contentHash,
      required String mimeType,
      required String fileExtension,
      required String filePath,
      required int byteSize,
      Value<DateTime> createdAt,
    });
typedef $$ArtworkBlobsTableUpdateCompanionBuilder =
    ArtworkBlobsCompanion Function({
      Value<int> id,
      Value<String> contentHash,
      Value<String> mimeType,
      Value<String> fileExtension,
      Value<String> filePath,
      Value<int> byteSize,
      Value<DateTime> createdAt,
    });

class $$ArtworkBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $ArtworkBlobsTable> {
  $$ArtworkBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworkBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtworkBlobsTable> {
  $$ArtworkBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworkBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtworkBlobsTable> {
  $$ArtworkBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ArtworkBlobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtworkBlobsTable,
          ArtworkBlob,
          $$ArtworkBlobsTableFilterComposer,
          $$ArtworkBlobsTableOrderingComposer,
          $$ArtworkBlobsTableAnnotationComposer,
          $$ArtworkBlobsTableCreateCompanionBuilder,
          $$ArtworkBlobsTableUpdateCompanionBuilder,
          (
            ArtworkBlob,
            BaseReferences<_$AppDatabase, $ArtworkBlobsTable, ArtworkBlob>,
          ),
          ArtworkBlob,
          PrefetchHooks Function()
        > {
  $$ArtworkBlobsTableTableManager(_$AppDatabase db, $ArtworkBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworkBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworkBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworkBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String> fileExtension = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ArtworkBlobsCompanion(
                id: id,
                contentHash: contentHash,
                mimeType: mimeType,
                fileExtension: fileExtension,
                filePath: filePath,
                byteSize: byteSize,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentHash,
                required String mimeType,
                required String fileExtension,
                required String filePath,
                required int byteSize,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ArtworkBlobsCompanion.insert(
                id: id,
                contentHash: contentHash,
                mimeType: mimeType,
                fileExtension: fileExtension,
                filePath: filePath,
                byteSize: byteSize,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworkBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtworkBlobsTable,
      ArtworkBlob,
      $$ArtworkBlobsTableFilterComposer,
      $$ArtworkBlobsTableOrderingComposer,
      $$ArtworkBlobsTableAnnotationComposer,
      $$ArtworkBlobsTableCreateCompanionBuilder,
      $$ArtworkBlobsTableUpdateCompanionBuilder,
      (
        ArtworkBlob,
        BaseReferences<_$AppDatabase, $ArtworkBlobsTable, ArtworkBlob>,
      ),
      ArtworkBlob,
      PrefetchHooks Function()
    >;
typedef $$PlaybackStatesTableCreateCompanionBuilder =
    PlaybackStatesCompanion Function({
      Value<int> id,
      Value<String> queueTrackIdsJson,
      Value<int?> currentTrackId,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<DateTime> updatedAt,
    });
typedef $$PlaybackStatesTableUpdateCompanionBuilder =
    PlaybackStatesCompanion Function({
      Value<int> id,
      Value<String> queueTrackIdsJson,
      Value<int?> currentTrackId,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<DateTime> updatedAt,
    });

class $$PlaybackStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queueTrackIdsJson => $composableBuilder(
    column: $table.queueTrackIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentTrackId => $composableBuilder(
    column: $table.currentTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queueTrackIdsJson => $composableBuilder(
    column: $table.queueTrackIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentTrackId => $composableBuilder(
    column: $table.currentTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queueTrackIdsJson => $composableBuilder(
    column: $table.queueTrackIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentTrackId => $composableBuilder(
    column: $table.currentTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlaying =>
      $composableBuilder(column: $table.isPlaying, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackStatesTable,
          PlaybackState,
          $$PlaybackStatesTableFilterComposer,
          $$PlaybackStatesTableOrderingComposer,
          $$PlaybackStatesTableAnnotationComposer,
          $$PlaybackStatesTableCreateCompanionBuilder,
          $$PlaybackStatesTableUpdateCompanionBuilder,
          (
            PlaybackState,
            BaseReferences<_$AppDatabase, $PlaybackStatesTable, PlaybackState>,
          ),
          PlaybackState,
          PrefetchHooks Function()
        > {
  $$PlaybackStatesTableTableManager(
    _$AppDatabase db,
    $PlaybackStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> queueTrackIdsJson = const Value.absent(),
                Value<int?> currentTrackId = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlaybackStatesCompanion(
                id: id,
                queueTrackIdsJson: queueTrackIdsJson,
                currentTrackId: currentTrackId,
                currentIndex: currentIndex,
                positionMs: positionMs,
                isPlaying: isPlaying,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> queueTrackIdsJson = const Value.absent(),
                Value<int?> currentTrackId = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlaybackStatesCompanion.insert(
                id: id,
                queueTrackIdsJson: queueTrackIdsJson,
                currentTrackId: currentTrackId,
                currentIndex: currentIndex,
                positionMs: positionMs,
                isPlaying: isPlaying,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackStatesTable,
      PlaybackState,
      $$PlaybackStatesTableFilterComposer,
      $$PlaybackStatesTableOrderingComposer,
      $$PlaybackStatesTableAnnotationComposer,
      $$PlaybackStatesTableCreateCompanionBuilder,
      $$PlaybackStatesTableUpdateCompanionBuilder,
      (
        PlaybackState,
        BaseReferences<_$AppDatabase, $PlaybackStatesTable, PlaybackState>,
      ),
      PlaybackState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncAccountsTableTableManager get syncAccounts =>
      $$SyncAccountsTableTableManager(_db, _db.syncAccounts);
  $$SyncRootsTableTableManager get syncRoots =>
      $$SyncRootsTableTableManager(_db, _db.syncRoots);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$LibraryProjectionMetasTableTableManager get libraryProjectionMetas =>
      $$LibraryProjectionMetasTableTableManager(
        _db,
        _db.libraryProjectionMetas,
      );
  $$LibraryAlbumProjectionsTableTableManager get libraryAlbumProjections =>
      $$LibraryAlbumProjectionsTableTableManager(
        _db,
        _db.libraryAlbumProjections,
      );
  $$LibraryArtistProjectionsTableTableManager get libraryArtistProjections =>
      $$LibraryArtistProjectionsTableTableManager(
        _db,
        _db.libraryArtistProjections,
      );
  $$LibraryAlbumArtistProjectionsTableTableManager
  get libraryAlbumArtistProjections =>
      $$LibraryAlbumArtistProjectionsTableTableManager(
        _db,
        _db.libraryAlbumArtistProjections,
      );
  $$LibraryGenreProjectionsTableTableManager get libraryGenreProjections =>
      $$LibraryGenreProjectionsTableTableManager(
        _db,
        _db.libraryGenreProjections,
      );
  $$DriveObjectsTableTableManager get driveObjects =>
      $$DriveObjectsTableTableManager(_db, _db.driveObjects);
  $$ScanJobsTableTableManager get scanJobs =>
      $$ScanJobsTableTableManager(_db, _db.scanJobs);
  $$ScanTasksTableTableManager get scanTasks =>
      $$ScanTasksTableTableManager(_db, _db.scanTasks);
  $$ArtworkBlobsTableTableManager get artworkBlobs =>
      $$ArtworkBlobsTableTableManager(_db, _db.artworkBlobs);
  $$PlaybackStatesTableTableManager get playbackStates =>
      $$PlaybackStatesTableTableManager(_db, _db.playbackStates);
}
