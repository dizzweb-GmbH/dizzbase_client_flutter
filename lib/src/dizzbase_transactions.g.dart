// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dizzbase_transactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DizzbaseTransaction<DizzbaseResultType>
    _$DizzbaseTransactionFromJson<DizzbaseResultType>(
            Map<String, dynamic> json) =>
        DizzbaseTransaction<DizzbaseResultType>(
          nickName: json['nickName'] as String,
        )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseTransactionToJson<DizzbaseResultType>(
        DizzbaseTransaction<DizzbaseResultType> instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
    };

DizzbaseUpdate _$DizzbaseUpdateFromJson(Map<String, dynamic> json) =>
    DizzbaseUpdate(
      table: json['table'] as String,
      fields:
          (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
      values: (json['values'] as List<dynamic>)
          .map((e) => _$JsonConverterFromJson<String, dynamic>(
              e, const DizzbaseJsonDynamicConverter().fromJson))
          .toList(),
      filters: (json['filters'] as List<dynamic>?)
              ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nickName: json['nickName'] as String? ?? "",
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseUpdateToJson(DizzbaseUpdate instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
      'table': instance.table,
      'fields': instance.fields,
      'values': instance.values
          .map(const DizzbaseJsonDynamicConverter().toJson)
          .toList(),
      'filters': instance.filters.map((e) => e.toJson()).toList(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

DizzbaseInsert _$DizzbaseInsertFromJson(Map<String, dynamic> json) =>
    DizzbaseInsert(
      table: json['table'] as String,
      fields:
          (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
      values: (json['values'] as List<dynamic>)
          .map((e) => _$JsonConverterFromJson<String, dynamic>(
              e, const DizzbaseJsonDynamicConverter().fromJson))
          .toList(),
      nickName: json['nickName'] as String? ?? "",
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseInsertToJson(DizzbaseInsert instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
      'table': instance.table,
      'fields': instance.fields,
      'values': instance.values
          .map(const DizzbaseJsonDynamicConverter().toJson)
          .toList(),
    };

DizzbaseDelete _$DizzbaseDeleteFromJson(Map<String, dynamic> json) =>
    DizzbaseDelete(
      table: json['table'] as String,
      filters: (json['filters'] as List<dynamic>)
          .map((e) => Filter.fromJson(e as Map<String, dynamic>))
          .toList(),
      nickName: json['nickName'] as String? ?? "",
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseDeleteToJson(DizzbaseDelete instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
      'table': instance.table,
      'filters': instance.filters.map((e) => e.toJson()).toList(),
    };

DizzbaseDirectSQL _$DizzbaseDirectSQLFromJson(Map<String, dynamic> json) =>
    DizzbaseDirectSQL(
      json['sql'] as String,
      nickName: json['nickName'] as String? ?? "",
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseDirectSQLToJson(DizzbaseDirectSQL instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
      'sql': instance.sql,
    };
