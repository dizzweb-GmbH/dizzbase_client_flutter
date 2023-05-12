// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dizzbase_transactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DizzbaseTransaction _$DizzbaseTransactionFromJson(Map<String, dynamic> json) =>
    DizzbaseTransaction()..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseTransactionToJson(
        DizzbaseTransaction instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
    };

DizzbaseUpdate _$DizzbaseUpdateFromJson(Map<String, dynamic> json) =>
    DizzbaseUpdate(
      table: json['table'] as String,
      fields:
          (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
      values: json['values'],
      filters: (json['filters'] as List<dynamic>?)
              ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseUpdateToJson(DizzbaseUpdate instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'table': instance.table,
      'fields': instance.fields,
      'values': instance.values,
      'filters': instance.filters.map((e) => e.toJson()).toList(),
    };

DizzbaseInsert _$DizzbaseInsertFromJson(Map<String, dynamic> json) =>
    DizzbaseInsert(
      table: json['table'] as String,
      fields:
          (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
      values: json['values'],
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseInsertToJson(DizzbaseInsert instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'table': instance.table,
      'fields': instance.fields,
      'values': instance.values,
    };

DizzbaseDelete _$DizzbaseDeleteFromJson(Map<String, dynamic> json) =>
    DizzbaseDelete(
      table: json['table'] as String,
      filters: (json['filters'] as List<dynamic>)
          .map((e) => Filter.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseDeleteToJson(DizzbaseDelete instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'table': instance.table,
      'filters': instance.filters.map((e) => e.toJson()).toList(),
    };

DizzbaseDirectSQL _$DizzbaseDirectSQLFromJson(Map<String, dynamic> json) =>
    DizzbaseDirectSQL(
      json['sql'] as String,
    )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseDirectSQLToJson(DizzbaseDirectSQL instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'sql': instance.sql,
    };
