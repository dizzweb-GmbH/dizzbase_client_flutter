import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'dizzbase_query.dart';
import 'dizzbase_protocol.dart';

part 'dizzbase_transactions.g.dart';

// For building the JSON code (generating dizzbase_transactions.g.dart), run: 
//    flutter pub run build_runner build --delete-conflicting-outputs

/// Abstract base class for non-streamed transactions
@JsonSerializable(explicitToJson: true)
class DizzbaseTransaction<DizzbaseResultType> extends DizzbaseRequest<DizzbaseResultType>
{ 
  DizzbaseTransaction();

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
class DizzbaseUpdate extends DizzbaseTransaction<DizzbaseResultRowCount>
{
/// Creates a SQL UPDATE statement
  DizzbaseUpdate ({required this.table, required this.fields, required this.values, this.filters = const []});

  final String table;
  final List<String> fields;
  final dynamic values;
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
class DizzbaseInsert extends DizzbaseTransaction<DizzbaseResultPkey>
{
/// Creates a SQL INSERT statement that returns the primary key of the new row
  DizzbaseInsert ({required this.table, required this.fields, required this.values});
  final String table;
  final List<String> fields;
  final dynamic values;

  factory DizzbaseInsert.fromJson(Map<String, dynamic> json) => _$DizzbaseInsertFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseInsertToJson(this);

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    var res = DizzbaseResultPkey(fromServer.data![0]["pkey"], fromServer);
    _completer!.complete(res);
  }
}

/// Creates a SQL DELETE statement
@JsonSerializable(explicitToJson: true)
class DizzbaseDelete extends DizzbaseTransaction<DizzbaseResultRowCount>
{
  /// Creates a SQL DELETE statement
  DizzbaseDelete ({required this.table, required this.filters});
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
  DizzbaseDirectSQL (this.sql);
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
  DizzbaseResultRowCount (this.rowCount, DizzbaseFromServerPacket fromServer) : super (fromServer);
  /// This is the structure that holds the retrieved data
  final int rowCount;
}

/// For insert statements that return a key
class DizzbaseResultPkey extends DizzbaseResult
{
  DizzbaseResultPkey (this.pkey, DizzbaseFromServerPacket fromServer) : super (fromServer);
  /// This is the structure that holds the retrieved data
  final int pkey;
}

/// For directSQL and stream-based result record sets
class DizzbaseResultRows extends DizzbaseResult
{
  DizzbaseResultRows (this.data, DizzbaseFromServerPacket fromServer) : super (fromServer);
  /// This is the structure that holds the retrieved data
  List<Map<String, dynamic>>? data;
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
