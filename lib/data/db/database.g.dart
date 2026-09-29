// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DomainsTable extends Domains with TableInfo<$DomainsTable, DomainRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DomainsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SmtpSecurity, int> security =
      GeneratedColumn<int>(
        'security',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SmtpSecurity>($DomainsTable.$convertersecurity);
  @override
  late final GeneratedColumnWithTypeConverter<SmtpAuthMode, int> authMode =
      GeneratedColumn<int>(
        'auth_mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SmtpAuthMode>($DomainsTable.$converterauthMode);
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _credentialKeyIdMeta = const VerificationMeta(
    'credentialKeyId',
  );
  @override
  late final GeneratedColumn<String> credentialKeyId = GeneratedColumn<String>(
    'credential_key_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowInsecureCertificateMeta =
      const VerificationMeta('allowInsecureCertificate');
  @override
  late final GeneratedColumn<bool> allowInsecureCertificate =
      GeneratedColumn<bool>(
        'allow_insecure_certificate',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_insecure_certificate" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _timeoutSecondsMeta = const VerificationMeta(
    'timeoutSeconds',
  );
  @override
  late final GeneratedColumn<int> timeoutSeconds = GeneratedColumn<int>(
    'timeout_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _defaultLocalPartMeta = const VerificationMeta(
    'defaultLocalPart',
  );
  @override
  late final GeneratedColumn<String> defaultLocalPart = GeneratedColumn<String>(
    'default_local_part',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultDisplayNameMeta =
      const VerificationMeta('defaultDisplayName');
  @override
  late final GeneratedColumn<String> defaultDisplayName =
      GeneratedColumn<String>(
        'default_display_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultReplyToMeta = const VerificationMeta(
    'defaultReplyTo',
  );
  @override
  late final GeneratedColumn<String> defaultReplyTo = GeneratedColumn<String>(
    'default_reply_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    label,
    domain,
    host,
    port,
    security,
    authMode,
    username,
    credentialKeyId,
    allowInsecureCertificate,
    timeoutSeconds,
    defaultLocalPart,
    defaultDisplayName,
    defaultReplyTo,
    isDefault,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'domains';
  @override
  VerificationContext validateIntegrity(
    Insertable<DomainRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('credential_key_id')) {
      context.handle(
        _credentialKeyIdMeta,
        credentialKeyId.isAcceptableOrUnknown(
          data['credential_key_id']!,
          _credentialKeyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialKeyIdMeta);
    }
    if (data.containsKey('allow_insecure_certificate')) {
      context.handle(
        _allowInsecureCertificateMeta,
        allowInsecureCertificate.isAcceptableOrUnknown(
          data['allow_insecure_certificate']!,
          _allowInsecureCertificateMeta,
        ),
      );
    }
    if (data.containsKey('timeout_seconds')) {
      context.handle(
        _timeoutSecondsMeta,
        timeoutSeconds.isAcceptableOrUnknown(
          data['timeout_seconds']!,
          _timeoutSecondsMeta,
        ),
      );
    }
    if (data.containsKey('default_local_part')) {
      context.handle(
        _defaultLocalPartMeta,
        defaultLocalPart.isAcceptableOrUnknown(
          data['default_local_part']!,
          _defaultLocalPartMeta,
        ),
      );
    }
    if (data.containsKey('default_display_name')) {
      context.handle(
        _defaultDisplayNameMeta,
        defaultDisplayName.isAcceptableOrUnknown(
          data['default_display_name']!,
          _defaultDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('default_reply_to')) {
      context.handle(
        _defaultReplyToMeta,
        defaultReplyTo.isAcceptableOrUnknown(
          data['default_reply_to']!,
          _defaultReplyToMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  DomainRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DomainRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      security: $DomainsTable.$convertersecurity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}security'],
        )!,
      ),
      authMode: $DomainsTable.$converterauthMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}auth_mode'],
        )!,
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      credentialKeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_key_id'],
      )!,
      allowInsecureCertificate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_insecure_certificate'],
      )!,
      timeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeout_seconds'],
      )!,
      defaultLocalPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_local_part'],
      ),
      defaultDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_display_name'],
      ),
      defaultReplyTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_reply_to'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
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
  $DomainsTable createAlias(String alias) {
    return $DomainsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SmtpSecurity, int, int> $convertersecurity =
      const EnumIndexConverter<SmtpSecurity>(SmtpSecurity.values);
  static JsonTypeConverter2<SmtpAuthMode, int, int> $converterauthMode =
      const EnumIndexConverter<SmtpAuthMode>(SmtpAuthMode.values);
}

class DomainRow extends DataClass implements Insertable<DomainRow> {
  final int id;

  /// Friendly name shown in the composer's dropdown.
  final String label;

  /// The mail domain used to build From addresses, e.g. `example.com`.
  final String domain;
  final String host;
  final int port;

  /// Stored as the enum index — see the ordering warning in `enums.dart`.
  final SmtpSecurity security;
  final SmtpAuthMode authMode;
  final String username;

  /// Secure-storage key for the password. Never the password itself.
  final String credentialKeyId;
  final bool allowInsecureCertificate;
  final int timeoutSeconds;

  /// Prefilled into the composer when this domain is chosen; always editable.
  final String? defaultLocalPart;
  final String? defaultDisplayName;
  final String? defaultReplyTo;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DomainRow({
    required this.id,
    required this.label,
    required this.domain,
    required this.host,
    required this.port,
    required this.security,
    required this.authMode,
    required this.username,
    required this.credentialKeyId,
    required this.allowInsecureCertificate,
    required this.timeoutSeconds,
    this.defaultLocalPart,
    this.defaultDisplayName,
    this.defaultReplyTo,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['domain'] = Variable<String>(domain);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    {
      map['security'] = Variable<int>(
        $DomainsTable.$convertersecurity.toSql(security),
      );
    }
    {
      map['auth_mode'] = Variable<int>(
        $DomainsTable.$converterauthMode.toSql(authMode),
      );
    }
    map['username'] = Variable<String>(username);
    map['credential_key_id'] = Variable<String>(credentialKeyId);
    map['allow_insecure_certificate'] = Variable<bool>(
      allowInsecureCertificate,
    );
    map['timeout_seconds'] = Variable<int>(timeoutSeconds);
    if (!nullToAbsent || defaultLocalPart != null) {
      map['default_local_part'] = Variable<String>(defaultLocalPart);
    }
    if (!nullToAbsent || defaultDisplayName != null) {
      map['default_display_name'] = Variable<String>(defaultDisplayName);
    }
    if (!nullToAbsent || defaultReplyTo != null) {
      map['default_reply_to'] = Variable<String>(defaultReplyTo);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DomainsCompanion toCompanion(bool nullToAbsent) {
    return DomainsCompanion(
      id: Value(id),
      label: Value(label),
      domain: Value(domain),
      host: Value(host),
      port: Value(port),
      security: Value(security),
      authMode: Value(authMode),
      username: Value(username),
      credentialKeyId: Value(credentialKeyId),
      allowInsecureCertificate: Value(allowInsecureCertificate),
      timeoutSeconds: Value(timeoutSeconds),
      defaultLocalPart: defaultLocalPart == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultLocalPart),
      defaultDisplayName: defaultDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultDisplayName),
      defaultReplyTo: defaultReplyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultReplyTo),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DomainRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DomainRow(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      domain: serializer.fromJson<String>(json['domain']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      security: $DomainsTable.$convertersecurity.fromJson(
        serializer.fromJson<int>(json['security']),
      ),
      authMode: $DomainsTable.$converterauthMode.fromJson(
        serializer.fromJson<int>(json['authMode']),
      ),
      username: serializer.fromJson<String>(json['username']),
      credentialKeyId: serializer.fromJson<String>(json['credentialKeyId']),
      allowInsecureCertificate: serializer.fromJson<bool>(
        json['allowInsecureCertificate'],
      ),
      timeoutSeconds: serializer.fromJson<int>(json['timeoutSeconds']),
      defaultLocalPart: serializer.fromJson<String?>(json['defaultLocalPart']),
      defaultDisplayName: serializer.fromJson<String?>(
        json['defaultDisplayName'],
      ),
      defaultReplyTo: serializer.fromJson<String?>(json['defaultReplyTo']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'domain': serializer.toJson<String>(domain),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'security': serializer.toJson<int>(
        $DomainsTable.$convertersecurity.toJson(security),
      ),
      'authMode': serializer.toJson<int>(
        $DomainsTable.$converterauthMode.toJson(authMode),
      ),
      'username': serializer.toJson<String>(username),
      'credentialKeyId': serializer.toJson<String>(credentialKeyId),
      'allowInsecureCertificate': serializer.toJson<bool>(
        allowInsecureCertificate,
      ),
      'timeoutSeconds': serializer.toJson<int>(timeoutSeconds),
      'defaultLocalPart': serializer.toJson<String?>(defaultLocalPart),
      'defaultDisplayName': serializer.toJson<String?>(defaultDisplayName),
      'defaultReplyTo': serializer.toJson<String?>(defaultReplyTo),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DomainRow copyWith({
    int? id,
    String? label,
    String? domain,
    String? host,
    int? port,
    SmtpSecurity? security,
    SmtpAuthMode? authMode,
    String? username,
    String? credentialKeyId,
    bool? allowInsecureCertificate,
    int? timeoutSeconds,
    Value<String?> defaultLocalPart = const Value.absent(),
    Value<String?> defaultDisplayName = const Value.absent(),
    Value<String?> defaultReplyTo = const Value.absent(),
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DomainRow(
    id: id ?? this.id,
    label: label ?? this.label,
    domain: domain ?? this.domain,
    host: host ?? this.host,
    port: port ?? this.port,
    security: security ?? this.security,
    authMode: authMode ?? this.authMode,
    username: username ?? this.username,
    credentialKeyId: credentialKeyId ?? this.credentialKeyId,
    allowInsecureCertificate:
        allowInsecureCertificate ?? this.allowInsecureCertificate,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    defaultLocalPart: defaultLocalPart.present
        ? defaultLocalPart.value
        : this.defaultLocalPart,
    defaultDisplayName: defaultDisplayName.present
        ? defaultDisplayName.value
        : this.defaultDisplayName,
    defaultReplyTo: defaultReplyTo.present
        ? defaultReplyTo.value
        : this.defaultReplyTo,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DomainRow copyWithCompanion(DomainsCompanion data) {
    return DomainRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      domain: data.domain.present ? data.domain.value : this.domain,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      security: data.security.present ? data.security.value : this.security,
      authMode: data.authMode.present ? data.authMode.value : this.authMode,
      username: data.username.present ? data.username.value : this.username,
      credentialKeyId: data.credentialKeyId.present
          ? data.credentialKeyId.value
          : this.credentialKeyId,
      allowInsecureCertificate: data.allowInsecureCertificate.present
          ? data.allowInsecureCertificate.value
          : this.allowInsecureCertificate,
      timeoutSeconds: data.timeoutSeconds.present
          ? data.timeoutSeconds.value
          : this.timeoutSeconds,
      defaultLocalPart: data.defaultLocalPart.present
          ? data.defaultLocalPart.value
          : this.defaultLocalPart,
      defaultDisplayName: data.defaultDisplayName.present
          ? data.defaultDisplayName.value
          : this.defaultDisplayName,
      defaultReplyTo: data.defaultReplyTo.present
          ? data.defaultReplyTo.value
          : this.defaultReplyTo,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DomainRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('domain: $domain, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('security: $security, ')
          ..write('authMode: $authMode, ')
          ..write('username: $username, ')
          ..write('credentialKeyId: $credentialKeyId, ')
          ..write('allowInsecureCertificate: $allowInsecureCertificate, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('defaultLocalPart: $defaultLocalPart, ')
          ..write('defaultDisplayName: $defaultDisplayName, ')
          ..write('defaultReplyTo: $defaultReplyTo, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    domain,
    host,
    port,
    security,
    authMode,
    username,
    credentialKeyId,
    allowInsecureCertificate,
    timeoutSeconds,
    defaultLocalPart,
    defaultDisplayName,
    defaultReplyTo,
    isDefault,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DomainRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.domain == this.domain &&
          other.host == this.host &&
          other.port == this.port &&
          other.security == this.security &&
          other.authMode == this.authMode &&
          other.username == this.username &&
          other.credentialKeyId == this.credentialKeyId &&
          other.allowInsecureCertificate == this.allowInsecureCertificate &&
          other.timeoutSeconds == this.timeoutSeconds &&
          other.defaultLocalPart == this.defaultLocalPart &&
          other.defaultDisplayName == this.defaultDisplayName &&
          other.defaultReplyTo == this.defaultReplyTo &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DomainsCompanion extends UpdateCompanion<DomainRow> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> domain;
  final Value<String> host;
  final Value<int> port;
  final Value<SmtpSecurity> security;
  final Value<SmtpAuthMode> authMode;
  final Value<String> username;
  final Value<String> credentialKeyId;
  final Value<bool> allowInsecureCertificate;
  final Value<int> timeoutSeconds;
  final Value<String?> defaultLocalPart;
  final Value<String?> defaultDisplayName;
  final Value<String?> defaultReplyTo;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DomainsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.domain = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.security = const Value.absent(),
    this.authMode = const Value.absent(),
    this.username = const Value.absent(),
    this.credentialKeyId = const Value.absent(),
    this.allowInsecureCertificate = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    this.defaultLocalPart = const Value.absent(),
    this.defaultDisplayName = const Value.absent(),
    this.defaultReplyTo = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DomainsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String domain,
    required String host,
    required int port,
    required SmtpSecurity security,
    required SmtpAuthMode authMode,
    this.username = const Value.absent(),
    required String credentialKeyId,
    this.allowInsecureCertificate = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    this.defaultLocalPart = const Value.absent(),
    this.defaultDisplayName = const Value.absent(),
    this.defaultReplyTo = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : label = Value(label),
       domain = Value(domain),
       host = Value(host),
       port = Value(port),
       security = Value(security),
       authMode = Value(authMode),
       credentialKeyId = Value(credentialKeyId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DomainRow> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? domain,
    Expression<String>? host,
    Expression<int>? port,
    Expression<int>? security,
    Expression<int>? authMode,
    Expression<String>? username,
    Expression<String>? credentialKeyId,
    Expression<bool>? allowInsecureCertificate,
    Expression<int>? timeoutSeconds,
    Expression<String>? defaultLocalPart,
    Expression<String>? defaultDisplayName,
    Expression<String>? defaultReplyTo,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (domain != null) 'domain': domain,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (security != null) 'security': security,
      if (authMode != null) 'auth_mode': authMode,
      if (username != null) 'username': username,
      if (credentialKeyId != null) 'credential_key_id': credentialKeyId,
      if (allowInsecureCertificate != null)
        'allow_insecure_certificate': allowInsecureCertificate,
      if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
      if (defaultLocalPart != null) 'default_local_part': defaultLocalPart,
      if (defaultDisplayName != null)
        'default_display_name': defaultDisplayName,
      if (defaultReplyTo != null) 'default_reply_to': defaultReplyTo,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DomainsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? domain,
    Value<String>? host,
    Value<int>? port,
    Value<SmtpSecurity>? security,
    Value<SmtpAuthMode>? authMode,
    Value<String>? username,
    Value<String>? credentialKeyId,
    Value<bool>? allowInsecureCertificate,
    Value<int>? timeoutSeconds,
    Value<String?>? defaultLocalPart,
    Value<String?>? defaultDisplayName,
    Value<String?>? defaultReplyTo,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DomainsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      domain: domain ?? this.domain,
      host: host ?? this.host,
      port: port ?? this.port,
      security: security ?? this.security,
      authMode: authMode ?? this.authMode,
      username: username ?? this.username,
      credentialKeyId: credentialKeyId ?? this.credentialKeyId,
      allowInsecureCertificate:
          allowInsecureCertificate ?? this.allowInsecureCertificate,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      defaultLocalPart: defaultLocalPart ?? this.defaultLocalPart,
      defaultDisplayName: defaultDisplayName ?? this.defaultDisplayName,
      defaultReplyTo: defaultReplyTo ?? this.defaultReplyTo,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (security.present) {
      map['security'] = Variable<int>(
        $DomainsTable.$convertersecurity.toSql(security.value),
      );
    }
    if (authMode.present) {
      map['auth_mode'] = Variable<int>(
        $DomainsTable.$converterauthMode.toSql(authMode.value),
      );
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (credentialKeyId.present) {
      map['credential_key_id'] = Variable<String>(credentialKeyId.value);
    }
    if (allowInsecureCertificate.present) {
      map['allow_insecure_certificate'] = Variable<bool>(
        allowInsecureCertificate.value,
      );
    }
    if (timeoutSeconds.present) {
      map['timeout_seconds'] = Variable<int>(timeoutSeconds.value);
    }
    if (defaultLocalPart.present) {
      map['default_local_part'] = Variable<String>(defaultLocalPart.value);
    }
    if (defaultDisplayName.present) {
      map['default_display_name'] = Variable<String>(defaultDisplayName.value);
    }
    if (defaultReplyTo.present) {
      map['default_reply_to'] = Variable<String>(defaultReplyTo.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('DomainsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('domain: $domain, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('security: $security, ')
          ..write('authMode: $authMode, ')
          ..write('username: $username, ')
          ..write('credentialKeyId: $credentialKeyId, ')
          ..write('allowInsecureCertificate: $allowInsecureCertificate, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('defaultLocalPart: $defaultLocalPart, ')
          ..write('defaultDisplayName: $defaultDisplayName, ')
          ..write('defaultReplyTo: $defaultReplyTo, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IdentityPresetsTable extends IdentityPresets
    with TableInfo<$IdentityPresetsTable, IdentityPresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentityPresetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _domainIdMeta = const VerificationMeta(
    'domainId',
  );
  @override
  late final GeneratedColumn<int> domainId = GeneratedColumn<int>(
    'domain_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES domains (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPartMeta = const VerificationMeta(
    'localPart',
  );
  @override
  late final GeneratedColumn<String> localPart = GeneratedColumn<String>(
    'local_part',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _replyToMeta = const VerificationMeta(
    'replyTo',
  );
  @override
  late final GeneratedColumn<String> replyTo = GeneratedColumn<String>(
    'reply_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    domainId,
    name,
    localPart,
    displayName,
    replyTo,
    signature,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityPresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('domain_id')) {
      context.handle(
        _domainIdMeta,
        domainId.isAcceptableOrUnknown(data['domain_id']!, _domainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_domainIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('local_part')) {
      context.handle(
        _localPartMeta,
        localPart.isAcceptableOrUnknown(data['local_part']!, _localPartMeta),
      );
    } else if (isInserting) {
      context.missing(_localPartMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('reply_to')) {
      context.handle(
        _replyToMeta,
        replyTo.isAcceptableOrUnknown(data['reply_to']!, _replyToMeta),
      );
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdentityPresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityPresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      domainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}domain_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      localPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_part'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      replyTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to'],
      ),
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $IdentityPresetsTable createAlias(String alias) {
    return $IdentityPresetsTable(attachedDatabase, alias);
  }
}

class IdentityPresetRow extends DataClass
    implements Insertable<IdentityPresetRow> {
  final int id;
  final int domainId;
  final String name;
  final String localPart;
  final String displayName;
  final String? replyTo;

  /// Overrides the global default signature when set.
  final String? signature;
  final int sortOrder;
  const IdentityPresetRow({
    required this.id,
    required this.domainId,
    required this.name,
    required this.localPart,
    required this.displayName,
    this.replyTo,
    this.signature,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['domain_id'] = Variable<int>(domainId);
    map['name'] = Variable<String>(name);
    map['local_part'] = Variable<String>(localPart);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || replyTo != null) {
      map['reply_to'] = Variable<String>(replyTo);
    }
    if (!nullToAbsent || signature != null) {
      map['signature'] = Variable<String>(signature);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  IdentityPresetsCompanion toCompanion(bool nullToAbsent) {
    return IdentityPresetsCompanion(
      id: Value(id),
      domainId: Value(domainId),
      name: Value(name),
      localPart: Value(localPart),
      displayName: Value(displayName),
      replyTo: replyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(replyTo),
      signature: signature == null && nullToAbsent
          ? const Value.absent()
          : Value(signature),
      sortOrder: Value(sortOrder),
    );
  }

  factory IdentityPresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityPresetRow(
      id: serializer.fromJson<int>(json['id']),
      domainId: serializer.fromJson<int>(json['domainId']),
      name: serializer.fromJson<String>(json['name']),
      localPart: serializer.fromJson<String>(json['localPart']),
      displayName: serializer.fromJson<String>(json['displayName']),
      replyTo: serializer.fromJson<String?>(json['replyTo']),
      signature: serializer.fromJson<String?>(json['signature']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'domainId': serializer.toJson<int>(domainId),
      'name': serializer.toJson<String>(name),
      'localPart': serializer.toJson<String>(localPart),
      'displayName': serializer.toJson<String>(displayName),
      'replyTo': serializer.toJson<String?>(replyTo),
      'signature': serializer.toJson<String?>(signature),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  IdentityPresetRow copyWith({
    int? id,
    int? domainId,
    String? name,
    String? localPart,
    String? displayName,
    Value<String?> replyTo = const Value.absent(),
    Value<String?> signature = const Value.absent(),
    int? sortOrder,
  }) => IdentityPresetRow(
    id: id ?? this.id,
    domainId: domainId ?? this.domainId,
    name: name ?? this.name,
    localPart: localPart ?? this.localPart,
    displayName: displayName ?? this.displayName,
    replyTo: replyTo.present ? replyTo.value : this.replyTo,
    signature: signature.present ? signature.value : this.signature,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  IdentityPresetRow copyWithCompanion(IdentityPresetsCompanion data) {
    return IdentityPresetRow(
      id: data.id.present ? data.id.value : this.id,
      domainId: data.domainId.present ? data.domainId.value : this.domainId,
      name: data.name.present ? data.name.value : this.name,
      localPart: data.localPart.present ? data.localPart.value : this.localPart,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      replyTo: data.replyTo.present ? data.replyTo.value : this.replyTo,
      signature: data.signature.present ? data.signature.value : this.signature,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityPresetRow(')
          ..write('id: $id, ')
          ..write('domainId: $domainId, ')
          ..write('name: $name, ')
          ..write('localPart: $localPart, ')
          ..write('displayName: $displayName, ')
          ..write('replyTo: $replyTo, ')
          ..write('signature: $signature, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    domainId,
    name,
    localPart,
    displayName,
    replyTo,
    signature,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityPresetRow &&
          other.id == this.id &&
          other.domainId == this.domainId &&
          other.name == this.name &&
          other.localPart == this.localPart &&
          other.displayName == this.displayName &&
          other.replyTo == this.replyTo &&
          other.signature == this.signature &&
          other.sortOrder == this.sortOrder);
}

class IdentityPresetsCompanion extends UpdateCompanion<IdentityPresetRow> {
  final Value<int> id;
  final Value<int> domainId;
  final Value<String> name;
  final Value<String> localPart;
  final Value<String> displayName;
  final Value<String?> replyTo;
  final Value<String?> signature;
  final Value<int> sortOrder;
  const IdentityPresetsCompanion({
    this.id = const Value.absent(),
    this.domainId = const Value.absent(),
    this.name = const Value.absent(),
    this.localPart = const Value.absent(),
    this.displayName = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.signature = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  IdentityPresetsCompanion.insert({
    this.id = const Value.absent(),
    required int domainId,
    required String name,
    required String localPart,
    this.displayName = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.signature = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : domainId = Value(domainId),
       name = Value(name),
       localPart = Value(localPart);
  static Insertable<IdentityPresetRow> custom({
    Expression<int>? id,
    Expression<int>? domainId,
    Expression<String>? name,
    Expression<String>? localPart,
    Expression<String>? displayName,
    Expression<String>? replyTo,
    Expression<String>? signature,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (domainId != null) 'domain_id': domainId,
      if (name != null) 'name': name,
      if (localPart != null) 'local_part': localPart,
      if (displayName != null) 'display_name': displayName,
      if (replyTo != null) 'reply_to': replyTo,
      if (signature != null) 'signature': signature,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  IdentityPresetsCompanion copyWith({
    Value<int>? id,
    Value<int>? domainId,
    Value<String>? name,
    Value<String>? localPart,
    Value<String>? displayName,
    Value<String?>? replyTo,
    Value<String?>? signature,
    Value<int>? sortOrder,
  }) {
    return IdentityPresetsCompanion(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      name: name ?? this.name,
      localPart: localPart ?? this.localPart,
      displayName: displayName ?? this.displayName,
      replyTo: replyTo ?? this.replyTo,
      signature: signature ?? this.signature,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (domainId.present) {
      map['domain_id'] = Variable<int>(domainId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (localPart.present) {
      map['local_part'] = Variable<String>(localPart.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (replyTo.present) {
      map['reply_to'] = Variable<String>(replyTo.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityPresetsCompanion(')
          ..write('id: $id, ')
          ..write('domainId: $domainId, ')
          ..write('name: $name, ')
          ..write('localPart: $localPart, ')
          ..write('displayName: $displayName, ')
          ..write('replyTo: $replyTo, ')
          ..write('signature: $signature, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<MessageStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MessageStatus>($MessagesTable.$converterstatus);
  static const VerificationMeta _domainIdMeta = const VerificationMeta(
    'domainId',
  );
  @override
  late final GeneratedColumn<int> domainId = GeneratedColumn<int>(
    'domain_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES domains (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _domainSnapshotMeta = const VerificationMeta(
    'domainSnapshot',
  );
  @override
  late final GeneratedColumn<String> domainSnapshot = GeneratedColumn<String>(
    'domain_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hostSnapshotMeta = const VerificationMeta(
    'hostSnapshot',
  );
  @override
  late final GeneratedColumn<String> hostSnapshot = GeneratedColumn<String>(
    'host_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _domainLabelSnapshotMeta =
      const VerificationMeta('domainLabelSnapshot');
  @override
  late final GeneratedColumn<String> domainLabelSnapshot =
      GeneratedColumn<String>(
        'domain_label_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _localPartMeta = const VerificationMeta(
    'localPart',
  );
  @override
  late final GeneratedColumn<String> localPart = GeneratedColumn<String>(
    'local_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _replyToMeta = const VerificationMeta(
    'replyTo',
  );
  @override
  late final GeneratedColumn<String> replyTo = GeneratedColumn<String>(
    'reply_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toAddressesMeta = const VerificationMeta(
    'toAddresses',
  );
  @override
  late final GeneratedColumn<String> toAddresses = GeneratedColumn<String>(
    'to_addresses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _ccAddressesMeta = const VerificationMeta(
    'ccAddresses',
  );
  @override
  late final GeneratedColumn<String> ccAddresses = GeneratedColumn<String>(
    'cc_addresses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _bccAddressesMeta = const VerificationMeta(
    'bccAddresses',
  );
  @override
  late final GeneratedColumn<String> bccAddresses = GeneratedColumn<String>(
    'bcc_addresses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyHtmlMeta = const VerificationMeta(
    'bodyHtml',
  );
  @override
  late final GeneratedColumn<String> bodyHtml = GeneratedColumn<String>(
    'body_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyPlainMeta = const VerificationMeta(
    'bodyPlain',
  );
  @override
  late final GeneratedColumn<String> bodyPlain = GeneratedColumn<String>(
    'body_plain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyDeltaJsonMeta = const VerificationMeta(
    'bodyDeltaJson',
  );
  @override
  late final GeneratedColumn<String> bodyDeltaJson = GeneratedColumn<String>(
    'body_delta_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHtmlMeta = const VerificationMeta('isHtml');
  @override
  late final GeneratedColumn<bool> isHtml = GeneratedColumn<bool>(
    'is_html',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_html" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _customHeadersMeta = const VerificationMeta(
    'customHeaders',
  );
  @override
  late final GeneratedColumn<String> customHeaders = GeneratedColumn<String>(
    'custom_headers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
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
  static const VerificationMeta _lastResponseLineMeta = const VerificationMeta(
    'lastResponseLine',
  );
  @override
  late final GeneratedColumn<String> lastResponseLine = GeneratedColumn<String>(
    'last_response_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    domainId,
    domainSnapshot,
    hostSnapshot,
    domainLabelSnapshot,
    localPart,
    displayName,
    replyTo,
    toAddresses,
    ccAddresses,
    bccAddresses,
    subject,
    bodyHtml,
    bodyPlain,
    bodyDeltaJson,
    isHtml,
    customHeaders,
    createdAt,
    updatedAt,
    sentAt,
    lastError,
    lastResponseLine,
    retryCount,
    nextRetryAt,
    messageId,
    transcript,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('domain_id')) {
      context.handle(
        _domainIdMeta,
        domainId.isAcceptableOrUnknown(data['domain_id']!, _domainIdMeta),
      );
    }
    if (data.containsKey('domain_snapshot')) {
      context.handle(
        _domainSnapshotMeta,
        domainSnapshot.isAcceptableOrUnknown(
          data['domain_snapshot']!,
          _domainSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('host_snapshot')) {
      context.handle(
        _hostSnapshotMeta,
        hostSnapshot.isAcceptableOrUnknown(
          data['host_snapshot']!,
          _hostSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('domain_label_snapshot')) {
      context.handle(
        _domainLabelSnapshotMeta,
        domainLabelSnapshot.isAcceptableOrUnknown(
          data['domain_label_snapshot']!,
          _domainLabelSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('local_part')) {
      context.handle(
        _localPartMeta,
        localPart.isAcceptableOrUnknown(data['local_part']!, _localPartMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('reply_to')) {
      context.handle(
        _replyToMeta,
        replyTo.isAcceptableOrUnknown(data['reply_to']!, _replyToMeta),
      );
    }
    if (data.containsKey('to_addresses')) {
      context.handle(
        _toAddressesMeta,
        toAddresses.isAcceptableOrUnknown(
          data['to_addresses']!,
          _toAddressesMeta,
        ),
      );
    }
    if (data.containsKey('cc_addresses')) {
      context.handle(
        _ccAddressesMeta,
        ccAddresses.isAcceptableOrUnknown(
          data['cc_addresses']!,
          _ccAddressesMeta,
        ),
      );
    }
    if (data.containsKey('bcc_addresses')) {
      context.handle(
        _bccAddressesMeta,
        bccAddresses.isAcceptableOrUnknown(
          data['bcc_addresses']!,
          _bccAddressesMeta,
        ),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('body_html')) {
      context.handle(
        _bodyHtmlMeta,
        bodyHtml.isAcceptableOrUnknown(data['body_html']!, _bodyHtmlMeta),
      );
    }
    if (data.containsKey('body_plain')) {
      context.handle(
        _bodyPlainMeta,
        bodyPlain.isAcceptableOrUnknown(data['body_plain']!, _bodyPlainMeta),
      );
    }
    if (data.containsKey('body_delta_json')) {
      context.handle(
        _bodyDeltaJsonMeta,
        bodyDeltaJson.isAcceptableOrUnknown(
          data['body_delta_json']!,
          _bodyDeltaJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_html')) {
      context.handle(
        _isHtmlMeta,
        isHtml.isAcceptableOrUnknown(data['is_html']!, _isHtmlMeta),
      );
    }
    if (data.containsKey('custom_headers')) {
      context.handle(
        _customHeadersMeta,
        customHeaders.isAcceptableOrUnknown(
          data['custom_headers']!,
          _customHeadersMeta,
        ),
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
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('last_response_line')) {
      context.handle(
        _lastResponseLineMeta,
        lastResponseLine.isAcceptableOrUnknown(
          data['last_response_line']!,
          _lastResponseLineMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: $MessagesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      domainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}domain_id'],
      ),
      domainSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_snapshot'],
      )!,
      hostSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_snapshot'],
      )!,
      domainLabelSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_label_snapshot'],
      )!,
      localPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_part'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      replyTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to'],
      ),
      toAddresses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_addresses'],
      )!,
      ccAddresses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cc_addresses'],
      )!,
      bccAddresses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bcc_addresses'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      bodyHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_html'],
      ),
      bodyPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_plain'],
      )!,
      bodyDeltaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_delta_json'],
      ),
      isHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_html'],
      )!,
      customHeaders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_headers'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      lastResponseLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_response_line'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageStatus, int, int> $converterstatus =
      const EnumIndexConverter<MessageStatus>(MessageStatus.values);
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final int id;
  final MessageStatus status;

  /// Nulled rather than cascaded when a domain is deleted, so sent history
  /// survives. The `*Snapshot` columns keep it readable afterwards.
  final int? domainId;
  final String domainSnapshot;
  final String hostSnapshot;
  final String domainLabelSnapshot;
  final String localPart;
  final String displayName;
  final String? replyTo;

  /// JSON arrays of addresses.
  final String toAddresses;
  final String ccAddresses;
  final String bccAddresses;
  final String subject;
  final String? bodyHtml;
  final String bodyPlain;

  /// Quill document, so a draft reopens in the rich editor without loss.
  final String? bodyDeltaJson;
  final bool isHtml;

  /// JSON object of user-supplied headers.
  final String customHeaders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? sentAt;

  /// Our summary of the last failure.
  final String? lastError;

  /// The server's own words, stored verbatim.
  final String? lastResponseLine;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? messageId;

  /// Redacted SMTP dialogue from the last attempt.
  final String? transcript;
  const MessageRow({
    required this.id,
    required this.status,
    this.domainId,
    required this.domainSnapshot,
    required this.hostSnapshot,
    required this.domainLabelSnapshot,
    required this.localPart,
    required this.displayName,
    this.replyTo,
    required this.toAddresses,
    required this.ccAddresses,
    required this.bccAddresses,
    required this.subject,
    this.bodyHtml,
    required this.bodyPlain,
    this.bodyDeltaJson,
    required this.isHtml,
    required this.customHeaders,
    required this.createdAt,
    required this.updatedAt,
    this.sentAt,
    this.lastError,
    this.lastResponseLine,
    required this.retryCount,
    this.nextRetryAt,
    this.messageId,
    this.transcript,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['status'] = Variable<int>(
        $MessagesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || domainId != null) {
      map['domain_id'] = Variable<int>(domainId);
    }
    map['domain_snapshot'] = Variable<String>(domainSnapshot);
    map['host_snapshot'] = Variable<String>(hostSnapshot);
    map['domain_label_snapshot'] = Variable<String>(domainLabelSnapshot);
    map['local_part'] = Variable<String>(localPart);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || replyTo != null) {
      map['reply_to'] = Variable<String>(replyTo);
    }
    map['to_addresses'] = Variable<String>(toAddresses);
    map['cc_addresses'] = Variable<String>(ccAddresses);
    map['bcc_addresses'] = Variable<String>(bccAddresses);
    map['subject'] = Variable<String>(subject);
    if (!nullToAbsent || bodyHtml != null) {
      map['body_html'] = Variable<String>(bodyHtml);
    }
    map['body_plain'] = Variable<String>(bodyPlain);
    if (!nullToAbsent || bodyDeltaJson != null) {
      map['body_delta_json'] = Variable<String>(bodyDeltaJson);
    }
    map['is_html'] = Variable<bool>(isHtml);
    map['custom_headers'] = Variable<String>(customHeaders);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || lastResponseLine != null) {
      map['last_response_line'] = Variable<String>(lastResponseLine);
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      status: Value(status),
      domainId: domainId == null && nullToAbsent
          ? const Value.absent()
          : Value(domainId),
      domainSnapshot: Value(domainSnapshot),
      hostSnapshot: Value(hostSnapshot),
      domainLabelSnapshot: Value(domainLabelSnapshot),
      localPart: Value(localPart),
      displayName: Value(displayName),
      replyTo: replyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(replyTo),
      toAddresses: Value(toAddresses),
      ccAddresses: Value(ccAddresses),
      bccAddresses: Value(bccAddresses),
      subject: Value(subject),
      bodyHtml: bodyHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyHtml),
      bodyPlain: Value(bodyPlain),
      bodyDeltaJson: bodyDeltaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyDeltaJson),
      isHtml: Value(isHtml),
      customHeaders: Value(customHeaders),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      lastResponseLine: lastResponseLine == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResponseLine),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<int>(json['id']),
      status: $MessagesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      domainId: serializer.fromJson<int?>(json['domainId']),
      domainSnapshot: serializer.fromJson<String>(json['domainSnapshot']),
      hostSnapshot: serializer.fromJson<String>(json['hostSnapshot']),
      domainLabelSnapshot: serializer.fromJson<String>(
        json['domainLabelSnapshot'],
      ),
      localPart: serializer.fromJson<String>(json['localPart']),
      displayName: serializer.fromJson<String>(json['displayName']),
      replyTo: serializer.fromJson<String?>(json['replyTo']),
      toAddresses: serializer.fromJson<String>(json['toAddresses']),
      ccAddresses: serializer.fromJson<String>(json['ccAddresses']),
      bccAddresses: serializer.fromJson<String>(json['bccAddresses']),
      subject: serializer.fromJson<String>(json['subject']),
      bodyHtml: serializer.fromJson<String?>(json['bodyHtml']),
      bodyPlain: serializer.fromJson<String>(json['bodyPlain']),
      bodyDeltaJson: serializer.fromJson<String?>(json['bodyDeltaJson']),
      isHtml: serializer.fromJson<bool>(json['isHtml']),
      customHeaders: serializer.fromJson<String>(json['customHeaders']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastResponseLine: serializer.fromJson<String?>(json['lastResponseLine']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      messageId: serializer.fromJson<String?>(json['messageId']),
      transcript: serializer.fromJson<String?>(json['transcript']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<int>(
        $MessagesTable.$converterstatus.toJson(status),
      ),
      'domainId': serializer.toJson<int?>(domainId),
      'domainSnapshot': serializer.toJson<String>(domainSnapshot),
      'hostSnapshot': serializer.toJson<String>(hostSnapshot),
      'domainLabelSnapshot': serializer.toJson<String>(domainLabelSnapshot),
      'localPart': serializer.toJson<String>(localPart),
      'displayName': serializer.toJson<String>(displayName),
      'replyTo': serializer.toJson<String?>(replyTo),
      'toAddresses': serializer.toJson<String>(toAddresses),
      'ccAddresses': serializer.toJson<String>(ccAddresses),
      'bccAddresses': serializer.toJson<String>(bccAddresses),
      'subject': serializer.toJson<String>(subject),
      'bodyHtml': serializer.toJson<String?>(bodyHtml),
      'bodyPlain': serializer.toJson<String>(bodyPlain),
      'bodyDeltaJson': serializer.toJson<String?>(bodyDeltaJson),
      'isHtml': serializer.toJson<bool>(isHtml),
      'customHeaders': serializer.toJson<String>(customHeaders),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'lastError': serializer.toJson<String?>(lastError),
      'lastResponseLine': serializer.toJson<String?>(lastResponseLine),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'messageId': serializer.toJson<String?>(messageId),
      'transcript': serializer.toJson<String?>(transcript),
    };
  }

  MessageRow copyWith({
    int? id,
    MessageStatus? status,
    Value<int?> domainId = const Value.absent(),
    String? domainSnapshot,
    String? hostSnapshot,
    String? domainLabelSnapshot,
    String? localPart,
    String? displayName,
    Value<String?> replyTo = const Value.absent(),
    String? toAddresses,
    String? ccAddresses,
    String? bccAddresses,
    String? subject,
    Value<String?> bodyHtml = const Value.absent(),
    String? bodyPlain,
    Value<String?> bodyDeltaJson = const Value.absent(),
    bool? isHtml,
    String? customHeaders,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> sentAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<String?> lastResponseLine = const Value.absent(),
    int? retryCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> messageId = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
  }) => MessageRow(
    id: id ?? this.id,
    status: status ?? this.status,
    domainId: domainId.present ? domainId.value : this.domainId,
    domainSnapshot: domainSnapshot ?? this.domainSnapshot,
    hostSnapshot: hostSnapshot ?? this.hostSnapshot,
    domainLabelSnapshot: domainLabelSnapshot ?? this.domainLabelSnapshot,
    localPart: localPart ?? this.localPart,
    displayName: displayName ?? this.displayName,
    replyTo: replyTo.present ? replyTo.value : this.replyTo,
    toAddresses: toAddresses ?? this.toAddresses,
    ccAddresses: ccAddresses ?? this.ccAddresses,
    bccAddresses: bccAddresses ?? this.bccAddresses,
    subject: subject ?? this.subject,
    bodyHtml: bodyHtml.present ? bodyHtml.value : this.bodyHtml,
    bodyPlain: bodyPlain ?? this.bodyPlain,
    bodyDeltaJson: bodyDeltaJson.present
        ? bodyDeltaJson.value
        : this.bodyDeltaJson,
    isHtml: isHtml ?? this.isHtml,
    customHeaders: customHeaders ?? this.customHeaders,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    lastResponseLine: lastResponseLine.present
        ? lastResponseLine.value
        : this.lastResponseLine,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    messageId: messageId.present ? messageId.value : this.messageId,
    transcript: transcript.present ? transcript.value : this.transcript,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      domainId: data.domainId.present ? data.domainId.value : this.domainId,
      domainSnapshot: data.domainSnapshot.present
          ? data.domainSnapshot.value
          : this.domainSnapshot,
      hostSnapshot: data.hostSnapshot.present
          ? data.hostSnapshot.value
          : this.hostSnapshot,
      domainLabelSnapshot: data.domainLabelSnapshot.present
          ? data.domainLabelSnapshot.value
          : this.domainLabelSnapshot,
      localPart: data.localPart.present ? data.localPart.value : this.localPart,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      replyTo: data.replyTo.present ? data.replyTo.value : this.replyTo,
      toAddresses: data.toAddresses.present
          ? data.toAddresses.value
          : this.toAddresses,
      ccAddresses: data.ccAddresses.present
          ? data.ccAddresses.value
          : this.ccAddresses,
      bccAddresses: data.bccAddresses.present
          ? data.bccAddresses.value
          : this.bccAddresses,
      subject: data.subject.present ? data.subject.value : this.subject,
      bodyHtml: data.bodyHtml.present ? data.bodyHtml.value : this.bodyHtml,
      bodyPlain: data.bodyPlain.present ? data.bodyPlain.value : this.bodyPlain,
      bodyDeltaJson: data.bodyDeltaJson.present
          ? data.bodyDeltaJson.value
          : this.bodyDeltaJson,
      isHtml: data.isHtml.present ? data.isHtml.value : this.isHtml,
      customHeaders: data.customHeaders.present
          ? data.customHeaders.value
          : this.customHeaders,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastResponseLine: data.lastResponseLine.present
          ? data.lastResponseLine.value
          : this.lastResponseLine,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('domainId: $domainId, ')
          ..write('domainSnapshot: $domainSnapshot, ')
          ..write('hostSnapshot: $hostSnapshot, ')
          ..write('domainLabelSnapshot: $domainLabelSnapshot, ')
          ..write('localPart: $localPart, ')
          ..write('displayName: $displayName, ')
          ..write('replyTo: $replyTo, ')
          ..write('toAddresses: $toAddresses, ')
          ..write('ccAddresses: $ccAddresses, ')
          ..write('bccAddresses: $bccAddresses, ')
          ..write('subject: $subject, ')
          ..write('bodyHtml: $bodyHtml, ')
          ..write('bodyPlain: $bodyPlain, ')
          ..write('bodyDeltaJson: $bodyDeltaJson, ')
          ..write('isHtml: $isHtml, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastResponseLine: $lastResponseLine, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('messageId: $messageId, ')
          ..write('transcript: $transcript')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    status,
    domainId,
    domainSnapshot,
    hostSnapshot,
    domainLabelSnapshot,
    localPart,
    displayName,
    replyTo,
    toAddresses,
    ccAddresses,
    bccAddresses,
    subject,
    bodyHtml,
    bodyPlain,
    bodyDeltaJson,
    isHtml,
    customHeaders,
    createdAt,
    updatedAt,
    sentAt,
    lastError,
    lastResponseLine,
    retryCount,
    nextRetryAt,
    messageId,
    transcript,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.domainId == this.domainId &&
          other.domainSnapshot == this.domainSnapshot &&
          other.hostSnapshot == this.hostSnapshot &&
          other.domainLabelSnapshot == this.domainLabelSnapshot &&
          other.localPart == this.localPart &&
          other.displayName == this.displayName &&
          other.replyTo == this.replyTo &&
          other.toAddresses == this.toAddresses &&
          other.ccAddresses == this.ccAddresses &&
          other.bccAddresses == this.bccAddresses &&
          other.subject == this.subject &&
          other.bodyHtml == this.bodyHtml &&
          other.bodyPlain == this.bodyPlain &&
          other.bodyDeltaJson == this.bodyDeltaJson &&
          other.isHtml == this.isHtml &&
          other.customHeaders == this.customHeaders &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sentAt == this.sentAt &&
          other.lastError == this.lastError &&
          other.lastResponseLine == this.lastResponseLine &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.messageId == this.messageId &&
          other.transcript == this.transcript);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<int> id;
  final Value<MessageStatus> status;
  final Value<int?> domainId;
  final Value<String> domainSnapshot;
  final Value<String> hostSnapshot;
  final Value<String> domainLabelSnapshot;
  final Value<String> localPart;
  final Value<String> displayName;
  final Value<String?> replyTo;
  final Value<String> toAddresses;
  final Value<String> ccAddresses;
  final Value<String> bccAddresses;
  final Value<String> subject;
  final Value<String?> bodyHtml;
  final Value<String> bodyPlain;
  final Value<String?> bodyDeltaJson;
  final Value<bool> isHtml;
  final Value<String> customHeaders;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> sentAt;
  final Value<String?> lastError;
  final Value<String?> lastResponseLine;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> messageId;
  final Value<String?> transcript;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.domainId = const Value.absent(),
    this.domainSnapshot = const Value.absent(),
    this.hostSnapshot = const Value.absent(),
    this.domainLabelSnapshot = const Value.absent(),
    this.localPart = const Value.absent(),
    this.displayName = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.toAddresses = const Value.absent(),
    this.ccAddresses = const Value.absent(),
    this.bccAddresses = const Value.absent(),
    this.subject = const Value.absent(),
    this.bodyHtml = const Value.absent(),
    this.bodyPlain = const Value.absent(),
    this.bodyDeltaJson = const Value.absent(),
    this.isHtml = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastResponseLine = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.messageId = const Value.absent(),
    this.transcript = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required MessageStatus status,
    this.domainId = const Value.absent(),
    this.domainSnapshot = const Value.absent(),
    this.hostSnapshot = const Value.absent(),
    this.domainLabelSnapshot = const Value.absent(),
    this.localPart = const Value.absent(),
    this.displayName = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.toAddresses = const Value.absent(),
    this.ccAddresses = const Value.absent(),
    this.bccAddresses = const Value.absent(),
    this.subject = const Value.absent(),
    this.bodyHtml = const Value.absent(),
    this.bodyPlain = const Value.absent(),
    this.bodyDeltaJson = const Value.absent(),
    this.isHtml = const Value.absent(),
    this.customHeaders = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastResponseLine = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.messageId = const Value.absent(),
    this.transcript = const Value.absent(),
  }) : status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MessageRow> custom({
    Expression<int>? id,
    Expression<int>? status,
    Expression<int>? domainId,
    Expression<String>? domainSnapshot,
    Expression<String>? hostSnapshot,
    Expression<String>? domainLabelSnapshot,
    Expression<String>? localPart,
    Expression<String>? displayName,
    Expression<String>? replyTo,
    Expression<String>? toAddresses,
    Expression<String>? ccAddresses,
    Expression<String>? bccAddresses,
    Expression<String>? subject,
    Expression<String>? bodyHtml,
    Expression<String>? bodyPlain,
    Expression<String>? bodyDeltaJson,
    Expression<bool>? isHtml,
    Expression<String>? customHeaders,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? sentAt,
    Expression<String>? lastError,
    Expression<String>? lastResponseLine,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? messageId,
    Expression<String>? transcript,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (domainId != null) 'domain_id': domainId,
      if (domainSnapshot != null) 'domain_snapshot': domainSnapshot,
      if (hostSnapshot != null) 'host_snapshot': hostSnapshot,
      if (domainLabelSnapshot != null)
        'domain_label_snapshot': domainLabelSnapshot,
      if (localPart != null) 'local_part': localPart,
      if (displayName != null) 'display_name': displayName,
      if (replyTo != null) 'reply_to': replyTo,
      if (toAddresses != null) 'to_addresses': toAddresses,
      if (ccAddresses != null) 'cc_addresses': ccAddresses,
      if (bccAddresses != null) 'bcc_addresses': bccAddresses,
      if (subject != null) 'subject': subject,
      if (bodyHtml != null) 'body_html': bodyHtml,
      if (bodyPlain != null) 'body_plain': bodyPlain,
      if (bodyDeltaJson != null) 'body_delta_json': bodyDeltaJson,
      if (isHtml != null) 'is_html': isHtml,
      if (customHeaders != null) 'custom_headers': customHeaders,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (lastError != null) 'last_error': lastError,
      if (lastResponseLine != null) 'last_response_line': lastResponseLine,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (messageId != null) 'message_id': messageId,
      if (transcript != null) 'transcript': transcript,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<MessageStatus>? status,
    Value<int?>? domainId,
    Value<String>? domainSnapshot,
    Value<String>? hostSnapshot,
    Value<String>? domainLabelSnapshot,
    Value<String>? localPart,
    Value<String>? displayName,
    Value<String?>? replyTo,
    Value<String>? toAddresses,
    Value<String>? ccAddresses,
    Value<String>? bccAddresses,
    Value<String>? subject,
    Value<String?>? bodyHtml,
    Value<String>? bodyPlain,
    Value<String?>? bodyDeltaJson,
    Value<bool>? isHtml,
    Value<String>? customHeaders,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? sentAt,
    Value<String?>? lastError,
    Value<String?>? lastResponseLine,
    Value<int>? retryCount,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? messageId,
    Value<String?>? transcript,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      domainId: domainId ?? this.domainId,
      domainSnapshot: domainSnapshot ?? this.domainSnapshot,
      hostSnapshot: hostSnapshot ?? this.hostSnapshot,
      domainLabelSnapshot: domainLabelSnapshot ?? this.domainLabelSnapshot,
      localPart: localPart ?? this.localPart,
      displayName: displayName ?? this.displayName,
      replyTo: replyTo ?? this.replyTo,
      toAddresses: toAddresses ?? this.toAddresses,
      ccAddresses: ccAddresses ?? this.ccAddresses,
      bccAddresses: bccAddresses ?? this.bccAddresses,
      subject: subject ?? this.subject,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      bodyPlain: bodyPlain ?? this.bodyPlain,
      bodyDeltaJson: bodyDeltaJson ?? this.bodyDeltaJson,
      isHtml: isHtml ?? this.isHtml,
      customHeaders: customHeaders ?? this.customHeaders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentAt: sentAt ?? this.sentAt,
      lastError: lastError ?? this.lastError,
      lastResponseLine: lastResponseLine ?? this.lastResponseLine,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      messageId: messageId ?? this.messageId,
      transcript: transcript ?? this.transcript,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $MessagesTable.$converterstatus.toSql(status.value),
      );
    }
    if (domainId.present) {
      map['domain_id'] = Variable<int>(domainId.value);
    }
    if (domainSnapshot.present) {
      map['domain_snapshot'] = Variable<String>(domainSnapshot.value);
    }
    if (hostSnapshot.present) {
      map['host_snapshot'] = Variable<String>(hostSnapshot.value);
    }
    if (domainLabelSnapshot.present) {
      map['domain_label_snapshot'] = Variable<String>(
        domainLabelSnapshot.value,
      );
    }
    if (localPart.present) {
      map['local_part'] = Variable<String>(localPart.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (replyTo.present) {
      map['reply_to'] = Variable<String>(replyTo.value);
    }
    if (toAddresses.present) {
      map['to_addresses'] = Variable<String>(toAddresses.value);
    }
    if (ccAddresses.present) {
      map['cc_addresses'] = Variable<String>(ccAddresses.value);
    }
    if (bccAddresses.present) {
      map['bcc_addresses'] = Variable<String>(bccAddresses.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (bodyHtml.present) {
      map['body_html'] = Variable<String>(bodyHtml.value);
    }
    if (bodyPlain.present) {
      map['body_plain'] = Variable<String>(bodyPlain.value);
    }
    if (bodyDeltaJson.present) {
      map['body_delta_json'] = Variable<String>(bodyDeltaJson.value);
    }
    if (isHtml.present) {
      map['is_html'] = Variable<bool>(isHtml.value);
    }
    if (customHeaders.present) {
      map['custom_headers'] = Variable<String>(customHeaders.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastResponseLine.present) {
      map['last_response_line'] = Variable<String>(lastResponseLine.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('domainId: $domainId, ')
          ..write('domainSnapshot: $domainSnapshot, ')
          ..write('hostSnapshot: $hostSnapshot, ')
          ..write('domainLabelSnapshot: $domainLabelSnapshot, ')
          ..write('localPart: $localPart, ')
          ..write('displayName: $displayName, ')
          ..write('replyTo: $replyTo, ')
          ..write('toAddresses: $toAddresses, ')
          ..write('ccAddresses: $ccAddresses, ')
          ..write('bccAddresses: $bccAddresses, ')
          ..write('subject: $subject, ')
          ..write('bodyHtml: $bodyHtml, ')
          ..write('bodyPlain: $bodyPlain, ')
          ..write('bodyDeltaJson: $bodyDeltaJson, ')
          ..write('isHtml: $isHtml, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastResponseLine: $lastResponseLine, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('messageId: $messageId, ')
          ..write('transcript: $transcript')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedPathMeta = const VerificationMeta(
    'storedPath',
  );
  @override
  late final GeneratedColumn<String> storedPath = GeneratedColumn<String>(
    'stored_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isInlineMeta = const VerificationMeta(
    'isInline',
  );
  @override
  late final GeneratedColumn<bool> isInline = GeneratedColumn<bool>(
    'is_inline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_inline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    fileName,
    mimeType,
    sizeBytes,
    storedPath,
    contentId,
    isInline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
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
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('stored_path')) {
      context.handle(
        _storedPathMeta,
        storedPath.isAcceptableOrUnknown(data['stored_path']!, _storedPathMeta),
      );
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    }
    if (data.containsKey('is_inline')) {
      context.handle(
        _isInlineMeta,
        isInline.isAcceptableOrUnknown(data['is_inline']!, _isInlineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      storedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_path'],
      ),
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      ),
      isInline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_inline'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final int id;
  final int messageId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  /// Path in app storage. Null once a sent message's files are discarded.
  final String? storedPath;

  /// Content-ID for inline parts, without angle brackets.
  final String? contentId;
  final bool isInline;
  const AttachmentRow({
    required this.id,
    required this.messageId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.storedPath,
    this.contentId,
    required this.isInline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || storedPath != null) {
      map['stored_path'] = Variable<String>(storedPath);
    }
    if (!nullToAbsent || contentId != null) {
      map['content_id'] = Variable<String>(contentId);
    }
    map['is_inline'] = Variable<bool>(isInline);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      storedPath: storedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(storedPath),
      contentId: contentId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentId),
      isInline: Value(isInline),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      storedPath: serializer.fromJson<String?>(json['storedPath']),
      contentId: serializer.fromJson<String?>(json['contentId']),
      isInline: serializer.fromJson<bool>(json['isInline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'storedPath': serializer.toJson<String?>(storedPath),
      'contentId': serializer.toJson<String?>(contentId),
      'isInline': serializer.toJson<bool>(isInline),
    };
  }

  AttachmentRow copyWith({
    int? id,
    int? messageId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Value<String?> storedPath = const Value.absent(),
    Value<String?> contentId = const Value.absent(),
    bool? isInline,
  }) => AttachmentRow(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    storedPath: storedPath.present ? storedPath.value : this.storedPath,
    contentId: contentId.present ? contentId.value : this.contentId,
    isInline: isInline ?? this.isInline,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      storedPath: data.storedPath.present
          ? data.storedPath.value
          : this.storedPath,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      isInline: data.isInline.present ? data.isInline.value : this.isInline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('storedPath: $storedPath, ')
          ..write('contentId: $contentId, ')
          ..write('isInline: $isInline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    fileName,
    mimeType,
    sizeBytes,
    storedPath,
    contentId,
    isInline,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.storedPath == this.storedPath &&
          other.contentId == this.contentId &&
          other.isInline == this.isInline);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> storedPath;
  final Value<String?> contentId;
  final Value<bool> isInline;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.storedPath = const Value.absent(),
    this.contentId = const Value.absent(),
    this.isInline = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.storedPath = const Value.absent(),
    this.contentId = const Value.absent(),
    this.isInline = const Value.absent(),
  }) : messageId = Value(messageId),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<AttachmentRow> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? storedPath,
    Expression<String>? contentId,
    Expression<bool>? isInline,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (storedPath != null) 'stored_path': storedPath,
      if (contentId != null) 'content_id': contentId,
      if (isInline != null) 'is_inline': isInline,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? storedPath,
    Value<String?>? contentId,
    Value<bool>? isInline,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storedPath: storedPath ?? this.storedPath,
      contentId: contentId ?? this.contentId,
      isInline: isInline ?? this.isInline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (storedPath.present) {
      map['stored_path'] = Variable<String>(storedPath.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (isInline.present) {
      map['is_inline'] = Variable<bool>(isInline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('storedPath: $storedPath, ')
          ..write('contentId: $contentId, ')
          ..write('isInline: $isInline')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultDomainIdMeta = const VerificationMeta(
    'defaultDomainId',
  );
  @override
  late final GeneratedColumn<int> defaultDomainId = GeneratedColumn<int>(
    'default_domain_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultPresetIdMeta = const VerificationMeta(
    'defaultPresetId',
  );
  @override
  late final GeneratedColumn<int> defaultPresetId = GeneratedColumn<int>(
    'default_preset_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _biometricLockEnabledMeta =
      const VerificationMeta('biometricLockEnabled');
  @override
  late final GeneratedColumn<bool> biometricLockEnabled = GeneratedColumn<bool>(
    'biometric_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("biometric_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attachmentWarnBytesMeta =
      const VerificationMeta('attachmentWarnBytes');
  @override
  late final GeneratedColumn<int> attachmentWarnBytes = GeneratedColumn<int>(
    'attachment_warn_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20 * 1024 * 1024),
  );
  static const VerificationMeta _sentLogRetentionDaysMeta =
      const VerificationMeta('sentLogRetentionDays');
  @override
  late final GeneratedColumn<int> sentLogRetentionDays = GeneratedColumn<int>(
    'sent_log_retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _composeHtmlByDefaultMeta =
      const VerificationMeta('composeHtmlByDefault');
  @override
  late final GeneratedColumn<bool> composeHtmlByDefault = GeneratedColumn<bool>(
    'compose_html_by_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("compose_html_by_default" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _keepSentAttachmentsMeta =
      const VerificationMeta('keepSentAttachments');
  @override
  late final GeneratedColumn<bool> keepSentAttachments = GeneratedColumn<bool>(
    'keep_sent_attachments',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_sent_attachments" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _defaultSignatureMeta = const VerificationMeta(
    'defaultSignature',
  );
  @override
  late final GeneratedColumn<String> defaultSignature = GeneratedColumn<String>(
    'default_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultDomainId,
    defaultPresetId,
    biometricLockEnabled,
    attachmentWarnBytes,
    sentLogRetentionDays,
    composeHtmlByDefault,
    keepSentAttachments,
    defaultSignature,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_domain_id')) {
      context.handle(
        _defaultDomainIdMeta,
        defaultDomainId.isAcceptableOrUnknown(
          data['default_domain_id']!,
          _defaultDomainIdMeta,
        ),
      );
    }
    if (data.containsKey('default_preset_id')) {
      context.handle(
        _defaultPresetIdMeta,
        defaultPresetId.isAcceptableOrUnknown(
          data['default_preset_id']!,
          _defaultPresetIdMeta,
        ),
      );
    }
    if (data.containsKey('biometric_lock_enabled')) {
      context.handle(
        _biometricLockEnabledMeta,
        biometricLockEnabled.isAcceptableOrUnknown(
          data['biometric_lock_enabled']!,
          _biometricLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('attachment_warn_bytes')) {
      context.handle(
        _attachmentWarnBytesMeta,
        attachmentWarnBytes.isAcceptableOrUnknown(
          data['attachment_warn_bytes']!,
          _attachmentWarnBytesMeta,
        ),
      );
    }
    if (data.containsKey('sent_log_retention_days')) {
      context.handle(
        _sentLogRetentionDaysMeta,
        sentLogRetentionDays.isAcceptableOrUnknown(
          data['sent_log_retention_days']!,
          _sentLogRetentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('compose_html_by_default')) {
      context.handle(
        _composeHtmlByDefaultMeta,
        composeHtmlByDefault.isAcceptableOrUnknown(
          data['compose_html_by_default']!,
          _composeHtmlByDefaultMeta,
        ),
      );
    }
    if (data.containsKey('keep_sent_attachments')) {
      context.handle(
        _keepSentAttachmentsMeta,
        keepSentAttachments.isAcceptableOrUnknown(
          data['keep_sent_attachments']!,
          _keepSentAttachmentsMeta,
        ),
      );
    }
    if (data.containsKey('default_signature')) {
      context.handle(
        _defaultSignatureMeta,
        defaultSignature.isAcceptableOrUnknown(
          data['default_signature']!,
          _defaultSignatureMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultDomainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_domain_id'],
      ),
      defaultPresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_preset_id'],
      ),
      biometricLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric_lock_enabled'],
      )!,
      attachmentWarnBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_warn_bytes'],
      )!,
      sentLogRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_log_retention_days'],
      )!,
      composeHtmlByDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}compose_html_by_default'],
      )!,
      keepSentAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_sent_attachments'],
      )!,
      defaultSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_signature'],
      ),
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final int? defaultDomainId;
  final int? defaultPresetId;
  final bool biometricLockEnabled;

  /// Warn above this total attachment size. Default 20 MB.
  final int attachmentWarnBytes;

  /// Days of sent history to keep. 0 means keep everything.
  final int sentLogRetentionDays;
  final bool composeHtmlByDefault;

  /// Whether to keep attachment files after sending, not just their metadata.
  final bool keepSentAttachments;
  final String? defaultSignature;
  const AppSettingsRow({
    required this.id,
    this.defaultDomainId,
    this.defaultPresetId,
    required this.biometricLockEnabled,
    required this.attachmentWarnBytes,
    required this.sentLogRetentionDays,
    required this.composeHtmlByDefault,
    required this.keepSentAttachments,
    this.defaultSignature,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || defaultDomainId != null) {
      map['default_domain_id'] = Variable<int>(defaultDomainId);
    }
    if (!nullToAbsent || defaultPresetId != null) {
      map['default_preset_id'] = Variable<int>(defaultPresetId);
    }
    map['biometric_lock_enabled'] = Variable<bool>(biometricLockEnabled);
    map['attachment_warn_bytes'] = Variable<int>(attachmentWarnBytes);
    map['sent_log_retention_days'] = Variable<int>(sentLogRetentionDays);
    map['compose_html_by_default'] = Variable<bool>(composeHtmlByDefault);
    map['keep_sent_attachments'] = Variable<bool>(keepSentAttachments);
    if (!nullToAbsent || defaultSignature != null) {
      map['default_signature'] = Variable<String>(defaultSignature);
    }
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      defaultDomainId: defaultDomainId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultDomainId),
      defaultPresetId: defaultPresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPresetId),
      biometricLockEnabled: Value(biometricLockEnabled),
      attachmentWarnBytes: Value(attachmentWarnBytes),
      sentLogRetentionDays: Value(sentLogRetentionDays),
      composeHtmlByDefault: Value(composeHtmlByDefault),
      keepSentAttachments: Value(keepSentAttachments),
      defaultSignature: defaultSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSignature),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      defaultDomainId: serializer.fromJson<int?>(json['defaultDomainId']),
      defaultPresetId: serializer.fromJson<int?>(json['defaultPresetId']),
      biometricLockEnabled: serializer.fromJson<bool>(
        json['biometricLockEnabled'],
      ),
      attachmentWarnBytes: serializer.fromJson<int>(
        json['attachmentWarnBytes'],
      ),
      sentLogRetentionDays: serializer.fromJson<int>(
        json['sentLogRetentionDays'],
      ),
      composeHtmlByDefault: serializer.fromJson<bool>(
        json['composeHtmlByDefault'],
      ),
      keepSentAttachments: serializer.fromJson<bool>(
        json['keepSentAttachments'],
      ),
      defaultSignature: serializer.fromJson<String?>(json['defaultSignature']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultDomainId': serializer.toJson<int?>(defaultDomainId),
      'defaultPresetId': serializer.toJson<int?>(defaultPresetId),
      'biometricLockEnabled': serializer.toJson<bool>(biometricLockEnabled),
      'attachmentWarnBytes': serializer.toJson<int>(attachmentWarnBytes),
      'sentLogRetentionDays': serializer.toJson<int>(sentLogRetentionDays),
      'composeHtmlByDefault': serializer.toJson<bool>(composeHtmlByDefault),
      'keepSentAttachments': serializer.toJson<bool>(keepSentAttachments),
      'defaultSignature': serializer.toJson<String?>(defaultSignature),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    Value<int?> defaultDomainId = const Value.absent(),
    Value<int?> defaultPresetId = const Value.absent(),
    bool? biometricLockEnabled,
    int? attachmentWarnBytes,
    int? sentLogRetentionDays,
    bool? composeHtmlByDefault,
    bool? keepSentAttachments,
    Value<String?> defaultSignature = const Value.absent(),
  }) => AppSettingsRow(
    id: id ?? this.id,
    defaultDomainId: defaultDomainId.present
        ? defaultDomainId.value
        : this.defaultDomainId,
    defaultPresetId: defaultPresetId.present
        ? defaultPresetId.value
        : this.defaultPresetId,
    biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
    attachmentWarnBytes: attachmentWarnBytes ?? this.attachmentWarnBytes,
    sentLogRetentionDays: sentLogRetentionDays ?? this.sentLogRetentionDays,
    composeHtmlByDefault: composeHtmlByDefault ?? this.composeHtmlByDefault,
    keepSentAttachments: keepSentAttachments ?? this.keepSentAttachments,
    defaultSignature: defaultSignature.present
        ? defaultSignature.value
        : this.defaultSignature,
  );
  AppSettingsRow copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      defaultDomainId: data.defaultDomainId.present
          ? data.defaultDomainId.value
          : this.defaultDomainId,
      defaultPresetId: data.defaultPresetId.present
          ? data.defaultPresetId.value
          : this.defaultPresetId,
      biometricLockEnabled: data.biometricLockEnabled.present
          ? data.biometricLockEnabled.value
          : this.biometricLockEnabled,
      attachmentWarnBytes: data.attachmentWarnBytes.present
          ? data.attachmentWarnBytes.value
          : this.attachmentWarnBytes,
      sentLogRetentionDays: data.sentLogRetentionDays.present
          ? data.sentLogRetentionDays.value
          : this.sentLogRetentionDays,
      composeHtmlByDefault: data.composeHtmlByDefault.present
          ? data.composeHtmlByDefault.value
          : this.composeHtmlByDefault,
      keepSentAttachments: data.keepSentAttachments.present
          ? data.keepSentAttachments.value
          : this.keepSentAttachments,
      defaultSignature: data.defaultSignature.present
          ? data.defaultSignature.value
          : this.defaultSignature,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('defaultDomainId: $defaultDomainId, ')
          ..write('defaultPresetId: $defaultPresetId, ')
          ..write('biometricLockEnabled: $biometricLockEnabled, ')
          ..write('attachmentWarnBytes: $attachmentWarnBytes, ')
          ..write('sentLogRetentionDays: $sentLogRetentionDays, ')
          ..write('composeHtmlByDefault: $composeHtmlByDefault, ')
          ..write('keepSentAttachments: $keepSentAttachments, ')
          ..write('defaultSignature: $defaultSignature')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultDomainId,
    defaultPresetId,
    biometricLockEnabled,
    attachmentWarnBytes,
    sentLogRetentionDays,
    composeHtmlByDefault,
    keepSentAttachments,
    defaultSignature,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.defaultDomainId == this.defaultDomainId &&
          other.defaultPresetId == this.defaultPresetId &&
          other.biometricLockEnabled == this.biometricLockEnabled &&
          other.attachmentWarnBytes == this.attachmentWarnBytes &&
          other.sentLogRetentionDays == this.sentLogRetentionDays &&
          other.composeHtmlByDefault == this.composeHtmlByDefault &&
          other.keepSentAttachments == this.keepSentAttachments &&
          other.defaultSignature == this.defaultSignature);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int?> defaultDomainId;
  final Value<int?> defaultPresetId;
  final Value<bool> biometricLockEnabled;
  final Value<int> attachmentWarnBytes;
  final Value<int> sentLogRetentionDays;
  final Value<bool> composeHtmlByDefault;
  final Value<bool> keepSentAttachments;
  final Value<String?> defaultSignature;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.defaultDomainId = const Value.absent(),
    this.defaultPresetId = const Value.absent(),
    this.biometricLockEnabled = const Value.absent(),
    this.attachmentWarnBytes = const Value.absent(),
    this.sentLogRetentionDays = const Value.absent(),
    this.composeHtmlByDefault = const Value.absent(),
    this.keepSentAttachments = const Value.absent(),
    this.defaultSignature = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.defaultDomainId = const Value.absent(),
    this.defaultPresetId = const Value.absent(),
    this.biometricLockEnabled = const Value.absent(),
    this.attachmentWarnBytes = const Value.absent(),
    this.sentLogRetentionDays = const Value.absent(),
    this.composeHtmlByDefault = const Value.absent(),
    this.keepSentAttachments = const Value.absent(),
    this.defaultSignature = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? defaultDomainId,
    Expression<int>? defaultPresetId,
    Expression<bool>? biometricLockEnabled,
    Expression<int>? attachmentWarnBytes,
    Expression<int>? sentLogRetentionDays,
    Expression<bool>? composeHtmlByDefault,
    Expression<bool>? keepSentAttachments,
    Expression<String>? defaultSignature,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultDomainId != null) 'default_domain_id': defaultDomainId,
      if (defaultPresetId != null) 'default_preset_id': defaultPresetId,
      if (biometricLockEnabled != null)
        'biometric_lock_enabled': biometricLockEnabled,
      if (attachmentWarnBytes != null)
        'attachment_warn_bytes': attachmentWarnBytes,
      if (sentLogRetentionDays != null)
        'sent_log_retention_days': sentLogRetentionDays,
      if (composeHtmlByDefault != null)
        'compose_html_by_default': composeHtmlByDefault,
      if (keepSentAttachments != null)
        'keep_sent_attachments': keepSentAttachments,
      if (defaultSignature != null) 'default_signature': defaultSignature,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? defaultDomainId,
    Value<int?>? defaultPresetId,
    Value<bool>? biometricLockEnabled,
    Value<int>? attachmentWarnBytes,
    Value<int>? sentLogRetentionDays,
    Value<bool>? composeHtmlByDefault,
    Value<bool>? keepSentAttachments,
    Value<String?>? defaultSignature,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      defaultDomainId: defaultDomainId ?? this.defaultDomainId,
      defaultPresetId: defaultPresetId ?? this.defaultPresetId,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      attachmentWarnBytes: attachmentWarnBytes ?? this.attachmentWarnBytes,
      sentLogRetentionDays: sentLogRetentionDays ?? this.sentLogRetentionDays,
      composeHtmlByDefault: composeHtmlByDefault ?? this.composeHtmlByDefault,
      keepSentAttachments: keepSentAttachments ?? this.keepSentAttachments,
      defaultSignature: defaultSignature ?? this.defaultSignature,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultDomainId.present) {
      map['default_domain_id'] = Variable<int>(defaultDomainId.value);
    }
    if (defaultPresetId.present) {
      map['default_preset_id'] = Variable<int>(defaultPresetId.value);
    }
    if (biometricLockEnabled.present) {
      map['biometric_lock_enabled'] = Variable<bool>(
        biometricLockEnabled.value,
      );
    }
    if (attachmentWarnBytes.present) {
      map['attachment_warn_bytes'] = Variable<int>(attachmentWarnBytes.value);
    }
    if (sentLogRetentionDays.present) {
      map['sent_log_retention_days'] = Variable<int>(
        sentLogRetentionDays.value,
      );
    }
    if (composeHtmlByDefault.present) {
      map['compose_html_by_default'] = Variable<bool>(
        composeHtmlByDefault.value,
      );
    }
    if (keepSentAttachments.present) {
      map['keep_sent_attachments'] = Variable<bool>(keepSentAttachments.value);
    }
    if (defaultSignature.present) {
      map['default_signature'] = Variable<String>(defaultSignature.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('defaultDomainId: $defaultDomainId, ')
          ..write('defaultPresetId: $defaultPresetId, ')
          ..write('biometricLockEnabled: $biometricLockEnabled, ')
          ..write('attachmentWarnBytes: $attachmentWarnBytes, ')
          ..write('sentLogRetentionDays: $sentLogRetentionDays, ')
          ..write('composeHtmlByDefault: $composeHtmlByDefault, ')
          ..write('keepSentAttachments: $keepSentAttachments, ')
          ..write('defaultSignature: $defaultSignature')
          ..write(')'))
        .toString();
  }
}

abstract class _$ManymailDatabase extends GeneratedDatabase {
  _$ManymailDatabase(QueryExecutor e) : super(e);
  $ManymailDatabaseManager get managers => $ManymailDatabaseManager(this);
  late final $DomainsTable domains = $DomainsTable(this);
  late final $IdentityPresetsTable identityPresets = $IdentityPresetsTable(
    this,
  );
  late final $MessagesTable messages = $MessagesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    domains,
    identityPresets,
    messages,
    attachments,
    appSettingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'domains',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('identity_presets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'domains',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DomainsTableCreateCompanionBuilder = DomainsCompanion Function({
  Value<int> id,
  required String label,
  required String domain,
  required String host,
  required int port,
  required SmtpSecurity security,
  required SmtpAuthMode authMode,
  Value<String> username,
  required String credentialKeyId,
  Value<bool> allowInsecureCertificate,
  Value<int> timeoutSeconds,
  Value<String?> defaultLocalPart,
  Value<String?> defaultDisplayName,
  Value<String?> defaultReplyTo,
  Value<bool> isDefault,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$DomainsTableUpdateCompanionBuilder = DomainsCompanion Function({
  Value<int> id,
  Value<String> label,
  Value<String> domain,
  Value<String> host,
  Value<int> port,
  Value<SmtpSecurity> security,
  Value<SmtpAuthMode> authMode,
  Value<String> username,
  Value<String> credentialKeyId,
  Value<bool> allowInsecureCertificate,
  Value<int> timeoutSeconds,
  Value<String?> defaultLocalPart,
  Value<String?> defaultDisplayName,
  Value<String?> defaultReplyTo,
  Value<bool> isDefault,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$DomainsTableReferences
    extends BaseReferences<_$ManymailDatabase, $DomainsTable, DomainRow> {
  $$DomainsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IdentityPresetsTable, List<IdentityPresetRow>>
  _identityPresetsRefsTable(_$ManymailDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.identityPresets,
        aliasName: 'domains__id__identity_presets__domain_id',
      );

  $$IdentityPresetsTableProcessedTableManager get identityPresetsRefs {
    final manager = $$IdentityPresetsTableTableManager(
      $_db,
      $_db.identityPresets,
    ).filter((f) => f.domainId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _identityPresetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<MessageRow>>
  _messagesRefsTable(_$ManymailDatabase db) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: 'domains__id__messages__domain_id',
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.domainId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DomainsTableFilterComposer
    extends Composer<_$ManymailDatabase, $DomainsTable> {
  $$DomainsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SmtpSecurity, SmtpSecurity, int>
  get security => $composableBuilder(
    column: $table.security,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SmtpAuthMode, SmtpAuthMode, int>
  get authMode => $composableBuilder(
    column: $table.authMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialKeyId => $composableBuilder(
    column: $table.credentialKeyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowInsecureCertificate => $composableBuilder(
    column: $table.allowInsecureCertificate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultLocalPart => $composableBuilder(
    column: $table.defaultLocalPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultDisplayName => $composableBuilder(
    column: $table.defaultDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultReplyTo => $composableBuilder(
    column: $table.defaultReplyTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  Expression<bool> identityPresetsRefs(
    Expression<bool> Function($$IdentityPresetsTableFilterComposer f) f,
  ) {
    final $$IdentityPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityPresets,
      getReferencedColumn: (t) => t.domainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityPresetsTableFilterComposer(
            $db: $db,
            $table: $db.identityPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.domainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DomainsTableOrderingComposer
    extends Composer<_$ManymailDatabase, $DomainsTable> {
  $$DomainsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get security => $composableBuilder(
    column: $table.security,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get authMode => $composableBuilder(
    column: $table.authMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialKeyId => $composableBuilder(
    column: $table.credentialKeyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowInsecureCertificate => $composableBuilder(
    column: $table.allowInsecureCertificate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultLocalPart => $composableBuilder(
    column: $table.defaultLocalPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDisplayName => $composableBuilder(
    column: $table.defaultDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultReplyTo => $composableBuilder(
    column: $table.defaultReplyTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

class $$DomainsTableAnnotationComposer
    extends Composer<_$ManymailDatabase, $DomainsTable> {
  $$DomainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SmtpSecurity, int> get security =>
      $composableBuilder(column: $table.security, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SmtpAuthMode, int> get authMode =>
      $composableBuilder(column: $table.authMode, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get credentialKeyId => $composableBuilder(
    column: $table.credentialKeyId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowInsecureCertificate => $composableBuilder(
    column: $table.allowInsecureCertificate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultLocalPart => $composableBuilder(
    column: $table.defaultLocalPart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultDisplayName => $composableBuilder(
    column: $table.defaultDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultReplyTo => $composableBuilder(
    column: $table.defaultReplyTo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> identityPresetsRefs<T extends Object>(
    Expression<T> Function($$IdentityPresetsTableAnnotationComposer a) f,
  ) {
    final $$IdentityPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityPresets,
      getReferencedColumn: (t) => t.domainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.identityPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.domainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DomainsTableTableManager
    extends
        RootTableManager<
          _$ManymailDatabase,
          $DomainsTable,
          DomainRow,
          $$DomainsTableFilterComposer,
          $$DomainsTableOrderingComposer,
          $$DomainsTableAnnotationComposer,
          $$DomainsTableCreateCompanionBuilder,
          $$DomainsTableUpdateCompanionBuilder,
          (DomainRow, $$DomainsTableReferences),
          DomainRow,
          PrefetchHooks Function({bool identityPresetsRefs, bool messagesRefs})
        > {
  $$DomainsTableTableManager(_$ManymailDatabase db, $DomainsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DomainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DomainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DomainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<SmtpSecurity> security = const Value.absent(),
                Value<SmtpAuthMode> authMode = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> credentialKeyId = const Value.absent(),
                Value<bool> allowInsecureCertificate = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                Value<String?> defaultLocalPart = const Value.absent(),
                Value<String?> defaultDisplayName = const Value.absent(),
                Value<String?> defaultReplyTo = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DomainsCompanion(
                id: id,
                label: label,
                domain: domain,
                host: host,
                port: port,
                security: security,
                authMode: authMode,
                username: username,
                credentialKeyId: credentialKeyId,
                allowInsecureCertificate: allowInsecureCertificate,
                timeoutSeconds: timeoutSeconds,
                defaultLocalPart: defaultLocalPart,
                defaultDisplayName: defaultDisplayName,
                defaultReplyTo: defaultReplyTo,
                isDefault: isDefault,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String domain,
                required String host,
                required int port,
                required SmtpSecurity security,
                required SmtpAuthMode authMode,
                Value<String> username = const Value.absent(),
                required String credentialKeyId,
                Value<bool> allowInsecureCertificate = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                Value<String?> defaultLocalPart = const Value.absent(),
                Value<String?> defaultDisplayName = const Value.absent(),
                Value<String?> defaultReplyTo = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DomainsCompanion.insert(
                id: id,
                label: label,
                domain: domain,
                host: host,
                port: port,
                security: security,
                authMode: authMode,
                username: username,
                credentialKeyId: credentialKeyId,
                allowInsecureCertificate: allowInsecureCertificate,
                timeoutSeconds: timeoutSeconds,
                defaultLocalPart: defaultLocalPart,
                defaultDisplayName: defaultDisplayName,
                defaultReplyTo: defaultReplyTo,
                isDefault: isDefault,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DomainsTable, DomainRow>(table),
                  $$DomainsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({identityPresetsRefs = false, messagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (identityPresetsRefs) db.identityPresets,
                    if (messagesRefs) db.messages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (identityPresetsRefs)
                        await $_getPrefetchedData<
                          DomainRow,
                          $DomainsTable,
                          IdentityPresetRow
                        >(
                          currentTable: table,
                          referencedTable: $$DomainsTableReferences
                              ._identityPresetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DomainsTableReferences(
                                db,
                                table,
                                p0,
                              ).identityPresetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.domainId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          DomainRow,
                          $DomainsTable,
                          MessageRow
                        >(
                          currentTable: table,
                          referencedTable: $$DomainsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DomainsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.domainId == item.id,
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

typedef $$DomainsTableProcessedTableManager =
    ProcessedTableManager<
      _$ManymailDatabase,
      $DomainsTable,
      DomainRow,
      $$DomainsTableFilterComposer,
      $$DomainsTableOrderingComposer,
      $$DomainsTableAnnotationComposer,
      $$DomainsTableCreateCompanionBuilder,
      $$DomainsTableUpdateCompanionBuilder,
      (DomainRow, $$DomainsTableReferences),
      DomainRow,
      PrefetchHooks Function({bool identityPresetsRefs, bool messagesRefs})
    >;
typedef $$IdentityPresetsTableCreateCompanionBuilder =
    IdentityPresetsCompanion Function({
      Value<int> id,
      required int domainId,
      required String name,
      required String localPart,
      Value<String> displayName,
      Value<String?> replyTo,
      Value<String?> signature,
      Value<int> sortOrder,
    });
typedef $$IdentityPresetsTableUpdateCompanionBuilder =
    IdentityPresetsCompanion Function({
      Value<int> id,
      Value<int> domainId,
      Value<String> name,
      Value<String> localPart,
      Value<String> displayName,
      Value<String?> replyTo,
      Value<String?> signature,
      Value<int> sortOrder,
    });

final class $$IdentityPresetsTableReferences
    extends
        BaseReferences<
          _$ManymailDatabase,
          $IdentityPresetsTable,
          IdentityPresetRow
        > {
  $$IdentityPresetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DomainsTable _domainIdTable(_$ManymailDatabase db) =>
      db.domains.createAlias('identity_presets__domain_id__domains__id');

  $$DomainsTableProcessedTableManager get domainId {
    final $_column = $_itemColumn<int>('domain_id')!;

    final manager = $$DomainsTableTableManager(
      $_db,
      $_db.domains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_domainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IdentityPresetsTableFilterComposer
    extends Composer<_$ManymailDatabase, $IdentityPresetsTable> {
  $$IdentityPresetsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPart => $composableBuilder(
    column: $table.localPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DomainsTableFilterComposer get domainId {
    final $$DomainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableFilterComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IdentityPresetsTableOrderingComposer
    extends Composer<_$ManymailDatabase, $IdentityPresetsTable> {
  $$IdentityPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPart => $composableBuilder(
    column: $table.localPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DomainsTableOrderingComposer get domainId {
    final $$DomainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableOrderingComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IdentityPresetsTableAnnotationComposer
    extends Composer<_$ManymailDatabase, $IdentityPresetsTable> {
  $$IdentityPresetsTableAnnotationComposer({
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

  GeneratedColumn<String> get localPart =>
      $composableBuilder(column: $table.localPart, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyTo =>
      $composableBuilder(column: $table.replyTo, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DomainsTableAnnotationComposer get domainId {
    final $$DomainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableAnnotationComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IdentityPresetsTableTableManager
    extends
        RootTableManager<
          _$ManymailDatabase,
          $IdentityPresetsTable,
          IdentityPresetRow,
          $$IdentityPresetsTableFilterComposer,
          $$IdentityPresetsTableOrderingComposer,
          $$IdentityPresetsTableAnnotationComposer,
          $$IdentityPresetsTableCreateCompanionBuilder,
          $$IdentityPresetsTableUpdateCompanionBuilder,
          (IdentityPresetRow, $$IdentityPresetsTableReferences),
          IdentityPresetRow,
          PrefetchHooks Function({bool domainId})
        > {
  $$IdentityPresetsTableTableManager(
    _$ManymailDatabase db,
    $IdentityPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentityPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentityPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentityPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> domainId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> localPart = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> replyTo = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => IdentityPresetsCompanion(
                id: id,
                domainId: domainId,
                name: name,
                localPart: localPart,
                displayName: displayName,
                replyTo: replyTo,
                signature: signature,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int domainId,
                required String name,
                required String localPart,
                Value<String> displayName = const Value.absent(),
                Value<String?> replyTo = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => IdentityPresetsCompanion.insert(
                id: id,
                domainId: domainId,
                name: name,
                localPart: localPart,
                displayName: displayName,
                replyTo: replyTo,
                signature: signature,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IdentityPresetsTable, IdentityPresetRow>(table),
                  $$IdentityPresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({domainId = false}) {
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
                    if (domainId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.domainId,
                        referencedTable: $$IdentityPresetsTableReferences
                            ._domainIdTable(db),
                        referencedColumn: $$IdentityPresetsTableReferences
                            ._domainIdTable(db)
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
        ),
      );
}

typedef $$IdentityPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$ManymailDatabase,
      $IdentityPresetsTable,
      IdentityPresetRow,
      $$IdentityPresetsTableFilterComposer,
      $$IdentityPresetsTableOrderingComposer,
      $$IdentityPresetsTableAnnotationComposer,
      $$IdentityPresetsTableCreateCompanionBuilder,
      $$IdentityPresetsTableUpdateCompanionBuilder,
      (IdentityPresetRow, $$IdentityPresetsTableReferences),
      IdentityPresetRow,
      PrefetchHooks Function({bool domainId})
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required MessageStatus status,
  Value<int?> domainId,
  Value<String> domainSnapshot,
  Value<String> hostSnapshot,
  Value<String> domainLabelSnapshot,
  Value<String> localPart,
  Value<String> displayName,
  Value<String?> replyTo,
  Value<String> toAddresses,
  Value<String> ccAddresses,
  Value<String> bccAddresses,
  Value<String> subject,
  Value<String?> bodyHtml,
  Value<String> bodyPlain,
  Value<String?> bodyDeltaJson,
  Value<bool> isHtml,
  Value<String> customHeaders,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> sentAt,
  Value<String?> lastError,
  Value<String?> lastResponseLine,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> messageId,
  Value<String?> transcript,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<MessageStatus> status,
  Value<int?> domainId,
  Value<String> domainSnapshot,
  Value<String> hostSnapshot,
  Value<String> domainLabelSnapshot,
  Value<String> localPart,
  Value<String> displayName,
  Value<String?> replyTo,
  Value<String> toAddresses,
  Value<String> ccAddresses,
  Value<String> bccAddresses,
  Value<String> subject,
  Value<String?> bodyHtml,
  Value<String> bodyPlain,
  Value<String?> bodyDeltaJson,
  Value<bool> isHtml,
  Value<String> customHeaders,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> sentAt,
  Value<String?> lastError,
  Value<String?> lastResponseLine,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> messageId,
  Value<String?> transcript,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$ManymailDatabase, $MessagesTable, MessageRow> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DomainsTable _domainIdTable(_$ManymailDatabase db) =>
      db.domains.createAlias('messages__domain_id__domains__id');

  $$DomainsTableProcessedTableManager? get domainId {
    final $_column = $_itemColumn<int>('domain_id');
    if ($_column == null) return null;
    final manager = $$DomainsTableTableManager(
      $_db,
      $_db.domains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_domainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$ManymailDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'messages__id__attachments__message_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$ManymailDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<MessageStatus, MessageStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get domainSnapshot => $composableBuilder(
    column: $table.domainSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostSnapshot => $composableBuilder(
    column: $table.hostSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainLabelSnapshot => $composableBuilder(
    column: $table.domainLabelSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPart => $composableBuilder(
    column: $table.localPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAddresses => $composableBuilder(
    column: $table.toAddresses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccAddresses => $composableBuilder(
    column: $table.ccAddresses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bccAddresses => $composableBuilder(
    column: $table.bccAddresses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyHtml => $composableBuilder(
    column: $table.bodyHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPlain => $composableBuilder(
    column: $table.bodyPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyDeltaJson => $composableBuilder(
    column: $table.bodyDeltaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHtml => $composableBuilder(
    column: $table.isHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
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

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastResponseLine => $composableBuilder(
    column: $table.lastResponseLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  $$DomainsTableFilterComposer get domainId {
    final $$DomainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableFilterComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$ManymailDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainSnapshot => $composableBuilder(
    column: $table.domainSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostSnapshot => $composableBuilder(
    column: $table.hostSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainLabelSnapshot => $composableBuilder(
    column: $table.domainLabelSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPart => $composableBuilder(
    column: $table.localPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAddresses => $composableBuilder(
    column: $table.toAddresses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccAddresses => $composableBuilder(
    column: $table.ccAddresses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bccAddresses => $composableBuilder(
    column: $table.bccAddresses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyHtml => $composableBuilder(
    column: $table.bodyHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPlain => $composableBuilder(
    column: $table.bodyPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyDeltaJson => $composableBuilder(
    column: $table.bodyDeltaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHtml => $composableBuilder(
    column: $table.isHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
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

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResponseLine => $composableBuilder(
    column: $table.lastResponseLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  $$DomainsTableOrderingComposer get domainId {
    final $$DomainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableOrderingComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$ManymailDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get domainSnapshot => $composableBuilder(
    column: $table.domainSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hostSnapshot => $composableBuilder(
    column: $table.hostSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domainLabelSnapshot => $composableBuilder(
    column: $table.domainLabelSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPart =>
      $composableBuilder(column: $table.localPart, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyTo =>
      $composableBuilder(column: $table.replyTo, builder: (column) => column);

  GeneratedColumn<String> get toAddresses => $composableBuilder(
    column: $table.toAddresses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ccAddresses => $composableBuilder(
    column: $table.ccAddresses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bccAddresses => $composableBuilder(
    column: $table.bccAddresses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get bodyHtml =>
      $composableBuilder(column: $table.bodyHtml, builder: (column) => column);

  GeneratedColumn<String> get bodyPlain =>
      $composableBuilder(column: $table.bodyPlain, builder: (column) => column);

  GeneratedColumn<String> get bodyDeltaJson => $composableBuilder(
    column: $table.bodyDeltaJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHtml =>
      $composableBuilder(column: $table.isHtml, builder: (column) => column);

  GeneratedColumn<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get lastResponseLine => $composableBuilder(
    column: $table.lastResponseLine,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  $$DomainsTableAnnotationComposer get domainId {
    final $$DomainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.domainId,
      referencedTable: $db.domains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomainsTableAnnotationComposer(
            $db: $db,
            $table: $db.domains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$ManymailDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (MessageRow, $$MessagesTableReferences),
          MessageRow,
          PrefetchHooks Function({bool domainId, bool attachmentsRefs})
        > {
  $$MessagesTableTableManager(_$ManymailDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<MessageStatus> status = const Value.absent(),
                Value<int?> domainId = const Value.absent(),
                Value<String> domainSnapshot = const Value.absent(),
                Value<String> hostSnapshot = const Value.absent(),
                Value<String> domainLabelSnapshot = const Value.absent(),
                Value<String> localPart = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> replyTo = const Value.absent(),
                Value<String> toAddresses = const Value.absent(),
                Value<String> ccAddresses = const Value.absent(),
                Value<String> bccAddresses = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String?> bodyHtml = const Value.absent(),
                Value<String> bodyPlain = const Value.absent(),
                Value<String?> bodyDeltaJson = const Value.absent(),
                Value<bool> isHtml = const Value.absent(),
                Value<String> customHeaders = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> lastResponseLine = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> messageId = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                status: status,
                domainId: domainId,
                domainSnapshot: domainSnapshot,
                hostSnapshot: hostSnapshot,
                domainLabelSnapshot: domainLabelSnapshot,
                localPart: localPart,
                displayName: displayName,
                replyTo: replyTo,
                toAddresses: toAddresses,
                ccAddresses: ccAddresses,
                bccAddresses: bccAddresses,
                subject: subject,
                bodyHtml: bodyHtml,
                bodyPlain: bodyPlain,
                bodyDeltaJson: bodyDeltaJson,
                isHtml: isHtml,
                customHeaders: customHeaders,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                lastError: lastError,
                lastResponseLine: lastResponseLine,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                messageId: messageId,
                transcript: transcript,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required MessageStatus status,
                Value<int?> domainId = const Value.absent(),
                Value<String> domainSnapshot = const Value.absent(),
                Value<String> hostSnapshot = const Value.absent(),
                Value<String> domainLabelSnapshot = const Value.absent(),
                Value<String> localPart = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> replyTo = const Value.absent(),
                Value<String> toAddresses = const Value.absent(),
                Value<String> ccAddresses = const Value.absent(),
                Value<String> bccAddresses = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String?> bodyHtml = const Value.absent(),
                Value<String> bodyPlain = const Value.absent(),
                Value<String?> bodyDeltaJson = const Value.absent(),
                Value<bool> isHtml = const Value.absent(),
                Value<String> customHeaders = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> lastResponseLine = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> messageId = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                status: status,
                domainId: domainId,
                domainSnapshot: domainSnapshot,
                hostSnapshot: hostSnapshot,
                domainLabelSnapshot: domainLabelSnapshot,
                localPart: localPart,
                displayName: displayName,
                replyTo: replyTo,
                toAddresses: toAddresses,
                ccAddresses: ccAddresses,
                bccAddresses: bccAddresses,
                subject: subject,
                bodyHtml: bodyHtml,
                bodyPlain: bodyPlain,
                bodyDeltaJson: bodyDeltaJson,
                isHtml: isHtml,
                customHeaders: customHeaders,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                lastError: lastError,
                lastResponseLine: lastResponseLine,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                messageId: messageId,
                transcript: transcript,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({domainId = false, attachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attachmentsRefs) db.attachments],
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
                    if (domainId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.domainId,
                        referencedTable: $$MessagesTableReferences
                            ._domainIdTable(db),
                        referencedColumn: $$MessagesTableReferences
                            ._domainIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attachmentsRefs)
                    await $_getPrefetchedData<
                      MessageRow,
                      $MessagesTable,
                      AttachmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$MessagesTableReferences
                          ._attachmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MessagesTableReferences(
                        db,
                        table,
                        p0,
                      ).attachmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.messageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$ManymailDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, $$MessagesTableReferences),
      MessageRow,
      PrefetchHooks Function({bool domainId, bool attachmentsRefs})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      required int messageId,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      Value<String?> storedPath,
      Value<String?> contentId,
      Value<bool> isInline,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> storedPath,
      Value<String?> contentId,
      Value<bool> isInline,
    });

final class $$AttachmentsTableReferences
    extends
        BaseReferences<_$ManymailDatabase, $AttachmentsTable, AttachmentRow> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessagesTable _messageIdTable(_$ManymailDatabase db) =>
      db.messages.createAlias('attachments__message_id__messages__id');

  $$MessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$ManymailDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
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

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
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

  ColumnFilters<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInline => $composableBuilder(
    column: $table.isInline,
    builder: (column) => ColumnFilters(column),
  );

  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$ManymailDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
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

  ColumnOrderings<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInline => $composableBuilder(
    column: $table.isInline,
    builder: (column) => ColumnOrderings(column),
  );

  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$ManymailDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<bool> get isInline =>
      $composableBuilder(column: $table.isInline, builder: (column) => column);

  $$MessagesTableAnnotationComposer get messageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$ManymailDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (AttachmentRow, $$AttachmentsTableReferences),
          AttachmentRow,
          PrefetchHooks Function({bool messageId})
        > {
  $$AttachmentsTableTableManager(_$ManymailDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> storedPath = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<bool> isInline = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                messageId: messageId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                storedPath: storedPath,
                contentId: contentId,
                isInline: isInline,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                Value<String?> storedPath = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<bool> isInline = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                messageId: messageId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                storedPath: storedPath,
                contentId: contentId,
                isInline: isInline,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, AttachmentRow>(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false}) {
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
                    if (messageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.messageId,
                        referencedTable: $$AttachmentsTableReferences
                            ._messageIdTable(db),
                        referencedColumn: $$AttachmentsTableReferences
                            ._messageIdTable(db)
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
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ManymailDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (AttachmentRow, $$AttachmentsTableReferences),
      AttachmentRow,
      PrefetchHooks Function({bool messageId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> defaultDomainId,
      Value<int?> defaultPresetId,
      Value<bool> biometricLockEnabled,
      Value<int> attachmentWarnBytes,
      Value<int> sentLogRetentionDays,
      Value<bool> composeHtmlByDefault,
      Value<bool> keepSentAttachments,
      Value<String?> defaultSignature,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> defaultDomainId,
      Value<int?> defaultPresetId,
      Value<bool> biometricLockEnabled,
      Value<int> attachmentWarnBytes,
      Value<int> sentLogRetentionDays,
      Value<bool> composeHtmlByDefault,
      Value<bool> keepSentAttachments,
      Value<String?> defaultSignature,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$ManymailDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
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

  ColumnFilters<int> get defaultDomainId => $composableBuilder(
    column: $table.defaultDomainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPresetId => $composableBuilder(
    column: $table.defaultPresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attachmentWarnBytes => $composableBuilder(
    column: $table.attachmentWarnBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentLogRetentionDays => $composableBuilder(
    column: $table.sentLogRetentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get composeHtmlByDefault => $composableBuilder(
    column: $table.composeHtmlByDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepSentAttachments => $composableBuilder(
    column: $table.keepSentAttachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSignature => $composableBuilder(
    column: $table.defaultSignature,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$ManymailDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
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

  ColumnOrderings<int> get defaultDomainId => $composableBuilder(
    column: $table.defaultDomainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPresetId => $composableBuilder(
    column: $table.defaultPresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attachmentWarnBytes => $composableBuilder(
    column: $table.attachmentWarnBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentLogRetentionDays => $composableBuilder(
    column: $table.sentLogRetentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get composeHtmlByDefault => $composableBuilder(
    column: $table.composeHtmlByDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepSentAttachments => $composableBuilder(
    column: $table.keepSentAttachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSignature => $composableBuilder(
    column: $table.defaultSignature,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$ManymailDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultDomainId => $composableBuilder(
    column: $table.defaultDomainId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultPresetId => $composableBuilder(
    column: $table.defaultPresetId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attachmentWarnBytes => $composableBuilder(
    column: $table.attachmentWarnBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentLogRetentionDays => $composableBuilder(
    column: $table.sentLogRetentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get composeHtmlByDefault => $composableBuilder(
    column: $table.composeHtmlByDefault,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepSentAttachments => $composableBuilder(
    column: $table.keepSentAttachments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSignature => $composableBuilder(
    column: $table.defaultSignature,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$ManymailDatabase,
          $AppSettingsTableTable,
          AppSettingsRow,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$ManymailDatabase,
              $AppSettingsTableTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$ManymailDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> defaultDomainId = const Value.absent(),
                Value<int?> defaultPresetId = const Value.absent(),
                Value<bool> biometricLockEnabled = const Value.absent(),
                Value<int> attachmentWarnBytes = const Value.absent(),
                Value<int> sentLogRetentionDays = const Value.absent(),
                Value<bool> composeHtmlByDefault = const Value.absent(),
                Value<bool> keepSentAttachments = const Value.absent(),
                Value<String?> defaultSignature = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                defaultDomainId: defaultDomainId,
                defaultPresetId: defaultPresetId,
                biometricLockEnabled: biometricLockEnabled,
                attachmentWarnBytes: attachmentWarnBytes,
                sentLogRetentionDays: sentLogRetentionDays,
                composeHtmlByDefault: composeHtmlByDefault,
                keepSentAttachments: keepSentAttachments,
                defaultSignature: defaultSignature,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> defaultDomainId = const Value.absent(),
                Value<int?> defaultPresetId = const Value.absent(),
                Value<bool> biometricLockEnabled = const Value.absent(),
                Value<int> attachmentWarnBytes = const Value.absent(),
                Value<int> sentLogRetentionDays = const Value.absent(),
                Value<bool> composeHtmlByDefault = const Value.absent(),
                Value<bool> keepSentAttachments = const Value.absent(),
                Value<String?> defaultSignature = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                defaultDomainId: defaultDomainId,
                defaultPresetId: defaultPresetId,
                biometricLockEnabled: biometricLockEnabled,
                attachmentWarnBytes: attachmentWarnBytes,
                sentLogRetentionDays: sentLogRetentionDays,
                composeHtmlByDefault: composeHtmlByDefault,
                keepSentAttachments: keepSentAttachments,
                defaultSignature: defaultSignature,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTableTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$ManymailDatabase,
                    $AppSettingsTableTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ManymailDatabase,
      $AppSettingsTableTable,
      AppSettingsRow,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<
          _$ManymailDatabase,
          $AppSettingsTableTable,
          AppSettingsRow
        >,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;

class $ManymailDatabaseManager {
  final _$ManymailDatabase _db;
  $ManymailDatabaseManager(this._db);
  $$DomainsTableTableManager get domains =>
      $$DomainsTableTableManager(_db, _db.domains);
  $$IdentityPresetsTableTableManager get identityPresets =>
      $$IdentityPresetsTableTableManager(_db, _db.identityPresets);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
