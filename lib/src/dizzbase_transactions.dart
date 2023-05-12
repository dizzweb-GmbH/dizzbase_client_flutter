import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dizzbase_connection.dart';
import 'dizzbase_query.dart';

part 'dizzbase_transactions.g.dart';

// For building the JSON code (generating dizzbase_transactions.g.dart), run: 
//    flutter pub run build_runner build --delete-conflicting-outputs

/// Abstract base class for non-streamed transactions
@JsonSerializable(explicitToJson: true)
class DizzbaseTransaction extends DizzbaseRequest
{ 
  DizzbaseTransaction();
  String transactionuuid = "";

  @JsonKey(includeToJson: false, includeFromJson: false,)
  Completer<Map<String, dynamic>>? completer;

  factory DizzbaseTransaction.fromJson(Map<String, dynamic> json) => _$DizzbaseTransactionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseTransactionToJson(this);

  void init()
  {
    completer = Completer<Map<String, dynamic>>();
    transactionuuid = const Uuid().v4();
  }
  void reset()
  {
    transactionuuid = "";
  }

  bool isRunning()
  {
    if (completer == null)
    {
      return false;
    }
    if ((completer!.isCompleted == false) && (transactionuuid != ""))
    {
      throw Exception("DizzbaseTransaction: Inconsistant state: Completer exist and is not completed, but uuid is empty.");
    }
    return (completer!.isCompleted) == false;
  }
}

/// Creates a SQL UPDATE statement
@JsonSerializable(explicitToJson: true)
class DizzbaseUpdate extends DizzbaseTransaction
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
}

/// Creates a SQL INSERT statement that returns the primary key of the new row
@JsonSerializable(explicitToJson: true)
class DizzbaseInsert extends DizzbaseTransaction
{
/// Creates a SQL INSERT statement that returns the primary key of the new row
  DizzbaseInsert ({required this.table, required this.fields, required this.values});
  final String table;
  final List<String> fields;
  final dynamic values;

  factory DizzbaseInsert.fromJson(Map<String, dynamic> json) => _$DizzbaseInsertFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseInsertToJson(this);
}

/// Creates a SQL DELETE statement
@JsonSerializable(explicitToJson: true)
class DizzbaseDelete extends DizzbaseTransaction
{
/// Creates a SQL DELETE statement
  DizzbaseDelete ({required this.table, required this.filters});
  final String table;
  final List<Filter> filters;

  factory DizzbaseDelete.fromJson(Map<String, dynamic> json) => _$DizzbaseDeleteFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseDeleteToJson(this);
}

/// Result set and error message for a DizzbaseDirectSQL transaction
class DizzbaseDirectSQLResult 
{
  /// This structure hold status information
  Map<String, dynamic> status = {};
  /// This is the structure that holds the retrieved data
  List<Map<String, dynamic>> data = [];
  String error = "";
}

/// Allows sending an arbitrary SQL statement to the server and retrieves any resulting row in a non-streamed way
@JsonSerializable(explicitToJson: true)
class DizzbaseDirectSQL extends DizzbaseTransaction
{
  /// Allows sending an arbitrary SQL statement to the server and retrieves any resulting row in a non-streamed way
  DizzbaseDirectSQL (this.sql);
  final String sql;

  factory DizzbaseDirectSQL.fromJson(Map<String, dynamic> json) => _$DizzbaseDirectSQLFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseDirectSQLToJson(this);
}
