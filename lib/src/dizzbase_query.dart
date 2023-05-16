// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'dizzbase_protocol.dart';
import 'dizzbase_transactions.dart';

// For information about how the JSON serialization works, please see https://docs.flutter.dev/data-and-backend/json
// To include the code generator, run:
//    flutter pub add json_annotation
//    flutter pub add dev:build_runner
//    flutter pub add dev:json_serializable
// For building the JSON code (generating dizzbase_client.g.dart), run: 
//    dart run build_runner build --delete-conflicting-outputs
part 'dizzbase_query.g.dart';

@JsonSerializable(explicitToJson: true)
class MainTable
{
  /// Pass columns if you want specific columns, otherwise all columns (SELECT *) are retrieved.
  /// Passing a primary key is optional, use a filter otherwise.
  /// 
  /// In case of multiple tables with the same column name: Add an alias to ensure that each column get's a different name in the result data set.
  MainTable(this.name, {this.pkey = 0, this.columns = const[], this.alias = ""});

  final String name;
  final int pkey;
  final List<String> columns;
  final String alias;

  factory MainTable.fromJson(Map<String, dynamic> json) => _$MainTableFromJson(json);
  Map<String, dynamic> toJson() => _$MainTableToJson(this);
}

enum JoinType {inner, leftOuter, rightOuter}

/// Creates the JOIN part of the SQL statement
@JsonSerializable(explicitToJson: true)
class JoinedTable extends MainTable
{
  /// Passing a joinToTableAlias is optional, if not passed the query main table will be used by default.
  /// 
  /// Passing a foreign key is optional, if not passed it will be lookped up in the database contraints.
  /// 
  /// In case of multiple tables with the same column name: Add an alias to ensure that each column get's a different name in the result data set.
  JoinedTable (String name, {this.joinToTableOrAlias='', this.foreignKey='', this.joinType=JoinType.inner, List<String> columns = const[], String alias=""}) : super (name, columns: columns, alias: alias);

  final String joinToTableOrAlias;
  final String foreignKey;
  final JoinType joinType;

  factory JoinedTable.fromJson(Map<String, dynamic> json) => _$JoinedTableFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JoinedTableToJson(this);

}

/// Creates the ORDER BY part of the SQL query.
@JsonSerializable()
class SortField
{
  /// The table parameter has to be the table alias if specified in Table() or JoinedTable() constructor.
  SortField(this.table, this.column, {this.ascending = true});
  
  final String column;
  final String table;
  final bool ascending;

  factory SortField.fromJson(Map<String, dynamic> json) => _$SortFieldFromJson(json);
  Map<String, dynamic> toJson() => _$SortFieldToJson(this);
}

/// Creates the WHERE part of the SQL statement
@JsonSerializable()
class Filter
{
  /// The table parameter has to be the table alias if specified in Table() or JoinedTable() constructor.
  Filter(this.table, this.column, this.value, {this.comparison = "="});

  final String table;
  final String column;
  final dynamic value;
  final String comparison;

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
  Map<String, dynamic> toJson() => _$FilterToJson(this);
}

/// SELECT query for a stream
@JsonSerializable(explicitToJson: true)
class DizzbaseQuery extends DizzbaseRequest<DizzbaseResultRows>
{
  StreamController<DizzbaseResultRows>? _controller;

  /// Create SELECT query for a stream. 
  DizzbaseQuery({required this.table, this.joinedTables = const [], this.sortFields = const [], this.filters = const [], String nickName=""}) : super (nickName: nickName);
  /// Short hand for creating a stream for a single row by primary key. 
  DizzbaseQuery.singleRow (String table, int primaryKeyValue, {String nickName = ""}) : this(table: MainTable (table, pkey: primaryKeyValue), nickName: nickName);

  final MainTable table;
  final List<MainTable> joinedTables;
  final List<SortField> sortFields;
  final List<Filter> filters;
  void Function (String transactionuuid, DizzbaseQuery q, bool reconnect)? _executionCallback;

  factory DizzbaseQuery.fromJson(Map<String, dynamic> json) => _$DizzbaseQueryFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseQueryToJson(this);

  StreamController<DizzbaseResultRows> runQuery (void Function (String transactionuuid, DizzbaseQuery q, bool reconnect) executionCallback)
  {
    init();
    _controller ??= StreamController<DizzbaseResultRows>();
    _executionCallback = executionCallback;
    _executionCallback! (transactionuuid, this, false);
    return _controller!;
  }

  @override
  void complete(DizzbaseFromServerPacket fromServer)
  {
    if ((fromServer.error != "") || (fromServer.data == null))
    {
      String err = fromServer.error;
      if (err == "") {err = "Data set is null due to an unknown error.";}
      _controller!.addError(err);
    } else {
      var res = DizzbaseResultRows(fromServer.data!, fromServer);
      _controller!.add(res);
    }
  }

  @override
  void dispose()
  {
    if (_controller != null) _controller!.close();
  }

  @override
  void reconnect() // called when we reconnect to the server after a lost connnection
  {
    if (_executionCallback != null)
    {
      _executionCallback!(transactionuuid, this, true);
    } else {
      print ("WARNING: DizzbaseQuery.reconnect() called without valid _executionCallback.");
    }
  }
}



/// Converts a rows result set from a node.js query result to an easier to consume format. Mostly for dizzbase_client internal use only.
List<Map<String, dynamic>> convertList (List<dynamic> ld)
{
  List<Map<String, dynamic>> lm = [];
  for (var row in ld) {
    Map<String, dynamic> m = {};
    (row as Map).forEach ((k, v) {
      m[k] = v;
    });
    lm.add(m);
  }
  return lm;
}
