// ignore_for_file: avoid_print

import 'dart:async';
import 'dizzbase_protocol.dart';
import 'dizzbase_transactions.dart';
import 'package:uuid/uuid.dart';
import 'dizzbase_query.dart';
import 'dizzbase_socket.dart';

/// Create a DizzbaseConnection for every widget with realtime updating and/or for every SQL transaction
/// Call DizzbaseConnection.dispose() in the StatefulWidget's dispose() event.
class DizzbaseConnection
{
  void Function (bool connected)? connectionStatusCallback;
  late String connectionuuid;
  Map<String, DizzbaseRequest> _transactions = {};
  final String nickName;

  /// Add a connectionStatusCallback to get notified when the backend is not online or comes back online again.
  /// The nickName can be used for debugging in multi-connection scenarios and has no further function.
  DizzbaseConnection ({this.connectionStatusCallback, this.nickName=""})
  {
    connectionuuid = const Uuid().v4();
    DizzbaseSocket.addConnection(connectionuuid, this);
  }

  /// Call once after app start to set connection parameters for all connections.
  /// The apiAccessToken is the default authentication before any (optional) login has happened.
  static void configureConnection (String url, String apiAccessToken)
  {
    DizzbaseSocket.configureConnection(url, apiAccessToken);
  }

  void handleFirstConnect ()
  {
    if (connectionStatusCallback != null) connectionStatusCallback!(true);
  }

  void handleDisconnect ()
  {
    if (connectionStatusCallback != null) connectionStatusCallback! (false);
  }

  void handleReconnect ()
  {
    if (connectionStatusCallback != null) connectionStatusCallback! (true);
    _transactions.forEach((key, t) { 
      t.reconnect();
    });
  }

  /// Closes the stream (if any) and unregisteres the connection from the dizzbase server
  void dispose ()
  {
    _transactions.forEach((key, t) {
      t.dispose();
    });
    DizzbaseSocket.closeConnection(connectionuuid);
    _transactions = {};
  }

  void _sendToServer (DizzbaseRequest r, {String transactionuuid = ''})
  {
    var toServer = DizzbaseToServerPacket('', connectionuuid, transactionuuid, r, r.runtimeType.toString().toLowerCase(), nickName: nickName);
    DizzbaseSocket.sendDBRequestToServer(toServer);
  }

  void _requestExecutionCallback (String tUuid, DizzbaseRequest t, bool reconnect)
  {
    if (!reconnect) _transactions[tUuid] = t;	
    _sendToServer(t, transactionuuid: tUuid);
  }

  void processDBRequestResponse (DizzbaseFromServerPacket fromServer)
  {
    _transactions[fromServer.transactionuuid]!.complete(fromServer);
    if (_transactions[fromServer.transactionuuid]!.persistOnServer() == false) _transactions.remove(fromServer.transactionuuid);
  }

  /// Creates a stream to be used with eg. a StreamBuilder widget
  Stream<DizzbaseResultRows> streamFromQuery (DizzbaseQuery q)
  {
    return q.runQuery(_requestExecutionCallback).stream;
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<DizzbaseResultPkey> insertTransaction (DizzbaseInsert req) async
  {
    var result = await req.runTransaction(_requestExecutionCallback);
    return result;
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<DizzbaseResultRowCount> updateTransaction (DizzbaseUpdate req) async
  {
    var result = await req.runTransaction(_requestExecutionCallback);
    return result;
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<DizzbaseResultRowCount> deleteTransaction (DizzbaseDelete req) async
  {
    var result = await req.runTransaction(_requestExecutionCallback);
    return result;
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<DizzbaseResultRows> directSQLTransaction (String sql) async
  {
    var req = DizzbaseDirectSQL(sql);
    var result = await req.runTransaction(_requestExecutionCallback);
    return result;
  }
}
