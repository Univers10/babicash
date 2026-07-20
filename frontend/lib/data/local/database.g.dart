// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalProduitsTable extends LocalProduits
    with TableInfo<$LocalProduitsTable, LocalProduit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProduitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categorieIdMeta =
      const VerificationMeta('categorieId');
  @override
  late final GeneratedColumn<String> categorieId = GeneratedColumn<String>(
      'categorie_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixAchatMoyenMeta =
      const VerificationMeta('prixAchatMoyen');
  @override
  late final GeneratedColumn<double> prixAchatMoyen = GeneratedColumn<double>(
      'prix_achat_moyen', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _prixVenteSuggereMeta =
      const VerificationMeta('prixVenteSuggere');
  @override
  late final GeneratedColumn<double> prixVenteSuggere = GeneratedColumn<double>(
      'prix_vente_suggere', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stockActuelMeta =
      const VerificationMeta('stockActuel');
  @override
  late final GeneratedColumn<int> stockActuel = GeneratedColumn<int>(
      'stock_actuel', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stockAlerteMeta =
      const VerificationMeta('stockAlerte');
  @override
  late final GeneratedColumn<int> stockAlerte = GeneratedColumn<int>(
      'stock_alerte', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
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
        boutiqueId,
        categorieId,
        nom,
        prixAchatMoyen,
        prixVenteSuggere,
        stockActuel,
        stockAlerte,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_produits';
  @override
  VerificationContext validateIntegrity(Insertable<LocalProduit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('categorie_id')) {
      context.handle(
          _categorieIdMeta,
          categorieId.isAcceptableOrUnknown(
              data['categorie_id']!, _categorieIdMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prix_achat_moyen')) {
      context.handle(
          _prixAchatMoyenMeta,
          prixAchatMoyen.isAcceptableOrUnknown(
              data['prix_achat_moyen']!, _prixAchatMoyenMeta));
    }
    if (data.containsKey('prix_vente_suggere')) {
      context.handle(
          _prixVenteSuggereMeta,
          prixVenteSuggere.isAcceptableOrUnknown(
              data['prix_vente_suggere']!, _prixVenteSuggereMeta));
    }
    if (data.containsKey('stock_actuel')) {
      context.handle(
          _stockActuelMeta,
          stockActuel.isAcceptableOrUnknown(
              data['stock_actuel']!, _stockActuelMeta));
    }
    if (data.containsKey('stock_alerte')) {
      context.handle(
          _stockAlerteMeta,
          stockAlerte.isAcceptableOrUnknown(
              data['stock_alerte']!, _stockAlerteMeta));
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
  LocalProduit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProduit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      categorieId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categorie_id']),
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      prixAchatMoyen: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}prix_achat_moyen'])!,
      prixVenteSuggere: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}prix_vente_suggere'])!,
      stockActuel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_actuel'])!,
      stockAlerte: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_alerte'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalProduitsTable createAlias(String alias) {
    return $LocalProduitsTable(attachedDatabase, alias);
  }
}

class LocalProduit extends DataClass implements Insertable<LocalProduit> {
  final String id;
  final String boutiqueId;
  final String? categorieId;
  final String nom;
  final double prixAchatMoyen;
  final double prixVenteSuggere;
  final int stockActuel;
  final int stockAlerte;
  final DateTime updatedAt;
  const LocalProduit(
      {required this.id,
      required this.boutiqueId,
      this.categorieId,
      required this.nom,
      required this.prixAchatMoyen,
      required this.prixVenteSuggere,
      required this.stockActuel,
      required this.stockAlerte,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boutique_id'] = Variable<String>(boutiqueId);
    if (!nullToAbsent || categorieId != null) {
      map['categorie_id'] = Variable<String>(categorieId);
    }
    map['nom'] = Variable<String>(nom);
    map['prix_achat_moyen'] = Variable<double>(prixAchatMoyen);
    map['prix_vente_suggere'] = Variable<double>(prixVenteSuggere);
    map['stock_actuel'] = Variable<int>(stockActuel);
    map['stock_alerte'] = Variable<int>(stockAlerte);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalProduitsCompanion toCompanion(bool nullToAbsent) {
    return LocalProduitsCompanion(
      id: Value(id),
      boutiqueId: Value(boutiqueId),
      categorieId: categorieId == null && nullToAbsent
          ? const Value.absent()
          : Value(categorieId),
      nom: Value(nom),
      prixAchatMoyen: Value(prixAchatMoyen),
      prixVenteSuggere: Value(prixVenteSuggere),
      stockActuel: Value(stockActuel),
      stockAlerte: Value(stockAlerte),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalProduit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProduit(
      id: serializer.fromJson<String>(json['id']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      categorieId: serializer.fromJson<String?>(json['categorieId']),
      nom: serializer.fromJson<String>(json['nom']),
      prixAchatMoyen: serializer.fromJson<double>(json['prixAchatMoyen']),
      prixVenteSuggere: serializer.fromJson<double>(json['prixVenteSuggere']),
      stockActuel: serializer.fromJson<int>(json['stockActuel']),
      stockAlerte: serializer.fromJson<int>(json['stockAlerte']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'categorieId': serializer.toJson<String?>(categorieId),
      'nom': serializer.toJson<String>(nom),
      'prixAchatMoyen': serializer.toJson<double>(prixAchatMoyen),
      'prixVenteSuggere': serializer.toJson<double>(prixVenteSuggere),
      'stockActuel': serializer.toJson<int>(stockActuel),
      'stockAlerte': serializer.toJson<int>(stockAlerte),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalProduit copyWith(
          {String? id,
          String? boutiqueId,
          Value<String?> categorieId = const Value.absent(),
          String? nom,
          double? prixAchatMoyen,
          double? prixVenteSuggere,
          int? stockActuel,
          int? stockAlerte,
          DateTime? updatedAt}) =>
      LocalProduit(
        id: id ?? this.id,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        categorieId: categorieId.present ? categorieId.value : this.categorieId,
        nom: nom ?? this.nom,
        prixAchatMoyen: prixAchatMoyen ?? this.prixAchatMoyen,
        prixVenteSuggere: prixVenteSuggere ?? this.prixVenteSuggere,
        stockActuel: stockActuel ?? this.stockActuel,
        stockAlerte: stockAlerte ?? this.stockAlerte,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalProduit copyWithCompanion(LocalProduitsCompanion data) {
    return LocalProduit(
      id: data.id.present ? data.id.value : this.id,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      categorieId:
          data.categorieId.present ? data.categorieId.value : this.categorieId,
      nom: data.nom.present ? data.nom.value : this.nom,
      prixAchatMoyen: data.prixAchatMoyen.present
          ? data.prixAchatMoyen.value
          : this.prixAchatMoyen,
      prixVenteSuggere: data.prixVenteSuggere.present
          ? data.prixVenteSuggere.value
          : this.prixVenteSuggere,
      stockActuel:
          data.stockActuel.present ? data.stockActuel.value : this.stockActuel,
      stockAlerte:
          data.stockAlerte.present ? data.stockAlerte.value : this.stockAlerte,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProduit(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prixAchatMoyen: $prixAchatMoyen, ')
          ..write('prixVenteSuggere: $prixVenteSuggere, ')
          ..write('stockActuel: $stockActuel, ')
          ..write('stockAlerte: $stockAlerte, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, boutiqueId, categorieId, nom,
      prixAchatMoyen, prixVenteSuggere, stockActuel, stockAlerte, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProduit &&
          other.id == this.id &&
          other.boutiqueId == this.boutiqueId &&
          other.categorieId == this.categorieId &&
          other.nom == this.nom &&
          other.prixAchatMoyen == this.prixAchatMoyen &&
          other.prixVenteSuggere == this.prixVenteSuggere &&
          other.stockActuel == this.stockActuel &&
          other.stockAlerte == this.stockAlerte &&
          other.updatedAt == this.updatedAt);
}

class LocalProduitsCompanion extends UpdateCompanion<LocalProduit> {
  final Value<String> id;
  final Value<String> boutiqueId;
  final Value<String?> categorieId;
  final Value<String> nom;
  final Value<double> prixAchatMoyen;
  final Value<double> prixVenteSuggere;
  final Value<int> stockActuel;
  final Value<int> stockAlerte;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalProduitsCompanion({
    this.id = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.categorieId = const Value.absent(),
    this.nom = const Value.absent(),
    this.prixAchatMoyen = const Value.absent(),
    this.prixVenteSuggere = const Value.absent(),
    this.stockActuel = const Value.absent(),
    this.stockAlerte = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProduitsCompanion.insert({
    required String id,
    required String boutiqueId,
    this.categorieId = const Value.absent(),
    required String nom,
    this.prixAchatMoyen = const Value.absent(),
    this.prixVenteSuggere = const Value.absent(),
    this.stockActuel = const Value.absent(),
    this.stockAlerte = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boutiqueId = Value(boutiqueId),
        nom = Value(nom);
  static Insertable<LocalProduit> custom({
    Expression<String>? id,
    Expression<String>? boutiqueId,
    Expression<String>? categorieId,
    Expression<String>? nom,
    Expression<double>? prixAchatMoyen,
    Expression<double>? prixVenteSuggere,
    Expression<int>? stockActuel,
    Expression<int>? stockAlerte,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (categorieId != null) 'categorie_id': categorieId,
      if (nom != null) 'nom': nom,
      if (prixAchatMoyen != null) 'prix_achat_moyen': prixAchatMoyen,
      if (prixVenteSuggere != null) 'prix_vente_suggere': prixVenteSuggere,
      if (stockActuel != null) 'stock_actuel': stockActuel,
      if (stockAlerte != null) 'stock_alerte': stockAlerte,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProduitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? boutiqueId,
      Value<String?>? categorieId,
      Value<String>? nom,
      Value<double>? prixAchatMoyen,
      Value<double>? prixVenteSuggere,
      Value<int>? stockActuel,
      Value<int>? stockAlerte,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalProduitsCompanion(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      categorieId: categorieId ?? this.categorieId,
      nom: nom ?? this.nom,
      prixAchatMoyen: prixAchatMoyen ?? this.prixAchatMoyen,
      prixVenteSuggere: prixVenteSuggere ?? this.prixVenteSuggere,
      stockActuel: stockActuel ?? this.stockActuel,
      stockAlerte: stockAlerte ?? this.stockAlerte,
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
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (categorieId.present) {
      map['categorie_id'] = Variable<String>(categorieId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prixAchatMoyen.present) {
      map['prix_achat_moyen'] = Variable<double>(prixAchatMoyen.value);
    }
    if (prixVenteSuggere.present) {
      map['prix_vente_suggere'] = Variable<double>(prixVenteSuggere.value);
    }
    if (stockActuel.present) {
      map['stock_actuel'] = Variable<int>(stockActuel.value);
    }
    if (stockAlerte.present) {
      map['stock_alerte'] = Variable<int>(stockAlerte.value);
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
    return (StringBuffer('LocalProduitsCompanion(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prixAchatMoyen: $prixAchatMoyen, ')
          ..write('prixVenteSuggere: $prixVenteSuggere, ')
          ..write('stockActuel: $stockActuel, ')
          ..write('stockAlerte: $stockAlerte, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, boutiqueId, nom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String boutiqueId;
  final String nom;
  const LocalCategory(
      {required this.id, required this.boutiqueId, required this.nom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boutique_id'] = Variable<String>(boutiqueId);
    map['nom'] = Variable<String>(nom);
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      boutiqueId: Value(boutiqueId),
      nom: Value(nom),
    );
  }

  factory LocalCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      nom: serializer.fromJson<String>(json['nom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'nom': serializer.toJson<String>(nom),
    };
  }

  LocalCategory copyWith({String? id, String? boutiqueId, String? nom}) =>
      LocalCategory(
        id: id ?? this.id,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        nom: nom ?? this.nom,
      );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      nom: data.nom.present ? data.nom.value : this.nom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, boutiqueId, nom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.boutiqueId == this.boutiqueId &&
          other.nom == this.nom);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String> boutiqueId;
  final Value<String> nom;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.nom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    required String boutiqueId,
    required String nom,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boutiqueId = Value(boutiqueId),
        nom = Value(nom);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? boutiqueId,
    Expression<String>? nom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (nom != null) 'nom': nom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? boutiqueId,
      Value<String>? nom,
      Value<int>? rowid}) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      nom: nom ?? this.nom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalVentesTable extends LocalVentes
    with TableInfo<$LocalVentesTable, LocalVente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalVentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idLocalMeta =
      const VerificationMeta('idLocal');
  @override
  late final GeneratedColumn<String> idLocal = GeneratedColumn<String>(
      'id_local', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tierIdMeta = const VerificationMeta('tierId');
  @override
  late final GeneratedColumn<String> tierId = GeneratedColumn<String>(
      'tier_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modePaiementMeta =
      const VerificationMeta('modePaiement');
  @override
  late final GeneratedColumn<String> modePaiement = GeneratedColumn<String>(
      'mode_paiement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montantTotalMeta =
      const VerificationMeta('montantTotal');
  @override
  late final GeneratedColumn<double> montantTotal = GeneratedColumn<double>(
      'montant_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dateVenteMeta =
      const VerificationMeta('dateVente');
  @override
  late final GeneratedColumn<DateTime> dateVente = GeneratedColumn<DateTime>(
      'date_vente', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _serverVenteIdMeta =
      const VerificationMeta('serverVenteId');
  @override
  late final GeneratedColumn<String> serverVenteId = GeneratedColumn<String>(
      'server_vente_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        idLocal,
        boutiqueId,
        sessionId,
        tierId,
        modePaiement,
        montantTotal,
        dateVente,
        synced,
        serverVenteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ventes';
  @override
  VerificationContext validateIntegrity(Insertable<LocalVente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_local')) {
      context.handle(_idLocalMeta,
          idLocal.isAcceptableOrUnknown(data['id_local']!, _idLocalMeta));
    } else if (isInserting) {
      context.missing(_idLocalMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('tier_id')) {
      context.handle(_tierIdMeta,
          tierId.isAcceptableOrUnknown(data['tier_id']!, _tierIdMeta));
    }
    if (data.containsKey('mode_paiement')) {
      context.handle(
          _modePaiementMeta,
          modePaiement.isAcceptableOrUnknown(
              data['mode_paiement']!, _modePaiementMeta));
    } else if (isInserting) {
      context.missing(_modePaiementMeta);
    }
    if (data.containsKey('montant_total')) {
      context.handle(
          _montantTotalMeta,
          montantTotal.isAcceptableOrUnknown(
              data['montant_total']!, _montantTotalMeta));
    }
    if (data.containsKey('date_vente')) {
      context.handle(_dateVenteMeta,
          dateVente.isAcceptableOrUnknown(data['date_vente']!, _dateVenteMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('server_vente_id')) {
      context.handle(
          _serverVenteIdMeta,
          serverVenteId.isAcceptableOrUnknown(
              data['server_vente_id']!, _serverVenteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idLocal};
  @override
  LocalVente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalVente(
      idLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_local'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      tierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tier_id']),
      modePaiement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode_paiement'])!,
      montantTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}montant_total'])!,
      dateVente: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_vente'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      serverVenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_vente_id']),
    );
  }

  @override
  $LocalVentesTable createAlias(String alias) {
    return $LocalVentesTable(attachedDatabase, alias);
  }
}

class LocalVente extends DataClass implements Insertable<LocalVente> {
  final String idLocal;
  final String boutiqueId;
  final String? sessionId;
  final String? tierId;
  final String modePaiement;
  final double montantTotal;
  final DateTime dateVente;
  final bool synced;
  final String? serverVenteId;
  const LocalVente(
      {required this.idLocal,
      required this.boutiqueId,
      this.sessionId,
      this.tierId,
      required this.modePaiement,
      required this.montantTotal,
      required this.dateVente,
      required this.synced,
      this.serverVenteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_local'] = Variable<String>(idLocal);
    map['boutique_id'] = Variable<String>(boutiqueId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || tierId != null) {
      map['tier_id'] = Variable<String>(tierId);
    }
    map['mode_paiement'] = Variable<String>(modePaiement);
    map['montant_total'] = Variable<double>(montantTotal);
    map['date_vente'] = Variable<DateTime>(dateVente);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || serverVenteId != null) {
      map['server_vente_id'] = Variable<String>(serverVenteId);
    }
    return map;
  }

  LocalVentesCompanion toCompanion(bool nullToAbsent) {
    return LocalVentesCompanion(
      idLocal: Value(idLocal),
      boutiqueId: Value(boutiqueId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      tierId:
          tierId == null && nullToAbsent ? const Value.absent() : Value(tierId),
      modePaiement: Value(modePaiement),
      montantTotal: Value(montantTotal),
      dateVente: Value(dateVente),
      synced: Value(synced),
      serverVenteId: serverVenteId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVenteId),
    );
  }

  factory LocalVente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalVente(
      idLocal: serializer.fromJson<String>(json['idLocal']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      tierId: serializer.fromJson<String?>(json['tierId']),
      modePaiement: serializer.fromJson<String>(json['modePaiement']),
      montantTotal: serializer.fromJson<double>(json['montantTotal']),
      dateVente: serializer.fromJson<DateTime>(json['dateVente']),
      synced: serializer.fromJson<bool>(json['synced']),
      serverVenteId: serializer.fromJson<String?>(json['serverVenteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idLocal': serializer.toJson<String>(idLocal),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'tierId': serializer.toJson<String?>(tierId),
      'modePaiement': serializer.toJson<String>(modePaiement),
      'montantTotal': serializer.toJson<double>(montantTotal),
      'dateVente': serializer.toJson<DateTime>(dateVente),
      'synced': serializer.toJson<bool>(synced),
      'serverVenteId': serializer.toJson<String?>(serverVenteId),
    };
  }

  LocalVente copyWith(
          {String? idLocal,
          String? boutiqueId,
          Value<String?> sessionId = const Value.absent(),
          Value<String?> tierId = const Value.absent(),
          String? modePaiement,
          double? montantTotal,
          DateTime? dateVente,
          bool? synced,
          Value<String?> serverVenteId = const Value.absent()}) =>
      LocalVente(
        idLocal: idLocal ?? this.idLocal,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        tierId: tierId.present ? tierId.value : this.tierId,
        modePaiement: modePaiement ?? this.modePaiement,
        montantTotal: montantTotal ?? this.montantTotal,
        dateVente: dateVente ?? this.dateVente,
        synced: synced ?? this.synced,
        serverVenteId:
            serverVenteId.present ? serverVenteId.value : this.serverVenteId,
      );
  LocalVente copyWithCompanion(LocalVentesCompanion data) {
    return LocalVente(
      idLocal: data.idLocal.present ? data.idLocal.value : this.idLocal,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      tierId: data.tierId.present ? data.tierId.value : this.tierId,
      modePaiement: data.modePaiement.present
          ? data.modePaiement.value
          : this.modePaiement,
      montantTotal: data.montantTotal.present
          ? data.montantTotal.value
          : this.montantTotal,
      dateVente: data.dateVente.present ? data.dateVente.value : this.dateVente,
      synced: data.synced.present ? data.synced.value : this.synced,
      serverVenteId: data.serverVenteId.present
          ? data.serverVenteId.value
          : this.serverVenteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalVente(')
          ..write('idLocal: $idLocal, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('sessionId: $sessionId, ')
          ..write('tierId: $tierId, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('montantTotal: $montantTotal, ')
          ..write('dateVente: $dateVente, ')
          ..write('synced: $synced, ')
          ..write('serverVenteId: $serverVenteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idLocal, boutiqueId, sessionId, tierId,
      modePaiement, montantTotal, dateVente, synced, serverVenteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalVente &&
          other.idLocal == this.idLocal &&
          other.boutiqueId == this.boutiqueId &&
          other.sessionId == this.sessionId &&
          other.tierId == this.tierId &&
          other.modePaiement == this.modePaiement &&
          other.montantTotal == this.montantTotal &&
          other.dateVente == this.dateVente &&
          other.synced == this.synced &&
          other.serverVenteId == this.serverVenteId);
}

class LocalVentesCompanion extends UpdateCompanion<LocalVente> {
  final Value<String> idLocal;
  final Value<String> boutiqueId;
  final Value<String?> sessionId;
  final Value<String?> tierId;
  final Value<String> modePaiement;
  final Value<double> montantTotal;
  final Value<DateTime> dateVente;
  final Value<bool> synced;
  final Value<String?> serverVenteId;
  final Value<int> rowid;
  const LocalVentesCompanion({
    this.idLocal = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.tierId = const Value.absent(),
    this.modePaiement = const Value.absent(),
    this.montantTotal = const Value.absent(),
    this.dateVente = const Value.absent(),
    this.synced = const Value.absent(),
    this.serverVenteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalVentesCompanion.insert({
    required String idLocal,
    required String boutiqueId,
    this.sessionId = const Value.absent(),
    this.tierId = const Value.absent(),
    required String modePaiement,
    this.montantTotal = const Value.absent(),
    this.dateVente = const Value.absent(),
    this.synced = const Value.absent(),
    this.serverVenteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : idLocal = Value(idLocal),
        boutiqueId = Value(boutiqueId),
        modePaiement = Value(modePaiement);
  static Insertable<LocalVente> custom({
    Expression<String>? idLocal,
    Expression<String>? boutiqueId,
    Expression<String>? sessionId,
    Expression<String>? tierId,
    Expression<String>? modePaiement,
    Expression<double>? montantTotal,
    Expression<DateTime>? dateVente,
    Expression<bool>? synced,
    Expression<String>? serverVenteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idLocal != null) 'id_local': idLocal,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (sessionId != null) 'session_id': sessionId,
      if (tierId != null) 'tier_id': tierId,
      if (modePaiement != null) 'mode_paiement': modePaiement,
      if (montantTotal != null) 'montant_total': montantTotal,
      if (dateVente != null) 'date_vente': dateVente,
      if (synced != null) 'synced': synced,
      if (serverVenteId != null) 'server_vente_id': serverVenteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalVentesCompanion copyWith(
      {Value<String>? idLocal,
      Value<String>? boutiqueId,
      Value<String?>? sessionId,
      Value<String?>? tierId,
      Value<String>? modePaiement,
      Value<double>? montantTotal,
      Value<DateTime>? dateVente,
      Value<bool>? synced,
      Value<String?>? serverVenteId,
      Value<int>? rowid}) {
    return LocalVentesCompanion(
      idLocal: idLocal ?? this.idLocal,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      sessionId: sessionId ?? this.sessionId,
      tierId: tierId ?? this.tierId,
      modePaiement: modePaiement ?? this.modePaiement,
      montantTotal: montantTotal ?? this.montantTotal,
      dateVente: dateVente ?? this.dateVente,
      synced: synced ?? this.synced,
      serverVenteId: serverVenteId ?? this.serverVenteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idLocal.present) {
      map['id_local'] = Variable<String>(idLocal.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (tierId.present) {
      map['tier_id'] = Variable<String>(tierId.value);
    }
    if (modePaiement.present) {
      map['mode_paiement'] = Variable<String>(modePaiement.value);
    }
    if (montantTotal.present) {
      map['montant_total'] = Variable<double>(montantTotal.value);
    }
    if (dateVente.present) {
      map['date_vente'] = Variable<DateTime>(dateVente.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (serverVenteId.present) {
      map['server_vente_id'] = Variable<String>(serverVenteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalVentesCompanion(')
          ..write('idLocal: $idLocal, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('sessionId: $sessionId, ')
          ..write('tierId: $tierId, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('montantTotal: $montantTotal, ')
          ..write('dateVente: $dateVente, ')
          ..write('synced: $synced, ')
          ..write('serverVenteId: $serverVenteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLignesVenteTable extends LocalLignesVente
    with TableInfo<$LocalLignesVenteTable, LocalLignesVenteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLignesVenteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _venteIdLocalMeta =
      const VerificationMeta('venteIdLocal');
  @override
  late final GeneratedColumn<String> venteIdLocal = GeneratedColumn<String>(
      'vente_id_local', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_ventes (id_local) ON DELETE CASCADE'));
  static const VerificationMeta _produitIdMeta =
      const VerificationMeta('produitId');
  @override
  late final GeneratedColumn<String> produitId = GeneratedColumn<String>(
      'produit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<int> quantite = GeneratedColumn<int>(
      'quantite', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _prixVenduReelMeta =
      const VerificationMeta('prixVenduReel');
  @override
  late final GeneratedColumn<double> prixVenduReel = GeneratedColumn<double>(
      'prix_vendu_reel', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _margeCalculeeMeta =
      const VerificationMeta('margeCalculee');
  @override
  late final GeneratedColumn<double> margeCalculee = GeneratedColumn<double>(
      'marge_calculee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, venteIdLocal, produitId, quantite, prixVenduReel, margeCalculee];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lignes_vente';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalLignesVenteData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vente_id_local')) {
      context.handle(
          _venteIdLocalMeta,
          venteIdLocal.isAcceptableOrUnknown(
              data['vente_id_local']!, _venteIdLocalMeta));
    } else if (isInserting) {
      context.missing(_venteIdLocalMeta);
    }
    if (data.containsKey('produit_id')) {
      context.handle(_produitIdMeta,
          produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta));
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    }
    if (data.containsKey('prix_vendu_reel')) {
      context.handle(
          _prixVenduReelMeta,
          prixVenduReel.isAcceptableOrUnknown(
              data['prix_vendu_reel']!, _prixVenduReelMeta));
    } else if (isInserting) {
      context.missing(_prixVenduReelMeta);
    }
    if (data.containsKey('marge_calculee')) {
      context.handle(
          _margeCalculeeMeta,
          margeCalculee.isAcceptableOrUnknown(
              data['marge_calculee']!, _margeCalculeeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLignesVenteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLignesVenteData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      venteIdLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vente_id_local'])!,
      produitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produit_id']),
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantite'])!,
      prixVenduReel: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}prix_vendu_reel'])!,
      margeCalculee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}marge_calculee'])!,
    );
  }

  @override
  $LocalLignesVenteTable createAlias(String alias) {
    return $LocalLignesVenteTable(attachedDatabase, alias);
  }
}

class LocalLignesVenteData extends DataClass
    implements Insertable<LocalLignesVenteData> {
  final int id;
  final String venteIdLocal;
  final String? produitId;
  final int quantite;
  final double prixVenduReel;
  final double margeCalculee;
  const LocalLignesVenteData(
      {required this.id,
      required this.venteIdLocal,
      this.produitId,
      required this.quantite,
      required this.prixVenduReel,
      required this.margeCalculee});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vente_id_local'] = Variable<String>(venteIdLocal);
    if (!nullToAbsent || produitId != null) {
      map['produit_id'] = Variable<String>(produitId);
    }
    map['quantite'] = Variable<int>(quantite);
    map['prix_vendu_reel'] = Variable<double>(prixVenduReel);
    map['marge_calculee'] = Variable<double>(margeCalculee);
    return map;
  }

  LocalLignesVenteCompanion toCompanion(bool nullToAbsent) {
    return LocalLignesVenteCompanion(
      id: Value(id),
      venteIdLocal: Value(venteIdLocal),
      produitId: produitId == null && nullToAbsent
          ? const Value.absent()
          : Value(produitId),
      quantite: Value(quantite),
      prixVenduReel: Value(prixVenduReel),
      margeCalculee: Value(margeCalculee),
    );
  }

  factory LocalLignesVenteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLignesVenteData(
      id: serializer.fromJson<int>(json['id']),
      venteIdLocal: serializer.fromJson<String>(json['venteIdLocal']),
      produitId: serializer.fromJson<String?>(json['produitId']),
      quantite: serializer.fromJson<int>(json['quantite']),
      prixVenduReel: serializer.fromJson<double>(json['prixVenduReel']),
      margeCalculee: serializer.fromJson<double>(json['margeCalculee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'venteIdLocal': serializer.toJson<String>(venteIdLocal),
      'produitId': serializer.toJson<String?>(produitId),
      'quantite': serializer.toJson<int>(quantite),
      'prixVenduReel': serializer.toJson<double>(prixVenduReel),
      'margeCalculee': serializer.toJson<double>(margeCalculee),
    };
  }

  LocalLignesVenteData copyWith(
          {int? id,
          String? venteIdLocal,
          Value<String?> produitId = const Value.absent(),
          int? quantite,
          double? prixVenduReel,
          double? margeCalculee}) =>
      LocalLignesVenteData(
        id: id ?? this.id,
        venteIdLocal: venteIdLocal ?? this.venteIdLocal,
        produitId: produitId.present ? produitId.value : this.produitId,
        quantite: quantite ?? this.quantite,
        prixVenduReel: prixVenduReel ?? this.prixVenduReel,
        margeCalculee: margeCalculee ?? this.margeCalculee,
      );
  LocalLignesVenteData copyWithCompanion(LocalLignesVenteCompanion data) {
    return LocalLignesVenteData(
      id: data.id.present ? data.id.value : this.id,
      venteIdLocal: data.venteIdLocal.present
          ? data.venteIdLocal.value
          : this.venteIdLocal,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      prixVenduReel: data.prixVenduReel.present
          ? data.prixVenduReel.value
          : this.prixVenduReel,
      margeCalculee: data.margeCalculee.present
          ? data.margeCalculee.value
          : this.margeCalculee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLignesVenteData(')
          ..write('id: $id, ')
          ..write('venteIdLocal: $venteIdLocal, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('prixVenduReel: $prixVenduReel, ')
          ..write('margeCalculee: $margeCalculee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, venteIdLocal, produitId, quantite, prixVenduReel, margeCalculee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLignesVenteData &&
          other.id == this.id &&
          other.venteIdLocal == this.venteIdLocal &&
          other.produitId == this.produitId &&
          other.quantite == this.quantite &&
          other.prixVenduReel == this.prixVenduReel &&
          other.margeCalculee == this.margeCalculee);
}

class LocalLignesVenteCompanion extends UpdateCompanion<LocalLignesVenteData> {
  final Value<int> id;
  final Value<String> venteIdLocal;
  final Value<String?> produitId;
  final Value<int> quantite;
  final Value<double> prixVenduReel;
  final Value<double> margeCalculee;
  const LocalLignesVenteCompanion({
    this.id = const Value.absent(),
    this.venteIdLocal = const Value.absent(),
    this.produitId = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixVenduReel = const Value.absent(),
    this.margeCalculee = const Value.absent(),
  });
  LocalLignesVenteCompanion.insert({
    this.id = const Value.absent(),
    required String venteIdLocal,
    this.produitId = const Value.absent(),
    this.quantite = const Value.absent(),
    required double prixVenduReel,
    this.margeCalculee = const Value.absent(),
  })  : venteIdLocal = Value(venteIdLocal),
        prixVenduReel = Value(prixVenduReel);
  static Insertable<LocalLignesVenteData> custom({
    Expression<int>? id,
    Expression<String>? venteIdLocal,
    Expression<String>? produitId,
    Expression<int>? quantite,
    Expression<double>? prixVenduReel,
    Expression<double>? margeCalculee,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (venteIdLocal != null) 'vente_id_local': venteIdLocal,
      if (produitId != null) 'produit_id': produitId,
      if (quantite != null) 'quantite': quantite,
      if (prixVenduReel != null) 'prix_vendu_reel': prixVenduReel,
      if (margeCalculee != null) 'marge_calculee': margeCalculee,
    });
  }

  LocalLignesVenteCompanion copyWith(
      {Value<int>? id,
      Value<String>? venteIdLocal,
      Value<String?>? produitId,
      Value<int>? quantite,
      Value<double>? prixVenduReel,
      Value<double>? margeCalculee}) {
    return LocalLignesVenteCompanion(
      id: id ?? this.id,
      venteIdLocal: venteIdLocal ?? this.venteIdLocal,
      produitId: produitId ?? this.produitId,
      quantite: quantite ?? this.quantite,
      prixVenduReel: prixVenduReel ?? this.prixVenduReel,
      margeCalculee: margeCalculee ?? this.margeCalculee,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (venteIdLocal.present) {
      map['vente_id_local'] = Variable<String>(venteIdLocal.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<String>(produitId.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<int>(quantite.value);
    }
    if (prixVenduReel.present) {
      map['prix_vendu_reel'] = Variable<double>(prixVenduReel.value);
    }
    if (margeCalculee.present) {
      map['marge_calculee'] = Variable<double>(margeCalculee.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLignesVenteCompanion(')
          ..write('id: $id, ')
          ..write('venteIdLocal: $venteIdLocal, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('prixVenduReel: $prixVenduReel, ')
          ..write('margeCalculee: $margeCalculee')
          ..write(')'))
        .toString();
  }
}

class $LocalDepensesTable extends LocalDepenses
    with TableInfo<$LocalDepensesTable, LocalDepense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDepensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idLocalMeta =
      const VerificationMeta('idLocal');
  @override
  late final GeneratedColumn<String> idLocal = GeneratedColumn<String>(
      'id_local', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _montantMeta =
      const VerificationMeta('montant');
  @override
  late final GeneratedColumn<double> montant = GeneratedColumn<double>(
      'montant', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _motifMeta = const VerificationMeta('motif');
  @override
  late final GeneratedColumn<String> motif = GeneratedColumn<String>(
      'motif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateTransactionMeta =
      const VerificationMeta('dateTransaction');
  @override
  late final GeneratedColumn<DateTime> dateTransaction =
      GeneratedColumn<DateTime>('date_transaction', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [idLocal, boutiqueId, sessionId, montant, motif, dateTransaction, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_depenses';
  @override
  VerificationContext validateIntegrity(Insertable<LocalDepense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_local')) {
      context.handle(_idLocalMeta,
          idLocal.isAcceptableOrUnknown(data['id_local']!, _idLocalMeta));
    } else if (isInserting) {
      context.missing(_idLocalMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('montant')) {
      context.handle(_montantMeta,
          montant.isAcceptableOrUnknown(data['montant']!, _montantMeta));
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('motif')) {
      context.handle(
          _motifMeta, motif.isAcceptableOrUnknown(data['motif']!, _motifMeta));
    } else if (isInserting) {
      context.missing(_motifMeta);
    }
    if (data.containsKey('date_transaction')) {
      context.handle(
          _dateTransactionMeta,
          dateTransaction.isAcceptableOrUnknown(
              data['date_transaction']!, _dateTransactionMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idLocal};
  @override
  LocalDepense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDepense(
      idLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_local'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      montant: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}montant'])!,
      motif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motif'])!,
      dateTransaction: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_transaction'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $LocalDepensesTable createAlias(String alias) {
    return $LocalDepensesTable(attachedDatabase, alias);
  }
}

class LocalDepense extends DataClass implements Insertable<LocalDepense> {
  final String idLocal;
  final String boutiqueId;
  final String? sessionId;
  final double montant;
  final String motif;
  final DateTime dateTransaction;
  final bool synced;
  const LocalDepense(
      {required this.idLocal,
      required this.boutiqueId,
      this.sessionId,
      required this.montant,
      required this.motif,
      required this.dateTransaction,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_local'] = Variable<String>(idLocal);
    map['boutique_id'] = Variable<String>(boutiqueId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['montant'] = Variable<double>(montant);
    map['motif'] = Variable<String>(motif);
    map['date_transaction'] = Variable<DateTime>(dateTransaction);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalDepensesCompanion toCompanion(bool nullToAbsent) {
    return LocalDepensesCompanion(
      idLocal: Value(idLocal),
      boutiqueId: Value(boutiqueId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      montant: Value(montant),
      motif: Value(motif),
      dateTransaction: Value(dateTransaction),
      synced: Value(synced),
    );
  }

  factory LocalDepense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDepense(
      idLocal: serializer.fromJson<String>(json['idLocal']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      montant: serializer.fromJson<double>(json['montant']),
      motif: serializer.fromJson<String>(json['motif']),
      dateTransaction: serializer.fromJson<DateTime>(json['dateTransaction']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idLocal': serializer.toJson<String>(idLocal),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'montant': serializer.toJson<double>(montant),
      'motif': serializer.toJson<String>(motif),
      'dateTransaction': serializer.toJson<DateTime>(dateTransaction),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalDepense copyWith(
          {String? idLocal,
          String? boutiqueId,
          Value<String?> sessionId = const Value.absent(),
          double? montant,
          String? motif,
          DateTime? dateTransaction,
          bool? synced}) =>
      LocalDepense(
        idLocal: idLocal ?? this.idLocal,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        montant: montant ?? this.montant,
        motif: motif ?? this.motif,
        dateTransaction: dateTransaction ?? this.dateTransaction,
        synced: synced ?? this.synced,
      );
  LocalDepense copyWithCompanion(LocalDepensesCompanion data) {
    return LocalDepense(
      idLocal: data.idLocal.present ? data.idLocal.value : this.idLocal,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      montant: data.montant.present ? data.montant.value : this.montant,
      motif: data.motif.present ? data.motif.value : this.motif,
      dateTransaction: data.dateTransaction.present
          ? data.dateTransaction.value
          : this.dateTransaction,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDepense(')
          ..write('idLocal: $idLocal, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('sessionId: $sessionId, ')
          ..write('montant: $montant, ')
          ..write('motif: $motif, ')
          ..write('dateTransaction: $dateTransaction, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      idLocal, boutiqueId, sessionId, montant, motif, dateTransaction, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDepense &&
          other.idLocal == this.idLocal &&
          other.boutiqueId == this.boutiqueId &&
          other.sessionId == this.sessionId &&
          other.montant == this.montant &&
          other.motif == this.motif &&
          other.dateTransaction == this.dateTransaction &&
          other.synced == this.synced);
}

class LocalDepensesCompanion extends UpdateCompanion<LocalDepense> {
  final Value<String> idLocal;
  final Value<String> boutiqueId;
  final Value<String?> sessionId;
  final Value<double> montant;
  final Value<String> motif;
  final Value<DateTime> dateTransaction;
  final Value<bool> synced;
  final Value<int> rowid;
  const LocalDepensesCompanion({
    this.idLocal = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.montant = const Value.absent(),
    this.motif = const Value.absent(),
    this.dateTransaction = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDepensesCompanion.insert({
    required String idLocal,
    required String boutiqueId,
    this.sessionId = const Value.absent(),
    required double montant,
    required String motif,
    this.dateTransaction = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : idLocal = Value(idLocal),
        boutiqueId = Value(boutiqueId),
        montant = Value(montant),
        motif = Value(motif);
  static Insertable<LocalDepense> custom({
    Expression<String>? idLocal,
    Expression<String>? boutiqueId,
    Expression<String>? sessionId,
    Expression<double>? montant,
    Expression<String>? motif,
    Expression<DateTime>? dateTransaction,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idLocal != null) 'id_local': idLocal,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (sessionId != null) 'session_id': sessionId,
      if (montant != null) 'montant': montant,
      if (motif != null) 'motif': motif,
      if (dateTransaction != null) 'date_transaction': dateTransaction,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDepensesCompanion copyWith(
      {Value<String>? idLocal,
      Value<String>? boutiqueId,
      Value<String?>? sessionId,
      Value<double>? montant,
      Value<String>? motif,
      Value<DateTime>? dateTransaction,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return LocalDepensesCompanion(
      idLocal: idLocal ?? this.idLocal,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      sessionId: sessionId ?? this.sessionId,
      montant: montant ?? this.montant,
      motif: motif ?? this.motif,
      dateTransaction: dateTransaction ?? this.dateTransaction,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idLocal.present) {
      map['id_local'] = Variable<String>(idLocal.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (montant.present) {
      map['montant'] = Variable<double>(montant.value);
    }
    if (motif.present) {
      map['motif'] = Variable<String>(motif.value);
    }
    if (dateTransaction.present) {
      map['date_transaction'] = Variable<DateTime>(dateTransaction.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDepensesCompanion(')
          ..write('idLocal: $idLocal, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('sessionId: $sessionId, ')
          ..write('montant: $montant, ')
          ..write('motif: $motif, ')
          ..write('dateTransaction: $dateTransaction, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSessionsTable extends LocalSessions
    with TableInfo<$LocalSessionsTable, LocalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _utilisateurNomMeta =
      const VerificationMeta('utilisateurNom');
  @override
  late final GeneratedColumn<String> utilisateurNom = GeneratedColumn<String>(
      'utilisateur_nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateOuvertureMeta =
      const VerificationMeta('dateOuverture');
  @override
  late final GeneratedColumn<DateTime> dateOuverture =
      GeneratedColumn<DateTime>('date_ouverture', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _dateFermetureMeta =
      const VerificationMeta('dateFermeture');
  @override
  late final GeneratedColumn<DateTime> dateFermeture =
      GeneratedColumn<DateTime>('date_fermeture', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _montantInitialMeta =
      const VerificationMeta('montantInitial');
  @override
  late final GeneratedColumn<double> montantInitial = GeneratedColumn<double>(
      'montant_initial', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _montantFinalDeclareMeta =
      const VerificationMeta('montantFinalDeclare');
  @override
  late final GeneratedColumn<double> montantFinalDeclare =
      GeneratedColumn<double>('montant_final_declare', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OUVERT'));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        boutiqueId,
        utilisateurNom,
        dateOuverture,
        dateFermeture,
        montantInitial,
        montantFinalDeclare,
        statut,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('utilisateur_nom')) {
      context.handle(
          _utilisateurNomMeta,
          utilisateurNom.isAcceptableOrUnknown(
              data['utilisateur_nom']!, _utilisateurNomMeta));
    } else if (isInserting) {
      context.missing(_utilisateurNomMeta);
    }
    if (data.containsKey('date_ouverture')) {
      context.handle(
          _dateOuvertureMeta,
          dateOuverture.isAcceptableOrUnknown(
              data['date_ouverture']!, _dateOuvertureMeta));
    }
    if (data.containsKey('date_fermeture')) {
      context.handle(
          _dateFermetureMeta,
          dateFermeture.isAcceptableOrUnknown(
              data['date_fermeture']!, _dateFermetureMeta));
    }
    if (data.containsKey('montant_initial')) {
      context.handle(
          _montantInitialMeta,
          montantInitial.isAcceptableOrUnknown(
              data['montant_initial']!, _montantInitialMeta));
    }
    if (data.containsKey('montant_final_declare')) {
      context.handle(
          _montantFinalDeclareMeta,
          montantFinalDeclare.isAcceptableOrUnknown(
              data['montant_final_declare']!, _montantFinalDeclareMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      utilisateurNom: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}utilisateur_nom'])!,
      dateOuverture: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_ouverture'])!,
      dateFermeture: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_fermeture']),
      montantInitial: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}montant_initial'])!,
      montantFinalDeclare: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}montant_final_declare']),
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $LocalSessionsTable createAlias(String alias) {
    return $LocalSessionsTable(attachedDatabase, alias);
  }
}

class LocalSession extends DataClass implements Insertable<LocalSession> {
  final String id;
  final String boutiqueId;
  final String utilisateurNom;
  final DateTime dateOuverture;
  final DateTime? dateFermeture;
  final double montantInitial;
  final double? montantFinalDeclare;
  final String statut;
  final bool synced;
  const LocalSession(
      {required this.id,
      required this.boutiqueId,
      required this.utilisateurNom,
      required this.dateOuverture,
      this.dateFermeture,
      required this.montantInitial,
      this.montantFinalDeclare,
      required this.statut,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boutique_id'] = Variable<String>(boutiqueId);
    map['utilisateur_nom'] = Variable<String>(utilisateurNom);
    map['date_ouverture'] = Variable<DateTime>(dateOuverture);
    if (!nullToAbsent || dateFermeture != null) {
      map['date_fermeture'] = Variable<DateTime>(dateFermeture);
    }
    map['montant_initial'] = Variable<double>(montantInitial);
    if (!nullToAbsent || montantFinalDeclare != null) {
      map['montant_final_declare'] = Variable<double>(montantFinalDeclare);
    }
    map['statut'] = Variable<String>(statut);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionsCompanion(
      id: Value(id),
      boutiqueId: Value(boutiqueId),
      utilisateurNom: Value(utilisateurNom),
      dateOuverture: Value(dateOuverture),
      dateFermeture: dateFermeture == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFermeture),
      montantInitial: Value(montantInitial),
      montantFinalDeclare: montantFinalDeclare == null && nullToAbsent
          ? const Value.absent()
          : Value(montantFinalDeclare),
      statut: Value(statut),
      synced: Value(synced),
    );
  }

  factory LocalSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSession(
      id: serializer.fromJson<String>(json['id']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      utilisateurNom: serializer.fromJson<String>(json['utilisateurNom']),
      dateOuverture: serializer.fromJson<DateTime>(json['dateOuverture']),
      dateFermeture: serializer.fromJson<DateTime?>(json['dateFermeture']),
      montantInitial: serializer.fromJson<double>(json['montantInitial']),
      montantFinalDeclare:
          serializer.fromJson<double?>(json['montantFinalDeclare']),
      statut: serializer.fromJson<String>(json['statut']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'utilisateurNom': serializer.toJson<String>(utilisateurNom),
      'dateOuverture': serializer.toJson<DateTime>(dateOuverture),
      'dateFermeture': serializer.toJson<DateTime?>(dateFermeture),
      'montantInitial': serializer.toJson<double>(montantInitial),
      'montantFinalDeclare': serializer.toJson<double?>(montantFinalDeclare),
      'statut': serializer.toJson<String>(statut),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalSession copyWith(
          {String? id,
          String? boutiqueId,
          String? utilisateurNom,
          DateTime? dateOuverture,
          Value<DateTime?> dateFermeture = const Value.absent(),
          double? montantInitial,
          Value<double?> montantFinalDeclare = const Value.absent(),
          String? statut,
          bool? synced}) =>
      LocalSession(
        id: id ?? this.id,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        utilisateurNom: utilisateurNom ?? this.utilisateurNom,
        dateOuverture: dateOuverture ?? this.dateOuverture,
        dateFermeture:
            dateFermeture.present ? dateFermeture.value : this.dateFermeture,
        montantInitial: montantInitial ?? this.montantInitial,
        montantFinalDeclare: montantFinalDeclare.present
            ? montantFinalDeclare.value
            : this.montantFinalDeclare,
        statut: statut ?? this.statut,
        synced: synced ?? this.synced,
      );
  LocalSession copyWithCompanion(LocalSessionsCompanion data) {
    return LocalSession(
      id: data.id.present ? data.id.value : this.id,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      utilisateurNom: data.utilisateurNom.present
          ? data.utilisateurNom.value
          : this.utilisateurNom,
      dateOuverture: data.dateOuverture.present
          ? data.dateOuverture.value
          : this.dateOuverture,
      dateFermeture: data.dateFermeture.present
          ? data.dateFermeture.value
          : this.dateFermeture,
      montantInitial: data.montantInitial.present
          ? data.montantInitial.value
          : this.montantInitial,
      montantFinalDeclare: data.montantFinalDeclare.present
          ? data.montantFinalDeclare.value
          : this.montantFinalDeclare,
      statut: data.statut.present ? data.statut.value : this.statut,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSession(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('utilisateurNom: $utilisateurNom, ')
          ..write('dateOuverture: $dateOuverture, ')
          ..write('dateFermeture: $dateFermeture, ')
          ..write('montantInitial: $montantInitial, ')
          ..write('montantFinalDeclare: $montantFinalDeclare, ')
          ..write('statut: $statut, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, boutiqueId, utilisateurNom, dateOuverture,
      dateFermeture, montantInitial, montantFinalDeclare, statut, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSession &&
          other.id == this.id &&
          other.boutiqueId == this.boutiqueId &&
          other.utilisateurNom == this.utilisateurNom &&
          other.dateOuverture == this.dateOuverture &&
          other.dateFermeture == this.dateFermeture &&
          other.montantInitial == this.montantInitial &&
          other.montantFinalDeclare == this.montantFinalDeclare &&
          other.statut == this.statut &&
          other.synced == this.synced);
}

class LocalSessionsCompanion extends UpdateCompanion<LocalSession> {
  final Value<String> id;
  final Value<String> boutiqueId;
  final Value<String> utilisateurNom;
  final Value<DateTime> dateOuverture;
  final Value<DateTime?> dateFermeture;
  final Value<double> montantInitial;
  final Value<double?> montantFinalDeclare;
  final Value<String> statut;
  final Value<bool> synced;
  final Value<int> rowid;
  const LocalSessionsCompanion({
    this.id = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.utilisateurNom = const Value.absent(),
    this.dateOuverture = const Value.absent(),
    this.dateFermeture = const Value.absent(),
    this.montantInitial = const Value.absent(),
    this.montantFinalDeclare = const Value.absent(),
    this.statut = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionsCompanion.insert({
    required String id,
    required String boutiqueId,
    required String utilisateurNom,
    this.dateOuverture = const Value.absent(),
    this.dateFermeture = const Value.absent(),
    this.montantInitial = const Value.absent(),
    this.montantFinalDeclare = const Value.absent(),
    this.statut = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boutiqueId = Value(boutiqueId),
        utilisateurNom = Value(utilisateurNom);
  static Insertable<LocalSession> custom({
    Expression<String>? id,
    Expression<String>? boutiqueId,
    Expression<String>? utilisateurNom,
    Expression<DateTime>? dateOuverture,
    Expression<DateTime>? dateFermeture,
    Expression<double>? montantInitial,
    Expression<double>? montantFinalDeclare,
    Expression<String>? statut,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (utilisateurNom != null) 'utilisateur_nom': utilisateurNom,
      if (dateOuverture != null) 'date_ouverture': dateOuverture,
      if (dateFermeture != null) 'date_fermeture': dateFermeture,
      if (montantInitial != null) 'montant_initial': montantInitial,
      if (montantFinalDeclare != null)
        'montant_final_declare': montantFinalDeclare,
      if (statut != null) 'statut': statut,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? boutiqueId,
      Value<String>? utilisateurNom,
      Value<DateTime>? dateOuverture,
      Value<DateTime?>? dateFermeture,
      Value<double>? montantInitial,
      Value<double?>? montantFinalDeclare,
      Value<String>? statut,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return LocalSessionsCompanion(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      utilisateurNom: utilisateurNom ?? this.utilisateurNom,
      dateOuverture: dateOuverture ?? this.dateOuverture,
      dateFermeture: dateFermeture ?? this.dateFermeture,
      montantInitial: montantInitial ?? this.montantInitial,
      montantFinalDeclare: montantFinalDeclare ?? this.montantFinalDeclare,
      statut: statut ?? this.statut,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (utilisateurNom.present) {
      map['utilisateur_nom'] = Variable<String>(utilisateurNom.value);
    }
    if (dateOuverture.present) {
      map['date_ouverture'] = Variable<DateTime>(dateOuverture.value);
    }
    if (dateFermeture.present) {
      map['date_fermeture'] = Variable<DateTime>(dateFermeture.value);
    }
    if (montantInitial.present) {
      map['montant_initial'] = Variable<double>(montantInitial.value);
    }
    if (montantFinalDeclare.present) {
      map['montant_final_declare'] =
          Variable<double>(montantFinalDeclare.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('utilisateurNom: $utilisateurNom, ')
          ..write('dateOuverture: $dateOuverture, ')
          ..write('dateFermeture: $dateFermeture, ')
          ..write('montantInitial: $montantInitial, ')
          ..write('montantFinalDeclare: $montantFinalDeclare, ')
          ..write('statut: $statut, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTiersTable extends LocalTiers
    with TableInfo<$LocalTiersTable, LocalTier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telephoneMeta =
      const VerificationMeta('telephone');
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
      'telephone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeTiersMeta =
      const VerificationMeta('typeTiers');
  @override
  late final GeneratedColumn<String> typeTiers = GeneratedColumn<String>(
      'type_tiers', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _soldeDuMeta =
      const VerificationMeta('soldeDu');
  @override
  late final GeneratedColumn<double> soldeDu = GeneratedColumn<double>(
      'solde_du', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, boutiqueId, nom, telephone, typeTiers, soldeDu, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tiers';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('telephone')) {
      context.handle(_telephoneMeta,
          telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta));
    }
    if (data.containsKey('type_tiers')) {
      context.handle(_typeTiersMeta,
          typeTiers.isAcceptableOrUnknown(data['type_tiers']!, _typeTiersMeta));
    } else if (isInserting) {
      context.missing(_typeTiersMeta);
    }
    if (data.containsKey('solde_du')) {
      context.handle(_soldeDuMeta,
          soldeDu.isAcceptableOrUnknown(data['solde_du']!, _soldeDuMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      telephone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telephone']),
      typeTiers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_tiers'])!,
      soldeDu: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}solde_du'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $LocalTiersTable createAlias(String alias) {
    return $LocalTiersTable(attachedDatabase, alias);
  }
}

class LocalTier extends DataClass implements Insertable<LocalTier> {
  final String id;
  final String boutiqueId;
  final String nom;
  final String? telephone;
  final String typeTiers;
  final double soldeDu;
  final bool synced;
  const LocalTier(
      {required this.id,
      required this.boutiqueId,
      required this.nom,
      this.telephone,
      required this.typeTiers,
      required this.soldeDu,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boutique_id'] = Variable<String>(boutiqueId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    map['type_tiers'] = Variable<String>(typeTiers);
    map['solde_du'] = Variable<double>(soldeDu);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalTiersCompanion toCompanion(bool nullToAbsent) {
    return LocalTiersCompanion(
      id: Value(id),
      boutiqueId: Value(boutiqueId),
      nom: Value(nom),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      typeTiers: Value(typeTiers),
      soldeDu: Value(soldeDu),
      synced: Value(synced),
    );
  }

  factory LocalTier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTier(
      id: serializer.fromJson<String>(json['id']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      nom: serializer.fromJson<String>(json['nom']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      typeTiers: serializer.fromJson<String>(json['typeTiers']),
      soldeDu: serializer.fromJson<double>(json['soldeDu']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'nom': serializer.toJson<String>(nom),
      'telephone': serializer.toJson<String?>(telephone),
      'typeTiers': serializer.toJson<String>(typeTiers),
      'soldeDu': serializer.toJson<double>(soldeDu),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalTier copyWith(
          {String? id,
          String? boutiqueId,
          String? nom,
          Value<String?> telephone = const Value.absent(),
          String? typeTiers,
          double? soldeDu,
          bool? synced}) =>
      LocalTier(
        id: id ?? this.id,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        nom: nom ?? this.nom,
        telephone: telephone.present ? telephone.value : this.telephone,
        typeTiers: typeTiers ?? this.typeTiers,
        soldeDu: soldeDu ?? this.soldeDu,
        synced: synced ?? this.synced,
      );
  LocalTier copyWithCompanion(LocalTiersCompanion data) {
    return LocalTier(
      id: data.id.present ? data.id.value : this.id,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      nom: data.nom.present ? data.nom.value : this.nom,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      typeTiers: data.typeTiers.present ? data.typeTiers.value : this.typeTiers,
      soldeDu: data.soldeDu.present ? data.soldeDu.value : this.soldeDu,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTier(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('typeTiers: $typeTiers, ')
          ..write('soldeDu: $soldeDu, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, boutiqueId, nom, telephone, typeTiers, soldeDu, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTier &&
          other.id == this.id &&
          other.boutiqueId == this.boutiqueId &&
          other.nom == this.nom &&
          other.telephone == this.telephone &&
          other.typeTiers == this.typeTiers &&
          other.soldeDu == this.soldeDu &&
          other.synced == this.synced);
}

class LocalTiersCompanion extends UpdateCompanion<LocalTier> {
  final Value<String> id;
  final Value<String> boutiqueId;
  final Value<String> nom;
  final Value<String?> telephone;
  final Value<String> typeTiers;
  final Value<double> soldeDu;
  final Value<bool> synced;
  final Value<int> rowid;
  const LocalTiersCompanion({
    this.id = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.nom = const Value.absent(),
    this.telephone = const Value.absent(),
    this.typeTiers = const Value.absent(),
    this.soldeDu = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTiersCompanion.insert({
    required String id,
    required String boutiqueId,
    required String nom,
    this.telephone = const Value.absent(),
    required String typeTiers,
    this.soldeDu = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boutiqueId = Value(boutiqueId),
        nom = Value(nom),
        typeTiers = Value(typeTiers);
  static Insertable<LocalTier> custom({
    Expression<String>? id,
    Expression<String>? boutiqueId,
    Expression<String>? nom,
    Expression<String>? telephone,
    Expression<String>? typeTiers,
    Expression<double>? soldeDu,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (typeTiers != null) 'type_tiers': typeTiers,
      if (soldeDu != null) 'solde_du': soldeDu,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTiersCompanion copyWith(
      {Value<String>? id,
      Value<String>? boutiqueId,
      Value<String>? nom,
      Value<String?>? telephone,
      Value<String>? typeTiers,
      Value<double>? soldeDu,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return LocalTiersCompanion(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      typeTiers: typeTiers ?? this.typeTiers,
      soldeDu: soldeDu ?? this.soldeDu,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (typeTiers.present) {
      map['type_tiers'] = Variable<String>(typeTiers.value);
    }
    if (soldeDu.present) {
      map['solde_du'] = Variable<double>(soldeDu.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTiersCompanion(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('typeTiers: $typeTiers, ')
          ..write('soldeDu: $soldeDu, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMouvementsStockTable extends LocalMouvementsStock
    with TableInfo<$LocalMouvementsStockTable, LocalMouvementsStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMouvementsStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boutiqueIdMeta =
      const VerificationMeta('boutiqueId');
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
      'boutique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _produitIdMeta =
      const VerificationMeta('produitId');
  @override
  late final GeneratedColumn<String> produitId = GeneratedColumn<String>(
      'produit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _produitNomMeta =
      const VerificationMeta('produitNom');
  @override
  late final GeneratedColumn<String> produitNom = GeneratedColumn<String>(
      'produit_nom', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _typeMouvementMeta =
      const VerificationMeta('typeMouvement');
  @override
  late final GeneratedColumn<String> typeMouvement = GeneratedColumn<String>(
      'type_mouvement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<int> quantite = GeneratedColumn<int>(
      'quantite', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _motifMeta = const VerificationMeta('motif');
  @override
  late final GeneratedColumn<String> motif = GeneratedColumn<String>(
      'motif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _auteurIdMeta =
      const VerificationMeta('auteurId');
  @override
  late final GeneratedColumn<String> auteurId = GeneratedColumn<String>(
      'auteur_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _auteurNomMeta =
      const VerificationMeta('auteurNom');
  @override
  late final GeneratedColumn<String> auteurNom = GeneratedColumn<String>(
      'auteur_nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMouvementMeta =
      const VerificationMeta('dateMouvement');
  @override
  late final GeneratedColumn<DateTime> dateMouvement =
      GeneratedColumn<DateTime>('date_mouvement', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        boutiqueId,
        produitId,
        produitNom,
        typeMouvement,
        quantite,
        motif,
        auteurId,
        auteurNom,
        dateMouvement,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_mouvements_stock';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalMouvementsStockData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
          _boutiqueIdMeta,
          boutiqueId.isAcceptableOrUnknown(
              data['boutique_id']!, _boutiqueIdMeta));
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('produit_id')) {
      context.handle(_produitIdMeta,
          produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta));
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('produit_nom')) {
      context.handle(
          _produitNomMeta,
          produitNom.isAcceptableOrUnknown(
              data['produit_nom']!, _produitNomMeta));
    }
    if (data.containsKey('type_mouvement')) {
      context.handle(
          _typeMouvementMeta,
          typeMouvement.isAcceptableOrUnknown(
              data['type_mouvement']!, _typeMouvementMeta));
    } else if (isInserting) {
      context.missing(_typeMouvementMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('motif')) {
      context.handle(
          _motifMeta, motif.isAcceptableOrUnknown(data['motif']!, _motifMeta));
    } else if (isInserting) {
      context.missing(_motifMeta);
    }
    if (data.containsKey('auteur_id')) {
      context.handle(_auteurIdMeta,
          auteurId.isAcceptableOrUnknown(data['auteur_id']!, _auteurIdMeta));
    }
    if (data.containsKey('auteur_nom')) {
      context.handle(_auteurNomMeta,
          auteurNom.isAcceptableOrUnknown(data['auteur_nom']!, _auteurNomMeta));
    } else if (isInserting) {
      context.missing(_auteurNomMeta);
    }
    if (data.containsKey('date_mouvement')) {
      context.handle(
          _dateMouvementMeta,
          dateMouvement.isAcceptableOrUnknown(
              data['date_mouvement']!, _dateMouvementMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMouvementsStockData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMouvementsStockData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boutiqueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boutique_id'])!,
      produitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produit_id'])!,
      produitNom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produit_nom'])!,
      typeMouvement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_mouvement'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantite'])!,
      motif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motif'])!,
      auteurId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auteur_id']),
      auteurNom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auteur_nom'])!,
      dateMouvement: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_mouvement'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $LocalMouvementsStockTable createAlias(String alias) {
    return $LocalMouvementsStockTable(attachedDatabase, alias);
  }
}

class LocalMouvementsStockData extends DataClass
    implements Insertable<LocalMouvementsStockData> {
  final String id;
  final String boutiqueId;
  final String produitId;
  final String produitNom;
  final String typeMouvement;
  final int quantite;
  final String motif;
  final String? auteurId;
  final String auteurNom;
  final DateTime dateMouvement;
  final bool synced;
  const LocalMouvementsStockData(
      {required this.id,
      required this.boutiqueId,
      required this.produitId,
      required this.produitNom,
      required this.typeMouvement,
      required this.quantite,
      required this.motif,
      this.auteurId,
      required this.auteurNom,
      required this.dateMouvement,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boutique_id'] = Variable<String>(boutiqueId);
    map['produit_id'] = Variable<String>(produitId);
    map['produit_nom'] = Variable<String>(produitNom);
    map['type_mouvement'] = Variable<String>(typeMouvement);
    map['quantite'] = Variable<int>(quantite);
    map['motif'] = Variable<String>(motif);
    if (!nullToAbsent || auteurId != null) {
      map['auteur_id'] = Variable<String>(auteurId);
    }
    map['auteur_nom'] = Variable<String>(auteurNom);
    map['date_mouvement'] = Variable<DateTime>(dateMouvement);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalMouvementsStockCompanion toCompanion(bool nullToAbsent) {
    return LocalMouvementsStockCompanion(
      id: Value(id),
      boutiqueId: Value(boutiqueId),
      produitId: Value(produitId),
      produitNom: Value(produitNom),
      typeMouvement: Value(typeMouvement),
      quantite: Value(quantite),
      motif: Value(motif),
      auteurId: auteurId == null && nullToAbsent
          ? const Value.absent()
          : Value(auteurId),
      auteurNom: Value(auteurNom),
      dateMouvement: Value(dateMouvement),
      synced: Value(synced),
    );
  }

  factory LocalMouvementsStockData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMouvementsStockData(
      id: serializer.fromJson<String>(json['id']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      produitId: serializer.fromJson<String>(json['produitId']),
      produitNom: serializer.fromJson<String>(json['produitNom']),
      typeMouvement: serializer.fromJson<String>(json['typeMouvement']),
      quantite: serializer.fromJson<int>(json['quantite']),
      motif: serializer.fromJson<String>(json['motif']),
      auteurId: serializer.fromJson<String?>(json['auteurId']),
      auteurNom: serializer.fromJson<String>(json['auteurNom']),
      dateMouvement: serializer.fromJson<DateTime>(json['dateMouvement']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'produitId': serializer.toJson<String>(produitId),
      'produitNom': serializer.toJson<String>(produitNom),
      'typeMouvement': serializer.toJson<String>(typeMouvement),
      'quantite': serializer.toJson<int>(quantite),
      'motif': serializer.toJson<String>(motif),
      'auteurId': serializer.toJson<String?>(auteurId),
      'auteurNom': serializer.toJson<String>(auteurNom),
      'dateMouvement': serializer.toJson<DateTime>(dateMouvement),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalMouvementsStockData copyWith(
          {String? id,
          String? boutiqueId,
          String? produitId,
          String? produitNom,
          String? typeMouvement,
          int? quantite,
          String? motif,
          Value<String?> auteurId = const Value.absent(),
          String? auteurNom,
          DateTime? dateMouvement,
          bool? synced}) =>
      LocalMouvementsStockData(
        id: id ?? this.id,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        produitId: produitId ?? this.produitId,
        produitNom: produitNom ?? this.produitNom,
        typeMouvement: typeMouvement ?? this.typeMouvement,
        quantite: quantite ?? this.quantite,
        motif: motif ?? this.motif,
        auteurId: auteurId.present ? auteurId.value : this.auteurId,
        auteurNom: auteurNom ?? this.auteurNom,
        dateMouvement: dateMouvement ?? this.dateMouvement,
        synced: synced ?? this.synced,
      );
  LocalMouvementsStockData copyWithCompanion(
      LocalMouvementsStockCompanion data) {
    return LocalMouvementsStockData(
      id: data.id.present ? data.id.value : this.id,
      boutiqueId:
          data.boutiqueId.present ? data.boutiqueId.value : this.boutiqueId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      produitNom:
          data.produitNom.present ? data.produitNom.value : this.produitNom,
      typeMouvement: data.typeMouvement.present
          ? data.typeMouvement.value
          : this.typeMouvement,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      motif: data.motif.present ? data.motif.value : this.motif,
      auteurId: data.auteurId.present ? data.auteurId.value : this.auteurId,
      auteurNom: data.auteurNom.present ? data.auteurNom.value : this.auteurNom,
      dateMouvement: data.dateMouvement.present
          ? data.dateMouvement.value
          : this.dateMouvement,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMouvementsStockData(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('produitId: $produitId, ')
          ..write('produitNom: $produitNom, ')
          ..write('typeMouvement: $typeMouvement, ')
          ..write('quantite: $quantite, ')
          ..write('motif: $motif, ')
          ..write('auteurId: $auteurId, ')
          ..write('auteurNom: $auteurNom, ')
          ..write('dateMouvement: $dateMouvement, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      boutiqueId,
      produitId,
      produitNom,
      typeMouvement,
      quantite,
      motif,
      auteurId,
      auteurNom,
      dateMouvement,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMouvementsStockData &&
          other.id == this.id &&
          other.boutiqueId == this.boutiqueId &&
          other.produitId == this.produitId &&
          other.produitNom == this.produitNom &&
          other.typeMouvement == this.typeMouvement &&
          other.quantite == this.quantite &&
          other.motif == this.motif &&
          other.auteurId == this.auteurId &&
          other.auteurNom == this.auteurNom &&
          other.dateMouvement == this.dateMouvement &&
          other.synced == this.synced);
}

class LocalMouvementsStockCompanion
    extends UpdateCompanion<LocalMouvementsStockData> {
  final Value<String> id;
  final Value<String> boutiqueId;
  final Value<String> produitId;
  final Value<String> produitNom;
  final Value<String> typeMouvement;
  final Value<int> quantite;
  final Value<String> motif;
  final Value<String?> auteurId;
  final Value<String> auteurNom;
  final Value<DateTime> dateMouvement;
  final Value<bool> synced;
  final Value<int> rowid;
  const LocalMouvementsStockCompanion({
    this.id = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.produitNom = const Value.absent(),
    this.typeMouvement = const Value.absent(),
    this.quantite = const Value.absent(),
    this.motif = const Value.absent(),
    this.auteurId = const Value.absent(),
    this.auteurNom = const Value.absent(),
    this.dateMouvement = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMouvementsStockCompanion.insert({
    required String id,
    required String boutiqueId,
    required String produitId,
    this.produitNom = const Value.absent(),
    required String typeMouvement,
    required int quantite,
    required String motif,
    this.auteurId = const Value.absent(),
    required String auteurNom,
    this.dateMouvement = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boutiqueId = Value(boutiqueId),
        produitId = Value(produitId),
        typeMouvement = Value(typeMouvement),
        quantite = Value(quantite),
        motif = Value(motif),
        auteurNom = Value(auteurNom);
  static Insertable<LocalMouvementsStockData> custom({
    Expression<String>? id,
    Expression<String>? boutiqueId,
    Expression<String>? produitId,
    Expression<String>? produitNom,
    Expression<String>? typeMouvement,
    Expression<int>? quantite,
    Expression<String>? motif,
    Expression<String>? auteurId,
    Expression<String>? auteurNom,
    Expression<DateTime>? dateMouvement,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (produitId != null) 'produit_id': produitId,
      if (produitNom != null) 'produit_nom': produitNom,
      if (typeMouvement != null) 'type_mouvement': typeMouvement,
      if (quantite != null) 'quantite': quantite,
      if (motif != null) 'motif': motif,
      if (auteurId != null) 'auteur_id': auteurId,
      if (auteurNom != null) 'auteur_nom': auteurNom,
      if (dateMouvement != null) 'date_mouvement': dateMouvement,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMouvementsStockCompanion copyWith(
      {Value<String>? id,
      Value<String>? boutiqueId,
      Value<String>? produitId,
      Value<String>? produitNom,
      Value<String>? typeMouvement,
      Value<int>? quantite,
      Value<String>? motif,
      Value<String?>? auteurId,
      Value<String>? auteurNom,
      Value<DateTime>? dateMouvement,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return LocalMouvementsStockCompanion(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      produitId: produitId ?? this.produitId,
      produitNom: produitNom ?? this.produitNom,
      typeMouvement: typeMouvement ?? this.typeMouvement,
      quantite: quantite ?? this.quantite,
      motif: motif ?? this.motif,
      auteurId: auteurId ?? this.auteurId,
      auteurNom: auteurNom ?? this.auteurNom,
      dateMouvement: dateMouvement ?? this.dateMouvement,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<String>(produitId.value);
    }
    if (produitNom.present) {
      map['produit_nom'] = Variable<String>(produitNom.value);
    }
    if (typeMouvement.present) {
      map['type_mouvement'] = Variable<String>(typeMouvement.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<int>(quantite.value);
    }
    if (motif.present) {
      map['motif'] = Variable<String>(motif.value);
    }
    if (auteurId.present) {
      map['auteur_id'] = Variable<String>(auteurId.value);
    }
    if (auteurNom.present) {
      map['auteur_nom'] = Variable<String>(auteurNom.value);
    }
    if (dateMouvement.present) {
      map['date_mouvement'] = Variable<DateTime>(dateMouvement.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMouvementsStockCompanion(')
          ..write('id: $id, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('produitId: $produitId, ')
          ..write('produitNom: $produitNom, ')
          ..write('typeMouvement: $typeMouvement, ')
          ..write('quantite: $quantite, ')
          ..write('motif: $motif, ')
          ..write('auteurId: $auteurId, ')
          ..write('auteurNom: $auteurNom, ')
          ..write('dateMouvement: $dateMouvement, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProduitsTable localProduits = $LocalProduitsTable(this);
  late final $LocalCategoriesTable localCategories =
      $LocalCategoriesTable(this);
  late final $LocalVentesTable localVentes = $LocalVentesTable(this);
  late final $LocalLignesVenteTable localLignesVente =
      $LocalLignesVenteTable(this);
  late final $LocalDepensesTable localDepenses = $LocalDepensesTable(this);
  late final $LocalSessionsTable localSessions = $LocalSessionsTable(this);
  late final $LocalTiersTable localTiers = $LocalTiersTable(this);
  late final $LocalMouvementsStockTable localMouvementsStock =
      $LocalMouvementsStockTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localProduits,
        localCategories,
        localVentes,
        localLignesVente,
        localDepenses,
        localSessions,
        localTiers,
        localMouvementsStock
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('local_ventes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('local_lignes_vente', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LocalProduitsTableCreateCompanionBuilder = LocalProduitsCompanion
    Function({
  required String id,
  required String boutiqueId,
  Value<String?> categorieId,
  required String nom,
  Value<double> prixAchatMoyen,
  Value<double> prixVenteSuggere,
  Value<int> stockActuel,
  Value<int> stockAlerte,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalProduitsTableUpdateCompanionBuilder = LocalProduitsCompanion
    Function({
  Value<String> id,
  Value<String> boutiqueId,
  Value<String?> categorieId,
  Value<String> nom,
  Value<double> prixAchatMoyen,
  Value<double> prixVenteSuggere,
  Value<int> stockActuel,
  Value<int> stockAlerte,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalProduitsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProduitsTable> {
  $$LocalProduitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorieId => $composableBuilder(
      column: $table.categorieId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prixAchatMoyen => $composableBuilder(
      column: $table.prixAchatMoyen,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prixVenteSuggere => $composableBuilder(
      column: $table.prixVenteSuggere,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockActuel => $composableBuilder(
      column: $table.stockActuel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockAlerte => $composableBuilder(
      column: $table.stockAlerte, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalProduitsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProduitsTable> {
  $$LocalProduitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorieId => $composableBuilder(
      column: $table.categorieId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prixAchatMoyen => $composableBuilder(
      column: $table.prixAchatMoyen,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prixVenteSuggere => $composableBuilder(
      column: $table.prixVenteSuggere,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockActuel => $composableBuilder(
      column: $table.stockActuel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockAlerte => $composableBuilder(
      column: $table.stockAlerte, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalProduitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProduitsTable> {
  $$LocalProduitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get categorieId => $composableBuilder(
      column: $table.categorieId, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<double> get prixAchatMoyen => $composableBuilder(
      column: $table.prixAchatMoyen, builder: (column) => column);

  GeneratedColumn<double> get prixVenteSuggere => $composableBuilder(
      column: $table.prixVenteSuggere, builder: (column) => column);

  GeneratedColumn<int> get stockActuel => $composableBuilder(
      column: $table.stockActuel, builder: (column) => column);

  GeneratedColumn<int> get stockAlerte => $composableBuilder(
      column: $table.stockAlerte, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalProduitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalProduitsTable,
    LocalProduit,
    $$LocalProduitsTableFilterComposer,
    $$LocalProduitsTableOrderingComposer,
    $$LocalProduitsTableAnnotationComposer,
    $$LocalProduitsTableCreateCompanionBuilder,
    $$LocalProduitsTableUpdateCompanionBuilder,
    (
      LocalProduit,
      BaseReferences<_$AppDatabase, $LocalProduitsTable, LocalProduit>
    ),
    LocalProduit,
    PrefetchHooks Function()> {
  $$LocalProduitsTableTableManager(_$AppDatabase db, $LocalProduitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProduitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProduitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProduitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String?> categorieId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<double> prixAchatMoyen = const Value.absent(),
            Value<double> prixVenteSuggere = const Value.absent(),
            Value<int> stockActuel = const Value.absent(),
            Value<int> stockAlerte = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProduitsCompanion(
            id: id,
            boutiqueId: boutiqueId,
            categorieId: categorieId,
            nom: nom,
            prixAchatMoyen: prixAchatMoyen,
            prixVenteSuggere: prixVenteSuggere,
            stockActuel: stockActuel,
            stockAlerte: stockAlerte,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boutiqueId,
            Value<String?> categorieId = const Value.absent(),
            required String nom,
            Value<double> prixAchatMoyen = const Value.absent(),
            Value<double> prixVenteSuggere = const Value.absent(),
            Value<int> stockActuel = const Value.absent(),
            Value<int> stockAlerte = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProduitsCompanion.insert(
            id: id,
            boutiqueId: boutiqueId,
            categorieId: categorieId,
            nom: nom,
            prixAchatMoyen: prixAchatMoyen,
            prixVenteSuggere: prixVenteSuggere,
            stockActuel: stockActuel,
            stockAlerte: stockAlerte,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalProduitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalProduitsTable,
    LocalProduit,
    $$LocalProduitsTableFilterComposer,
    $$LocalProduitsTableOrderingComposer,
    $$LocalProduitsTableAnnotationComposer,
    $$LocalProduitsTableCreateCompanionBuilder,
    $$LocalProduitsTableUpdateCompanionBuilder,
    (
      LocalProduit,
      BaseReferences<_$AppDatabase, $LocalProduitsTable, LocalProduit>
    ),
    LocalProduit,
    PrefetchHooks Function()>;
typedef $$LocalCategoriesTableCreateCompanionBuilder = LocalCategoriesCompanion
    Function({
  required String id,
  required String boutiqueId,
  required String nom,
  Value<int> rowid,
});
typedef $$LocalCategoriesTableUpdateCompanionBuilder = LocalCategoriesCompanion
    Function({
  Value<String> id,
  Value<String> boutiqueId,
  Value<String> nom,
  Value<int> rowid,
});

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCategoriesTable,
    LocalCategory,
    $$LocalCategoriesTableFilterComposer,
    $$LocalCategoriesTableOrderingComposer,
    $$LocalCategoriesTableAnnotationComposer,
    $$LocalCategoriesTableCreateCompanionBuilder,
    $$LocalCategoriesTableUpdateCompanionBuilder,
    (
      LocalCategory,
      BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>
    ),
    LocalCategory,
    PrefetchHooks Function()> {
  $$LocalCategoriesTableTableManager(
      _$AppDatabase db, $LocalCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCategoriesCompanion(
            id: id,
            boutiqueId: boutiqueId,
            nom: nom,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boutiqueId,
            required String nom,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCategoriesCompanion.insert(
            id: id,
            boutiqueId: boutiqueId,
            nom: nom,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCategoriesTable,
    LocalCategory,
    $$LocalCategoriesTableFilterComposer,
    $$LocalCategoriesTableOrderingComposer,
    $$LocalCategoriesTableAnnotationComposer,
    $$LocalCategoriesTableCreateCompanionBuilder,
    $$LocalCategoriesTableUpdateCompanionBuilder,
    (
      LocalCategory,
      BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>
    ),
    LocalCategory,
    PrefetchHooks Function()>;
typedef $$LocalVentesTableCreateCompanionBuilder = LocalVentesCompanion
    Function({
  required String idLocal,
  required String boutiqueId,
  Value<String?> sessionId,
  Value<String?> tierId,
  required String modePaiement,
  Value<double> montantTotal,
  Value<DateTime> dateVente,
  Value<bool> synced,
  Value<String?> serverVenteId,
  Value<int> rowid,
});
typedef $$LocalVentesTableUpdateCompanionBuilder = LocalVentesCompanion
    Function({
  Value<String> idLocal,
  Value<String> boutiqueId,
  Value<String?> sessionId,
  Value<String?> tierId,
  Value<String> modePaiement,
  Value<double> montantTotal,
  Value<DateTime> dateVente,
  Value<bool> synced,
  Value<String?> serverVenteId,
  Value<int> rowid,
});

final class $$LocalVentesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalVentesTable, LocalVente> {
  $$LocalVentesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalLignesVenteTable, List<LocalLignesVenteData>>
      _localLignesVenteRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localLignesVente,
              aliasName: $_aliasNameGenerator(
                  db.localVentes.idLocal, db.localLignesVente.venteIdLocal));

  $$LocalLignesVenteTableProcessedTableManager get localLignesVenteRefs {
    final manager =
        $$LocalLignesVenteTableTableManager($_db, $_db.localLignesVente).filter(
            (f) => f.venteIdLocal.idLocal
                .sqlEquals($_itemColumn<String>('id_local')!));

    final cache =
        $_typedResult.readTableOrNull(_localLignesVenteRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalVentesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalVentesTable> {
  $$LocalVentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idLocal => $composableBuilder(
      column: $table.idLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tierId => $composableBuilder(
      column: $table.tierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modePaiement => $composableBuilder(
      column: $table.modePaiement, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montantTotal => $composableBuilder(
      column: $table.montantTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateVente => $composableBuilder(
      column: $table.dateVente, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverVenteId => $composableBuilder(
      column: $table.serverVenteId, builder: (column) => ColumnFilters(column));

  Expression<bool> localLignesVenteRefs(
      Expression<bool> Function($$LocalLignesVenteTableFilterComposer f) f) {
    final $$LocalLignesVenteTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idLocal,
        referencedTable: $db.localLignesVente,
        getReferencedColumn: (t) => t.venteIdLocal,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalLignesVenteTableFilterComposer(
              $db: $db,
              $table: $db.localLignesVente,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalVentesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalVentesTable> {
  $$LocalVentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idLocal => $composableBuilder(
      column: $table.idLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tierId => $composableBuilder(
      column: $table.tierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modePaiement => $composableBuilder(
      column: $table.modePaiement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montantTotal => $composableBuilder(
      column: $table.montantTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateVente => $composableBuilder(
      column: $table.dateVente, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverVenteId => $composableBuilder(
      column: $table.serverVenteId,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalVentesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalVentesTable> {
  $$LocalVentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idLocal =>
      $composableBuilder(column: $table.idLocal, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get tierId =>
      $composableBuilder(column: $table.tierId, builder: (column) => column);

  GeneratedColumn<String> get modePaiement => $composableBuilder(
      column: $table.modePaiement, builder: (column) => column);

  GeneratedColumn<double> get montantTotal => $composableBuilder(
      column: $table.montantTotal, builder: (column) => column);

  GeneratedColumn<DateTime> get dateVente =>
      $composableBuilder(column: $table.dateVente, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get serverVenteId => $composableBuilder(
      column: $table.serverVenteId, builder: (column) => column);

  Expression<T> localLignesVenteRefs<T extends Object>(
      Expression<T> Function($$LocalLignesVenteTableAnnotationComposer a) f) {
    final $$LocalLignesVenteTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idLocal,
        referencedTable: $db.localLignesVente,
        getReferencedColumn: (t) => t.venteIdLocal,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalLignesVenteTableAnnotationComposer(
              $db: $db,
              $table: $db.localLignesVente,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalVentesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalVentesTable,
    LocalVente,
    $$LocalVentesTableFilterComposer,
    $$LocalVentesTableOrderingComposer,
    $$LocalVentesTableAnnotationComposer,
    $$LocalVentesTableCreateCompanionBuilder,
    $$LocalVentesTableUpdateCompanionBuilder,
    (LocalVente, $$LocalVentesTableReferences),
    LocalVente,
    PrefetchHooks Function({bool localLignesVenteRefs})> {
  $$LocalVentesTableTableManager(_$AppDatabase db, $LocalVentesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalVentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalVentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalVentesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> idLocal = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String?> tierId = const Value.absent(),
            Value<String> modePaiement = const Value.absent(),
            Value<double> montantTotal = const Value.absent(),
            Value<DateTime> dateVente = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String?> serverVenteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalVentesCompanion(
            idLocal: idLocal,
            boutiqueId: boutiqueId,
            sessionId: sessionId,
            tierId: tierId,
            modePaiement: modePaiement,
            montantTotal: montantTotal,
            dateVente: dateVente,
            synced: synced,
            serverVenteId: serverVenteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String idLocal,
            required String boutiqueId,
            Value<String?> sessionId = const Value.absent(),
            Value<String?> tierId = const Value.absent(),
            required String modePaiement,
            Value<double> montantTotal = const Value.absent(),
            Value<DateTime> dateVente = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String?> serverVenteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalVentesCompanion.insert(
            idLocal: idLocal,
            boutiqueId: boutiqueId,
            sessionId: sessionId,
            tierId: tierId,
            modePaiement: modePaiement,
            montantTotal: montantTotal,
            dateVente: dateVente,
            synced: synced,
            serverVenteId: serverVenteId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalVentesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({localLignesVenteRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localLignesVenteRefs) db.localLignesVente
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localLignesVenteRefs)
                    await $_getPrefetchedData<LocalVente, $LocalVentesTable,
                            LocalLignesVenteData>(
                        currentTable: table,
                        referencedTable: $$LocalVentesTableReferences
                            ._localLignesVenteRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalVentesTableReferences(db, table, p0)
                                .localLignesVenteRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.venteIdLocal == item.idLocal),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalVentesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalVentesTable,
    LocalVente,
    $$LocalVentesTableFilterComposer,
    $$LocalVentesTableOrderingComposer,
    $$LocalVentesTableAnnotationComposer,
    $$LocalVentesTableCreateCompanionBuilder,
    $$LocalVentesTableUpdateCompanionBuilder,
    (LocalVente, $$LocalVentesTableReferences),
    LocalVente,
    PrefetchHooks Function({bool localLignesVenteRefs})>;
typedef $$LocalLignesVenteTableCreateCompanionBuilder
    = LocalLignesVenteCompanion Function({
  Value<int> id,
  required String venteIdLocal,
  Value<String?> produitId,
  Value<int> quantite,
  required double prixVenduReel,
  Value<double> margeCalculee,
});
typedef $$LocalLignesVenteTableUpdateCompanionBuilder
    = LocalLignesVenteCompanion Function({
  Value<int> id,
  Value<String> venteIdLocal,
  Value<String?> produitId,
  Value<int> quantite,
  Value<double> prixVenduReel,
  Value<double> margeCalculee,
});

final class $$LocalLignesVenteTableReferences extends BaseReferences<
    _$AppDatabase, $LocalLignesVenteTable, LocalLignesVenteData> {
  $$LocalLignesVenteTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocalVentesTable _venteIdLocalTable(_$AppDatabase db) =>
      db.localVentes.createAlias($_aliasNameGenerator(
          db.localLignesVente.venteIdLocal, db.localVentes.idLocal));

  $$LocalVentesTableProcessedTableManager get venteIdLocal {
    final $_column = $_itemColumn<String>('vente_id_local')!;

    final manager = $$LocalVentesTableTableManager($_db, $_db.localVentes)
        .filter((f) => f.idLocal.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_venteIdLocalTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalLignesVenteTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLignesVenteTable> {
  $$LocalLignesVenteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produitId => $composableBuilder(
      column: $table.produitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prixVenduReel => $composableBuilder(
      column: $table.prixVenduReel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get margeCalculee => $composableBuilder(
      column: $table.margeCalculee, builder: (column) => ColumnFilters(column));

  $$LocalVentesTableFilterComposer get venteIdLocal {
    final $$LocalVentesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venteIdLocal,
        referencedTable: $db.localVentes,
        getReferencedColumn: (t) => t.idLocal,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalVentesTableFilterComposer(
              $db: $db,
              $table: $db.localVentes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalLignesVenteTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLignesVenteTable> {
  $$LocalLignesVenteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produitId => $composableBuilder(
      column: $table.produitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prixVenduReel => $composableBuilder(
      column: $table.prixVenduReel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get margeCalculee => $composableBuilder(
      column: $table.margeCalculee,
      builder: (column) => ColumnOrderings(column));

  $$LocalVentesTableOrderingComposer get venteIdLocal {
    final $$LocalVentesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venteIdLocal,
        referencedTable: $db.localVentes,
        getReferencedColumn: (t) => t.idLocal,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalVentesTableOrderingComposer(
              $db: $db,
              $table: $db.localVentes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalLignesVenteTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLignesVenteTable> {
  $$LocalLignesVenteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get produitId =>
      $composableBuilder(column: $table.produitId, builder: (column) => column);

  GeneratedColumn<int> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<double> get prixVenduReel => $composableBuilder(
      column: $table.prixVenduReel, builder: (column) => column);

  GeneratedColumn<double> get margeCalculee => $composableBuilder(
      column: $table.margeCalculee, builder: (column) => column);

  $$LocalVentesTableAnnotationComposer get venteIdLocal {
    final $$LocalVentesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.venteIdLocal,
        referencedTable: $db.localVentes,
        getReferencedColumn: (t) => t.idLocal,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalVentesTableAnnotationComposer(
              $db: $db,
              $table: $db.localVentes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalLignesVenteTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalLignesVenteTable,
    LocalLignesVenteData,
    $$LocalLignesVenteTableFilterComposer,
    $$LocalLignesVenteTableOrderingComposer,
    $$LocalLignesVenteTableAnnotationComposer,
    $$LocalLignesVenteTableCreateCompanionBuilder,
    $$LocalLignesVenteTableUpdateCompanionBuilder,
    (LocalLignesVenteData, $$LocalLignesVenteTableReferences),
    LocalLignesVenteData,
    PrefetchHooks Function({bool venteIdLocal})> {
  $$LocalLignesVenteTableTableManager(
      _$AppDatabase db, $LocalLignesVenteTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLignesVenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLignesVenteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLignesVenteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> venteIdLocal = const Value.absent(),
            Value<String?> produitId = const Value.absent(),
            Value<int> quantite = const Value.absent(),
            Value<double> prixVenduReel = const Value.absent(),
            Value<double> margeCalculee = const Value.absent(),
          }) =>
              LocalLignesVenteCompanion(
            id: id,
            venteIdLocal: venteIdLocal,
            produitId: produitId,
            quantite: quantite,
            prixVenduReel: prixVenduReel,
            margeCalculee: margeCalculee,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String venteIdLocal,
            Value<String?> produitId = const Value.absent(),
            Value<int> quantite = const Value.absent(),
            required double prixVenduReel,
            Value<double> margeCalculee = const Value.absent(),
          }) =>
              LocalLignesVenteCompanion.insert(
            id: id,
            venteIdLocal: venteIdLocal,
            produitId: produitId,
            quantite: quantite,
            prixVenduReel: prixVenduReel,
            margeCalculee: margeCalculee,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalLignesVenteTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({venteIdLocal = false}) {
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
                if (venteIdLocal) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.venteIdLocal,
                    referencedTable: $$LocalLignesVenteTableReferences
                        ._venteIdLocalTable(db),
                    referencedColumn: $$LocalLignesVenteTableReferences
                        ._venteIdLocalTable(db)
                        .idLocal,
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

typedef $$LocalLignesVenteTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalLignesVenteTable,
    LocalLignesVenteData,
    $$LocalLignesVenteTableFilterComposer,
    $$LocalLignesVenteTableOrderingComposer,
    $$LocalLignesVenteTableAnnotationComposer,
    $$LocalLignesVenteTableCreateCompanionBuilder,
    $$LocalLignesVenteTableUpdateCompanionBuilder,
    (LocalLignesVenteData, $$LocalLignesVenteTableReferences),
    LocalLignesVenteData,
    PrefetchHooks Function({bool venteIdLocal})>;
typedef $$LocalDepensesTableCreateCompanionBuilder = LocalDepensesCompanion
    Function({
  required String idLocal,
  required String boutiqueId,
  Value<String?> sessionId,
  required double montant,
  required String motif,
  Value<DateTime> dateTransaction,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$LocalDepensesTableUpdateCompanionBuilder = LocalDepensesCompanion
    Function({
  Value<String> idLocal,
  Value<String> boutiqueId,
  Value<String?> sessionId,
  Value<double> montant,
  Value<String> motif,
  Value<DateTime> dateTransaction,
  Value<bool> synced,
  Value<int> rowid,
});

class $$LocalDepensesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDepensesTable> {
  $$LocalDepensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idLocal => $composableBuilder(
      column: $table.idLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateTransaction => $composableBuilder(
      column: $table.dateTransaction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$LocalDepensesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDepensesTable> {
  $$LocalDepensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idLocal => $composableBuilder(
      column: $table.idLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateTransaction => $composableBuilder(
      column: $table.dateTransaction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$LocalDepensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDepensesTable> {
  $$LocalDepensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idLocal =>
      $composableBuilder(column: $table.idLocal, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get motif =>
      $composableBuilder(column: $table.motif, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTransaction => $composableBuilder(
      column: $table.dateTransaction, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalDepensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalDepensesTable,
    LocalDepense,
    $$LocalDepensesTableFilterComposer,
    $$LocalDepensesTableOrderingComposer,
    $$LocalDepensesTableAnnotationComposer,
    $$LocalDepensesTableCreateCompanionBuilder,
    $$LocalDepensesTableUpdateCompanionBuilder,
    (
      LocalDepense,
      BaseReferences<_$AppDatabase, $LocalDepensesTable, LocalDepense>
    ),
    LocalDepense,
    PrefetchHooks Function()> {
  $$LocalDepensesTableTableManager(_$AppDatabase db, $LocalDepensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDepensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDepensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDepensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> idLocal = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<double> montant = const Value.absent(),
            Value<String> motif = const Value.absent(),
            Value<DateTime> dateTransaction = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalDepensesCompanion(
            idLocal: idLocal,
            boutiqueId: boutiqueId,
            sessionId: sessionId,
            montant: montant,
            motif: motif,
            dateTransaction: dateTransaction,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String idLocal,
            required String boutiqueId,
            Value<String?> sessionId = const Value.absent(),
            required double montant,
            required String motif,
            Value<DateTime> dateTransaction = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalDepensesCompanion.insert(
            idLocal: idLocal,
            boutiqueId: boutiqueId,
            sessionId: sessionId,
            montant: montant,
            motif: motif,
            dateTransaction: dateTransaction,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalDepensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalDepensesTable,
    LocalDepense,
    $$LocalDepensesTableFilterComposer,
    $$LocalDepensesTableOrderingComposer,
    $$LocalDepensesTableAnnotationComposer,
    $$LocalDepensesTableCreateCompanionBuilder,
    $$LocalDepensesTableUpdateCompanionBuilder,
    (
      LocalDepense,
      BaseReferences<_$AppDatabase, $LocalDepensesTable, LocalDepense>
    ),
    LocalDepense,
    PrefetchHooks Function()>;
typedef $$LocalSessionsTableCreateCompanionBuilder = LocalSessionsCompanion
    Function({
  required String id,
  required String boutiqueId,
  required String utilisateurNom,
  Value<DateTime> dateOuverture,
  Value<DateTime?> dateFermeture,
  Value<double> montantInitial,
  Value<double?> montantFinalDeclare,
  Value<String> statut,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$LocalSessionsTableUpdateCompanionBuilder = LocalSessionsCompanion
    Function({
  Value<String> id,
  Value<String> boutiqueId,
  Value<String> utilisateurNom,
  Value<DateTime> dateOuverture,
  Value<DateTime?> dateFermeture,
  Value<double> montantInitial,
  Value<double?> montantFinalDeclare,
  Value<String> statut,
  Value<bool> synced,
  Value<int> rowid,
});

class $$LocalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get utilisateurNom => $composableBuilder(
      column: $table.utilisateurNom,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOuverture => $composableBuilder(
      column: $table.dateOuverture, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateFermeture => $composableBuilder(
      column: $table.dateFermeture, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montantInitial => $composableBuilder(
      column: $table.montantInitial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montantFinalDeclare => $composableBuilder(
      column: $table.montantFinalDeclare,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$LocalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get utilisateurNom => $composableBuilder(
      column: $table.utilisateurNom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOuverture => $composableBuilder(
      column: $table.dateOuverture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateFermeture => $composableBuilder(
      column: $table.dateFermeture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montantInitial => $composableBuilder(
      column: $table.montantInitial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montantFinalDeclare => $composableBuilder(
      column: $table.montantFinalDeclare,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$LocalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get utilisateurNom => $composableBuilder(
      column: $table.utilisateurNom, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOuverture => $composableBuilder(
      column: $table.dateOuverture, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFermeture => $composableBuilder(
      column: $table.dateFermeture, builder: (column) => column);

  GeneratedColumn<double> get montantInitial => $composableBuilder(
      column: $table.montantInitial, builder: (column) => column);

  GeneratedColumn<double> get montantFinalDeclare => $composableBuilder(
      column: $table.montantFinalDeclare, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSessionsTable,
    LocalSession,
    $$LocalSessionsTableFilterComposer,
    $$LocalSessionsTableOrderingComposer,
    $$LocalSessionsTableAnnotationComposer,
    $$LocalSessionsTableCreateCompanionBuilder,
    $$LocalSessionsTableUpdateCompanionBuilder,
    (
      LocalSession,
      BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>
    ),
    LocalSession,
    PrefetchHooks Function()> {
  $$LocalSessionsTableTableManager(_$AppDatabase db, $LocalSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String> utilisateurNom = const Value.absent(),
            Value<DateTime> dateOuverture = const Value.absent(),
            Value<DateTime?> dateFermeture = const Value.absent(),
            Value<double> montantInitial = const Value.absent(),
            Value<double?> montantFinalDeclare = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSessionsCompanion(
            id: id,
            boutiqueId: boutiqueId,
            utilisateurNom: utilisateurNom,
            dateOuverture: dateOuverture,
            dateFermeture: dateFermeture,
            montantInitial: montantInitial,
            montantFinalDeclare: montantFinalDeclare,
            statut: statut,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boutiqueId,
            required String utilisateurNom,
            Value<DateTime> dateOuverture = const Value.absent(),
            Value<DateTime?> dateFermeture = const Value.absent(),
            Value<double> montantInitial = const Value.absent(),
            Value<double?> montantFinalDeclare = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSessionsCompanion.insert(
            id: id,
            boutiqueId: boutiqueId,
            utilisateurNom: utilisateurNom,
            dateOuverture: dateOuverture,
            dateFermeture: dateFermeture,
            montantInitial: montantInitial,
            montantFinalDeclare: montantFinalDeclare,
            statut: statut,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSessionsTable,
    LocalSession,
    $$LocalSessionsTableFilterComposer,
    $$LocalSessionsTableOrderingComposer,
    $$LocalSessionsTableAnnotationComposer,
    $$LocalSessionsTableCreateCompanionBuilder,
    $$LocalSessionsTableUpdateCompanionBuilder,
    (
      LocalSession,
      BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>
    ),
    LocalSession,
    PrefetchHooks Function()>;
typedef $$LocalTiersTableCreateCompanionBuilder = LocalTiersCompanion Function({
  required String id,
  required String boutiqueId,
  required String nom,
  Value<String?> telephone,
  required String typeTiers,
  Value<double> soldeDu,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$LocalTiersTableUpdateCompanionBuilder = LocalTiersCompanion Function({
  Value<String> id,
  Value<String> boutiqueId,
  Value<String> nom,
  Value<String?> telephone,
  Value<String> typeTiers,
  Value<double> soldeDu,
  Value<bool> synced,
  Value<int> rowid,
});

class $$LocalTiersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTiersTable> {
  $$LocalTiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeTiers => $composableBuilder(
      column: $table.typeTiers, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get soldeDu => $composableBuilder(
      column: $table.soldeDu, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$LocalTiersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTiersTable> {
  $$LocalTiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeTiers => $composableBuilder(
      column: $table.typeTiers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get soldeDu => $composableBuilder(
      column: $table.soldeDu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$LocalTiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTiersTable> {
  $$LocalTiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get typeTiers =>
      $composableBuilder(column: $table.typeTiers, builder: (column) => column);

  GeneratedColumn<double> get soldeDu =>
      $composableBuilder(column: $table.soldeDu, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalTiersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTiersTable,
    LocalTier,
    $$LocalTiersTableFilterComposer,
    $$LocalTiersTableOrderingComposer,
    $$LocalTiersTableAnnotationComposer,
    $$LocalTiersTableCreateCompanionBuilder,
    $$LocalTiersTableUpdateCompanionBuilder,
    (LocalTier, BaseReferences<_$AppDatabase, $LocalTiersTable, LocalTier>),
    LocalTier,
    PrefetchHooks Function()> {
  $$LocalTiersTableTableManager(_$AppDatabase db, $LocalTiersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTiersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTiersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> telephone = const Value.absent(),
            Value<String> typeTiers = const Value.absent(),
            Value<double> soldeDu = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTiersCompanion(
            id: id,
            boutiqueId: boutiqueId,
            nom: nom,
            telephone: telephone,
            typeTiers: typeTiers,
            soldeDu: soldeDu,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boutiqueId,
            required String nom,
            Value<String?> telephone = const Value.absent(),
            required String typeTiers,
            Value<double> soldeDu = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTiersCompanion.insert(
            id: id,
            boutiqueId: boutiqueId,
            nom: nom,
            telephone: telephone,
            typeTiers: typeTiers,
            soldeDu: soldeDu,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTiersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTiersTable,
    LocalTier,
    $$LocalTiersTableFilterComposer,
    $$LocalTiersTableOrderingComposer,
    $$LocalTiersTableAnnotationComposer,
    $$LocalTiersTableCreateCompanionBuilder,
    $$LocalTiersTableUpdateCompanionBuilder,
    (LocalTier, BaseReferences<_$AppDatabase, $LocalTiersTable, LocalTier>),
    LocalTier,
    PrefetchHooks Function()>;
typedef $$LocalMouvementsStockTableCreateCompanionBuilder
    = LocalMouvementsStockCompanion Function({
  required String id,
  required String boutiqueId,
  required String produitId,
  Value<String> produitNom,
  required String typeMouvement,
  required int quantite,
  required String motif,
  Value<String?> auteurId,
  required String auteurNom,
  Value<DateTime> dateMouvement,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$LocalMouvementsStockTableUpdateCompanionBuilder
    = LocalMouvementsStockCompanion Function({
  Value<String> id,
  Value<String> boutiqueId,
  Value<String> produitId,
  Value<String> produitNom,
  Value<String> typeMouvement,
  Value<int> quantite,
  Value<String> motif,
  Value<String?> auteurId,
  Value<String> auteurNom,
  Value<DateTime> dateMouvement,
  Value<bool> synced,
  Value<int> rowid,
});

class $$LocalMouvementsStockTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMouvementsStockTable> {
  $$LocalMouvementsStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produitId => $composableBuilder(
      column: $table.produitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produitNom => $composableBuilder(
      column: $table.produitNom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeMouvement => $composableBuilder(
      column: $table.typeMouvement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get auteurId => $composableBuilder(
      column: $table.auteurId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get auteurNom => $composableBuilder(
      column: $table.auteurNom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateMouvement => $composableBuilder(
      column: $table.dateMouvement, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$LocalMouvementsStockTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMouvementsStockTable> {
  $$LocalMouvementsStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produitId => $composableBuilder(
      column: $table.produitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produitNom => $composableBuilder(
      column: $table.produitNom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeMouvement => $composableBuilder(
      column: $table.typeMouvement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get auteurId => $composableBuilder(
      column: $table.auteurId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get auteurNom => $composableBuilder(
      column: $table.auteurNom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateMouvement => $composableBuilder(
      column: $table.dateMouvement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$LocalMouvementsStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMouvementsStockTable> {
  $$LocalMouvementsStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boutiqueId => $composableBuilder(
      column: $table.boutiqueId, builder: (column) => column);

  GeneratedColumn<String> get produitId =>
      $composableBuilder(column: $table.produitId, builder: (column) => column);

  GeneratedColumn<String> get produitNom => $composableBuilder(
      column: $table.produitNom, builder: (column) => column);

  GeneratedColumn<String> get typeMouvement => $composableBuilder(
      column: $table.typeMouvement, builder: (column) => column);

  GeneratedColumn<int> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get motif =>
      $composableBuilder(column: $table.motif, builder: (column) => column);

  GeneratedColumn<String> get auteurId =>
      $composableBuilder(column: $table.auteurId, builder: (column) => column);

  GeneratedColumn<String> get auteurNom =>
      $composableBuilder(column: $table.auteurNom, builder: (column) => column);

  GeneratedColumn<DateTime> get dateMouvement => $composableBuilder(
      column: $table.dateMouvement, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalMouvementsStockTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMouvementsStockTable,
    LocalMouvementsStockData,
    $$LocalMouvementsStockTableFilterComposer,
    $$LocalMouvementsStockTableOrderingComposer,
    $$LocalMouvementsStockTableAnnotationComposer,
    $$LocalMouvementsStockTableCreateCompanionBuilder,
    $$LocalMouvementsStockTableUpdateCompanionBuilder,
    (
      LocalMouvementsStockData,
      BaseReferences<_$AppDatabase, $LocalMouvementsStockTable,
          LocalMouvementsStockData>
    ),
    LocalMouvementsStockData,
    PrefetchHooks Function()> {
  $$LocalMouvementsStockTableTableManager(
      _$AppDatabase db, $LocalMouvementsStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMouvementsStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMouvementsStockTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMouvementsStockTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boutiqueId = const Value.absent(),
            Value<String> produitId = const Value.absent(),
            Value<String> produitNom = const Value.absent(),
            Value<String> typeMouvement = const Value.absent(),
            Value<int> quantite = const Value.absent(),
            Value<String> motif = const Value.absent(),
            Value<String?> auteurId = const Value.absent(),
            Value<String> auteurNom = const Value.absent(),
            Value<DateTime> dateMouvement = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMouvementsStockCompanion(
            id: id,
            boutiqueId: boutiqueId,
            produitId: produitId,
            produitNom: produitNom,
            typeMouvement: typeMouvement,
            quantite: quantite,
            motif: motif,
            auteurId: auteurId,
            auteurNom: auteurNom,
            dateMouvement: dateMouvement,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boutiqueId,
            required String produitId,
            Value<String> produitNom = const Value.absent(),
            required String typeMouvement,
            required int quantite,
            required String motif,
            Value<String?> auteurId = const Value.absent(),
            required String auteurNom,
            Value<DateTime> dateMouvement = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMouvementsStockCompanion.insert(
            id: id,
            boutiqueId: boutiqueId,
            produitId: produitId,
            produitNom: produitNom,
            typeMouvement: typeMouvement,
            quantite: quantite,
            motif: motif,
            auteurId: auteurId,
            auteurNom: auteurNom,
            dateMouvement: dateMouvement,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMouvementsStockTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalMouvementsStockTable,
        LocalMouvementsStockData,
        $$LocalMouvementsStockTableFilterComposer,
        $$LocalMouvementsStockTableOrderingComposer,
        $$LocalMouvementsStockTableAnnotationComposer,
        $$LocalMouvementsStockTableCreateCompanionBuilder,
        $$LocalMouvementsStockTableUpdateCompanionBuilder,
        (
          LocalMouvementsStockData,
          BaseReferences<_$AppDatabase, $LocalMouvementsStockTable,
              LocalMouvementsStockData>
        ),
        LocalMouvementsStockData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProduitsTableTableManager get localProduits =>
      $$LocalProduitsTableTableManager(_db, _db.localProduits);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalVentesTableTableManager get localVentes =>
      $$LocalVentesTableTableManager(_db, _db.localVentes);
  $$LocalLignesVenteTableTableManager get localLignesVente =>
      $$LocalLignesVenteTableTableManager(_db, _db.localLignesVente);
  $$LocalDepensesTableTableManager get localDepenses =>
      $$LocalDepensesTableTableManager(_db, _db.localDepenses);
  $$LocalSessionsTableTableManager get localSessions =>
      $$LocalSessionsTableTableManager(_db, _db.localSessions);
  $$LocalTiersTableTableManager get localTiers =>
      $$LocalTiersTableTableManager(_db, _db.localTiers);
  $$LocalMouvementsStockTableTableManager get localMouvementsStock =>
      $$LocalMouvementsStockTableTableManager(_db, _db.localMouvementsStock);
}
