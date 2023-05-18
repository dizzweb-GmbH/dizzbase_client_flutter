import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'dizzbase_query.dart';
import 'dizzbase_protocol.dart';

part 'dizzbase_transactions.g.dart';

// For building the JSON code (generating dizzbase_transactions.g.dart), run: 
//    dart run build_runner build --delete-conflicting-outputs

/// Abstract base class for non-streamed transactions
@JsonSerializable(explicitToJson: true)
class DizzbaseTransaction<DizzbaseResultType> extends DizzbaseRequest<DizzbaseResultType>
{ 
  DizzbaseTransaction({required String nickName}) : super (nickName: nickName);

  @JsonKey(includeToJson: false, includeFromJson: false,)
  Completer<DizzbaseResultType>? _completer;

  factory DizzbaseTransaction.fromJson(Map<String, dynamic> json) => _$DizzbaseTransactionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseTransactionToJson(this);

  @override
  void init()
  {
    _completer = Completer<DizzbaseResultType>();
    super.init();
  }

  @override
  // ignore: unnecessary_overrides
  void reset()
  {
    super.reset();
  }

  bool isRunning()
  {
    if (_completer == null)
    {
      return false;
    }
    if ((_completer!.isCompleted == false) && (transactionuuid != ""))
    {
      throw Exception("DizzbaseTransaction: Inconsistant state: Completer exist and is not completed, but uuid is empty.");
    }
    return (_completer!.isCompleted) == false;
  }

  /// set connect=true does not apply to transactions as the should not be re-send.
  Future <DizzbaseResultType> runTransaction (void Function (String transactionuuid, DizzbaseTransaction t, bool reconnect) executionCallback) async
  {
    if (isRunning())
    {
      throw Exception ("DizzbaseTransactions cannote be re-used before the previous transaction has been completed.");
    }

    init();
    executionCallback (transactionuuid, this, false);
    return _completer!.future;
  }

  @override
  void dispose()
  {
    if (_completer != null) _completer = null;
  }

}

/// Creates a SQL UPDATE statement
@JsonSerializable(explicitToJson: true)
@DizzbaseJsonDynamicConverter()
class DizzbaseUpdate extends DizzbaseTransaction<DizzbaseResultRowCount>
{
/// Creates a SQL UPDATE statement
  DizzbaseUpdate ({required this.table, required this.fields, required this.values, this.filters = const [], String nickName=""}) :super (nickName: nickName);

  final String table;
  final List<String> fields;
  final List<dynamic> values;
  final List<Filter> filters;
 
  factory DizzbaseUpdate.fromJson(Map<String, dynamic> json) => _$DizzbaseUpdateFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseUpdateToJson(this);

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    var res = DizzbaseResultRowCount(fromServer.rowCount,fromServer);
    _completer!.complete(res);
  }
}

/// Creates a SQL INSERT statement that returns the primary key of the new row
@JsonSerializable(explicitToJson: true)
@DizzbaseJsonDynamicConverter()
class DizzbaseInsert extends DizzbaseTransaction<DizzbaseResultPkey>
{
/// Creates a SQL INSERT statement that returns the primary key of the new row
  DizzbaseInsert ({required this.table, required this.fields, required this.values, String nickName=""}) :super (nickName: nickName);
  final String table;
  final List<String> fields;
  final List<dynamic> values;

  factory DizzbaseInsert.fromJson(Map<String, dynamic> json) => _$DizzbaseInsertFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseInsertToJson(this);

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    int pkey = -1;
    if (fromServer.data != null)
    {
      if (fromServer.data!.isNotEmpty) pkey = fromServer.data![0]["pkey"];
    }
    var res = DizzbaseResultPkey(pkey, fromServer);
    _completer!.complete(res);
  }
}

/// Creates a SQL DELETE statement
@JsonSerializable(explicitToJson: true)
@DizzbaseJsonDynamicConverter()
class DizzbaseDelete extends DizzbaseTransaction<DizzbaseResultRowCount>
{
  /// Creates a SQL DELETE statement
  DizzbaseDelete ({required this.table, required this.filters, String nickName=""}) :super (nickName: nickName);
  final String table;
  final List<Filter> filters;

  factory DizzbaseDelete.fromJson(Map<String, dynamic> json) => _$DizzbaseDeleteFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseDeleteToJson(this);

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    var res = DizzbaseResultRowCount(fromServer.rowCount, fromServer);
    _completer!.complete(res);
  }
}

/// Allows sending an arbitrary SQL statement to the server and retrieves any resulting row in a non-streamed way
@JsonSerializable(explicitToJson: true)
class DizzbaseDirectSQL extends DizzbaseTransaction<DizzbaseResultRows>
{
  /// Allows sending an arbitrary SQL statement to the server and retrieves any resulting row in a non-streamed way
  DizzbaseDirectSQL (this.sql, {String nickName=""}) :super (nickName: nickName);
  final String sql;

  factory DizzbaseDirectSQL.fromJson(Map<String, dynamic> json) => _$DizzbaseDirectSQLFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseDirectSQLToJson(this);

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    var res = DizzbaseResultRows(fromServer.data, fromServer);
    _completer!.complete(res);
  }
}

/// For update and delete statements the number of rows affected
class DizzbaseResultRowCount extends DizzbaseResult
{
  DizzbaseResultRowCount (int resRowCount, DizzbaseFromServerPacket fromServer) : super (fromServer)
  {
    if (fromServer.error != "")
    {
      rowCount = 0;
    } else {
      rowCount = resRowCount;
    } 
  }
  /// This is the structure that holds the retrieved data
  late int rowCount;
}

/// For insert statements that return a key
class DizzbaseResultPkey extends DizzbaseResult
{
  DizzbaseResultPkey (int resPkey, DizzbaseFromServerPacket fromServer) : super (fromServer)
  {
    if (fromServer.error != "")
    {
      pkey = 0;
    } else {
      pkey = resPkey;
    } 
  }
  /// This is the structure that holds the retrieved data
  late int pkey;
}

/// For directSQL and stream-based result record sets
class DizzbaseResultRows extends DizzbaseResult
{
  DizzbaseResultRows (List<Map<String, dynamic>>? resRows, DizzbaseFromServerPacket fromServer) : super (fromServer)
  {
    if (fromServer.error != "")
    {
      rows = [];
    } else {
      resRows ??= [];
      rows = resRows;
    } 
  }
  
  /// This is the structure that holds the retrieved data
  late List<Map<String, dynamic>> rows;
}

/// Abstract base class
class DizzbaseResult 
{
  DizzbaseResult (DizzbaseFromServerPacket fromServer)
  {
    error = fromServer.error;
  }
  /// error message or empty if OK
  late String error;
}
