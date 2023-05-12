// ignore_for_file: avoid_print

import 'dart:async';
import 'dizzbase_transactions.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import 'dizzbase_query.dart';

String gUrl = "http://localhost:3000";
String gApiAccessToken = "";

class DizzbaseRequest
{
  Map<String, dynamic> toJson() 
  {
    throw Exception("Abstract base class toJson called in DizzbaseRequest.");
  }
}

/// Create a DizzbaseConnection for every widget with realtime updating and/or for every SQL transaction
/// Call DizzbaseConnection.dispose() in the StatefulWidget's dispose() event.
class DizzbaseConnection
{
  void Function (bool connected)? connectionStatusCallback;
  late String connectionuuid;
  late io.Socket _socket;
  StreamController<List<Map<String,dynamic>>>? _controller;
  Map<String, DizzbaseTransaction> transactions = {};
  bool hasBeenDisconnected = false;
  DizzbaseQuery? lastQuery;

  /// Call once after app start to set connection parameters for all connections.
  static void configureConnection (String url, String apiAccessToken)
  {
    gUrl = url;
    gApiAccessToken = apiAccessToken;
  }
  
  /// Add a connectionStatusCallback to get notified when the backend is not online or comes back online again.
  DizzbaseConnection ({this.connectionStatusCallback})
  {
    connectionuuid = const Uuid().v4();
  
    _socket = io.io(gUrl);
    // TODO Implement security/access token

    _socket.emit ('init', connectionuuid);

    _socket.onConnect((val) {
      // Moved the init event directly after the io.io(url) call as the .onConnect event wasn't triggered reliably 
      //_socket.emit ('init', connectionuuid);
      print('Connected to server.');
      if (hasBeenDisconnected)
      {
        _socket.emit ('init', connectionuuid);
        hasBeenDisconnected = false;
        if (lastQuery != null) {_sendToServer(lastQuery!);}
      }
      if (connectionStatusCallback != null)
      {
        connectionStatusCallback! (true);
      }
    });

    // Send from server on query transactions (eg SELECT)
    _socket.on('data', (data) {
      try
      {
        if (data['status']['uuid'] == connectionuuid && data['status']['type'] == 'dizzbasequery')
        {
          if ((data['status']['error'] != '') || (data['data'] == null))
          {
            print ("ERROR on query: ${data['status']}");
          } else {
            _sendToStream(convertList (data['data']));
          }
        }
      } catch (e) {print ("_socket.on ('data') - error: $e");}
    }); 

    // Send from server on non-query transactions (eg INSERT/DELETE/UPDATE)
    _socket.on('status', (data) {
      if (data["status"]['uuid'] == connectionuuid)
      {
        transactions[data["status"]['transactionuuid']]!.completer!.complete(data);
        transactions[data["status"]['transactionuuid']]!.reset();
      }
    }); 

    _socket.onDisconnect((_) {
      hasBeenDisconnected = true;
      print('disconnect');
      if (connectionStatusCallback != null)
      {
        connectionStatusCallback! (false);
      }
    });
  }

  /// Closes the stream (if any) and unregisteres the connection from the dizzbase server
  void dispose ()
  {
    _socket.emit('close', connectionuuid);
    if (_controller != null)
    {
      if (! _controller!.isClosed)
      {
        _controller!.close();
      }
    }
  }

  void _sendToStream(dynamic data)
  {
    if (_controller != null)
    {
      _controller!.add(data);
    }
  }

  void _sendToServer (DizzbaseRequest r)
  {
    var augmentedRequest = r.toJson();
    augmentedRequest['uuid'] = connectionuuid;
    augmentedRequest['type'] = r.runtimeType.toString().toLowerCase();

    _socket.emit('dbrequest', augmentedRequest);
  }

  /// Creates a stream to be used with eg. a StreamBuilder widget
  Stream<List<Map<String,dynamic>>> streamFromQuery (DizzbaseQuery q)
  {
    lastQuery = q;
    _controller ??= StreamController<List<Map<String,dynamic>>>();
    _sendToServer(q);
    return _controller!.stream;
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<int> insertTransaction (DizzbaseInsert req) async
  {
    var result = await _transaction (req);
    if (result["status"]["error"] != "") {throw Exception(result["status"]["error"]);}
    return result['data'][0]["pkey"];
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<Map<String, dynamic>> updateTransaction (DizzbaseUpdate req) async
  {
    var result = await _transaction (req);
    return result["status"];
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<Map<String, dynamic>> deleteTransaction (DizzbaseDelete req) async
  {
    var result = await _transaction (req);
    return result["status"];
  }

  /// Inserts data into the database and returns the primary key of the inserted row.
  Future<DizzbaseDirectSQLResult> directSQLTransaction (String sql) async
  {
    var result = await _transaction (DizzbaseDirectSQL(sql));
    var res = DizzbaseDirectSQLResult();
    res.status = result["status"];
    res.error = result["status"]["error"];
    if (result["status"]["error"] == "")
    {
      res.data = convertList (result["data"]);
    }
    return res;
  }

  /// The Future that is return by this function contains a map with the primary key of the new row.
  /// The primary key can be retrieved using the "pkey" key or by using it's proper column name, eg xxx_id
  Future<Map<String, dynamic>> _transaction (DizzbaseTransaction req)
  {
    if (req.isRunning())
    {
      throw Exception ("DizzbaseTransactions cannote be re-used before the previous transaction has been completed.");
    }

    req.init();
    transactions[req.transactionuuid] = req;
    _sendToServer(req);
    return req.completer!.future;
  }
}
