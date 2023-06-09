// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dizzbase_protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DizzbaseRequest<DizzbaseResultType>
    _$DizzbaseRequestFromJson<DizzbaseResultType>(Map<String, dynamic> json) =>
        DizzbaseRequest<DizzbaseResultType>(
          nickName: json['nickName'] as String? ?? "",
        )..transactionuuid = json['transactionuuid'] as String;

Map<String, dynamic> _$DizzbaseRequestToJson<DizzbaseResultType>(
        DizzbaseRequest<DizzbaseResultType> instance) =>
    <String, dynamic>{
      'transactionuuid': instance.transactionuuid,
      'nickName': instance.nickName,
    };

DizzbaseToServerPacket _$DizzbaseToServerPacketFromJson(
        Map<String, dynamic> json) =>
    DizzbaseToServerPacket(
      json['jwt'] as String,
      json['uuid'] as String,
      json['transactionuuid'] as String,
      DizzbaseRequest<dynamic>.fromJson(
          json['dizzbaseRequest'] as Map<String, dynamic>),
      json['dizzbaseRequestType'] as String,
      nickName: json['nickName'] as String? ?? "",
    );

Map<String, dynamic> _$DizzbaseToServerPacketToJson(
        DizzbaseToServerPacket instance) =>
    <String, dynamic>{
      'jwt': instance.jwt,
      'uuid': instance.uuid,
      'transactionuuid': instance.transactionuuid,
      'dizzbaseRequest': instance.dizzbaseRequest.toJson(),
      'dizzbaseRequestType': instance.dizzbaseRequestType,
      'nickName': instance.nickName,
    };

DizzbaseFromServerPacket _$DizzbaseFromServerPacketFromJson(
        Map<String, dynamic> json) =>
    DizzbaseFromServerPacket(
      json['uuid'] as String,
      json['transactionuuid'] as String,
      json['rowCount'] as int,
      (json['data'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      json['payload'],
      json['dizzbaseRequestType'] as String,
      json['error'] as String,
    );

Map<String, dynamic> _$DizzbaseFromServerPacketToJson(
        DizzbaseFromServerPacket instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'transactionuuid': instance.transactionuuid,
      'rowCount': instance.rowCount,
      'error': instance.error,
      'payload': instance.payload,
      'dizzbaseRequestType': instance.dizzbaseRequestType,
      'data': instance.data,
    };
