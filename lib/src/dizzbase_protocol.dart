// Defines the format of communications to and from the server
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'dizzbase_protocol.g.dart';
// For building the JSON code (generating dizzbase_client.g.dart), run: 
//    dart run build_runner build --delete-conflicting-outputs

/// Base class to handle queries and transactions, implements uuid identification
@JsonSerializable(explicitToJson: true)
class DizzbaseRequest<DizzbaseResultType>
{
  DizzbaseRequest({this.nickName=""});
  String transactionuuid = "";
  final String nickName;

  void init()
  {
    transactionuuid = const Uuid().v4();
  }

  /// For override 
  void dispose() {}
  /// For override 
  void reconnect () {} // called when we reconnect to the server after a lost connnection

  void reset()
  {
    transactionuuid = "";
  }

  /// Indicates whether the Request should keep persistent state on the server.
  /// If "false", the server state will be removed automatically
  /// If "true", the server state will be removed up calling dispose()
  bool persistOnServer ()
  {
    return false;
  }

  /// For override 
  void complete(DizzbaseFromServerPacket fromServer)
  {
    throw Exception("Abstract base class complete called in DizzbaseRequest.");
  }

  factory DizzbaseRequest.fromJson(Map<String, dynamic> json) => _$DizzbaseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DizzbaseRequestToJson(this);

}

/// Format for all SQL related server requests
@JsonSerializable(explicitToJson: true)
class DizzbaseToServerPacket
{
  DizzbaseToServerPacket (this.jwt, this.uuid, this.transactionuuid, this.dizzbaseRequest, this.dizzbaseRequestType, {this.nickName = ""});
  final String jwt;
  final String uuid;
  final String transactionuuid;
  final DizzbaseRequest dizzbaseRequest;
  final String dizzbaseRequestType;
  final String nickName;

  factory DizzbaseToServerPacket.fromJson(Map<String, dynamic> json) => _$DizzbaseToServerPacketFromJson(json);
  Map<String, dynamic> toJson() => _$DizzbaseToServerPacketToJson(this);
}

/// Format for all SQL related server responses
@JsonSerializable(explicitToJson: true)
class DizzbaseFromServerPacket
{
  DizzbaseFromServerPacket (this.uuid, this.transactionuuid, this.rowCount, this.data, this.payload, this.dizzbaseRequestType, this.error);
  final String uuid;
  final String transactionuuid;
  final int rowCount;
  final String error;
  final dynamic payload;
  final String dizzbaseRequestType;
  List<Map<String, dynamic>>? data;

  factory DizzbaseFromServerPacket.fromJson(Map<String, dynamic> json) => _$DizzbaseFromServerPacketFromJson(json);
  Map<String, dynamic> toJson() => _$DizzbaseFromServerPacketToJson(this);
}

/// API internal-use only: Required to properly transfer DateTime (and may other values) as Json
class DizzbaseJsonDynamicConverter implements JsonConverter<dynamic, String> {
  const DizzbaseJsonDynamicConverter();

  @override
  dynamic fromJson(String json) => json; // this is never used as we do not recieve transactions from the server.

  @override
  String toJson(dynamic object) {
    if (object is DateTime) {
      return object.toIso8601String();
    } else {
      return object.toString();
    }
  }
}
