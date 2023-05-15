// ignore_for_file: avoid_print

import 'dart:async';
import 'dizzbase_protocol.dart';
import 'dizzbase_transactions.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import 'dizzbase_query.dart';

String gUrl = "http://localhost:3000";
String gApiAccessToken = "";
String gUserToken = "";

/// Create a DizzbaseConnection for every widget with realtime updating and/or for every SQL transaction
/// Call DizzbaseConnection.dispose() in the StatefulWidget's dispose() event.
class DizzbaseConnection
{
  void Function (bool connected)? connectionStatusCallback;
  late String connectionuuid;
  late io.Socket _socket;
  Map<String, DizzbaseRequest> transactions = {};
  bool hasBeenDisconnected = false;

  /// Call once after app start to set connection parameters for all connections.
  /// The apiAccessToken is the default authentication before any (optional) login has happened.
  static void configureConnection (String url, String apiAccessToken)
  {
    gUrl = url;
    gApiAccessToken = apiAccessToken;
  }

  /// Add a connectionStatusCallback to get notified when the backend is not online or comes back online again.
  DizzbaseConnection ({this.connectionStatusCallback})
  {
    connectionuuid = const Uuid().v4();

    _socket = io.io(gUrl, io.OptionBuilder()
      //.setTransports(['websocket']) // Authorization header does not work with this option??
      .enableAutoConnect()
      //.setExtraHeaders({'Authorization': "Bearer ${(gUserToken=="")?gApiAccessToken:gUserToken}"})
      //.setQuery({'token': gApiAccessToken})
      .build()
    );

    _socket.emit ('init', connectionuuid);

    _socket.onConnect((val) {
      // Moved the init event directly after the io.io(url) call as the .onConnect event wasn't triggered reliably 
      //_socket.emit ('init', connectionuuid);
      print('Connected to server.');
      if (hasBeenDisconnected)
      {
        print ("Reconnect: Sending reconnect notifications to queries.");
        _socket.emit ('init', connectionuuid);
        hasBeenDisconnected = false;
        transactions.forEach((key, t) { 
          t.reconnect();
        });
      }
      if (connectionStatusCallback != null)
      {
        connectionStatusCallback! (true);
      }
    });

    /* unclear how to use this event...
    _socket.on('connect_error', (data) {
      print ("onnect_error: $data");
      print (data.runtimeType.toString());
    });
    */

    _socket.onerror((data) {
      print ("Socket onerror: ${data.toString()}"); 
      //throw Exception(data.toString());
    });

    _socket.on("error", (data) {
      print ("Socket on 'error': ${data.toString()}"); 
      //throw Exception(data.toString());
    });


    // Send from server on query transactions (eg SELECT)
    _socket.on('dbrequest_response', (data) {      
      try
      {
        if (data['uuid'] == connectionuuid) // check this before we .fromJson the full package for better performance.
        {
          var fromServer = DizzbaseFromServerPacket.fromJson (data);
          transactions[fromServer.transactionuuid]!.complete(fromServer);
          transactions[fromServer.transactionuuid]!.reset();
        }
        } catch (e) {print ("_socket.on ('dbrequest_response') - error: $e");}
      }); 

    _socket.onDisconnect((_) => _handleDisconnect("Disconnect event."));

    _socket.onError((data) => _handleDisconnect("Socket.io error: $data"));
  }

  void _handleDisconnect (String msg)
  {
    print(msg);
    hasBeenDisconnected = true;
    if (connectionStatusCallback != null)
    {
      connectionStatusCallback! (false);
    }
  }

  /// Closes the stream (if any) and unregisteres the connection from the dizzbase server
  void dispose ()
  {
    _socket.emit('close', connectionuuid);
    transactions.forEach((key, t) {
      t.dispose();
    });
    transactions = {};
  }

  void _sendToServer (DizzbaseRequest r, {String transactionuuid = ''})
  {
    var toServer = DizzbaseToServerPacket('', connectionuuid, transactionuuid, r, r.runtimeType.toString().toLowerCase());
    _socket.emit('dbrequest', toServer);
  }

  void _requestExecutionCallback (String tUuid, DizzbaseRequest t, bool reconnect)
  {
    if (!reconnect) transactions[tUuid] = t;
    _sendToServer(t, transactionuuid: tUuid);
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
