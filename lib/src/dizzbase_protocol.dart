// Defines the format of communications to and from the server
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'dizzbase_protocol.g.dart';
// For building the JSON code (generating dizzbase_client.g.dart), run: 
//    flutter pub run build_runner build --delete-conflicting-outputs

/// Base class to handle queries and transactions, implements uuid identification
class DizzbaseRequest<DizzbaseResultType>
{
  DizzbaseRequest();
  String transactionuuid = "";

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

  /// For override 
  void complete(DizzbaseFromServerPacket fromServer)
  {
    throw Exception("Abstract base class complete called in DizzbaseRequest.");
  }

  /// For override 
  factory DizzbaseRequest.fromJson(Map<String, dynamic> json)
  {
    throw Exception("Abstract base class fromJson called in DizzbaseRequest.");
  }
  Map<String, dynamic> toJson() 
  {
    throw Exception("Abstract base class toJson called in DizzbaseRequest.");
  }

}

/// Format for all SQL related server requests
@JsonSerializable(explicitToJson: true)
class DizzbaseToServerPacket
{
  DizzbaseToServerPacket (this.jwt, this.uuid, this.transactionuuid, this.dizzbaseRequest, this.dizzbaseRequestType);
  final String jwt;
  final String uuid;
  final String transactionuuid;
  final DizzbaseRequest dizzbaseRequest;
  final String dizzbaseRequestType;

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
