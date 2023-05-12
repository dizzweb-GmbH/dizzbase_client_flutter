// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dizzbase_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainTable _$MainTableFromJson(Map<String, dynamic> json) => MainTable(
      json['name'] as String,
      pkey: json['pkey'] as int? ?? 0,
      columns: (json['columns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      alias: json['alias'] as String? ?? "",
    );

Map<String, dynamic> _$MainTableToJson(MainTable instance) => <String, dynamic>{
      'name': instance.name,
      'pkey': instance.pkey,
      'columns': instance.columns,
      'alias': instance.alias,
    };

JoinedTable _$JoinedTableFromJson(Map<String, dynamic> json) => JoinedTable(
      json['name'] as String,
      joinToTableOrAlias: json['joinToTableOrAlias'] as String? ?? '',
      foreignKey: json['foreignKey'] as String? ?? '',
      joinType: $enumDecodeNullable(_$JoinTypeEnumMap, json['joinType']) ??
          JoinType.inner,
      columns: (json['columns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      alias: json['alias'] as String? ?? "",
    );

Map<String, dynamic> _$JoinedTableToJson(JoinedTable instance) =>
    <String, dynamic>{
      'name': instance.name,
      'columns': instance.columns,
      'alias': instance.alias,
      'joinToTableOrAlias': instance.joinToTableOrAlias,
      'foreignKey': instance.foreignKey,
      'joinType': _$JoinTypeEnumMap[instance.joinType]!,
    };

const _$JoinTypeEnumMap = {
  JoinType.inner: 'inner',
  JoinType.leftOuter: 'leftOuter',
  JoinType.rightOuter: 'rightOuter',
};

SortField _$SortFieldFromJson(Map<String, dynamic> json) => SortField(
      json['table'] as String,
      json['column'] as String,
      ascending: json['ascending'] as bool? ?? true,
    );

Map<String, dynamic> _$SortFieldToJson(SortField instance) => <String, dynamic>{
      'column': instance.column,
      'table': instance.table,
      'ascending': instance.ascending,
    };

Filter _$FilterFromJson(Map<String, dynamic> json) => Filter(
      json['table'] as String,
      json['column'] as String,
      json['value'],
      comparison: json['comparison'] as String? ?? "=",
    );

Map<String, dynamic> _$FilterToJson(Filter instance) => <String, dynamic>{
      'table': instance.table,
      'column': instance.column,
      'value': instance.value,
      'comparison': instance.comparison,
    };

DizzbaseQuery _$DizzbaseQueryFromJson(Map<String, dynamic> json) =>
    DizzbaseQuery(
      table: MainTable.fromJson(json['table'] as Map<String, dynamic>),
      joinedTables: (json['joinedTables'] as List<dynamic>?)
              ?.map((e) => MainTable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sortFields: (json['sortFields'] as List<dynamic>?)
              ?.map((e) => SortField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      filters: (json['filters'] as List<dynamic>?)
              ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DizzbaseQueryToJson(DizzbaseQuery instance) =>
    <String, dynamic>{
      'table': instance.table.toJson(),
      'joinedTables': instance.joinedTables.map((e) => e.toJson()).toList(),
      'sortFields': instance.sortFields.map((e) => e.toJson()).toList(),
      'filters': instance.filters.map((e) => e.toJson()).toList(),
    };
