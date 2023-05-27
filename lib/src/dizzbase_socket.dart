// ignore_for_file: avoid_print
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'dizzbase_connection.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dizzbase_authentication.dart';

import 'dizzbase_protocol.dart';

class DizzbaseSocket
{
  static final _SocketManager _socketManager = _SocketManager();
  static String _url = "http://localhost:3000";
  static String apiAccessToken = "";
  static Completer<dynamic>? _loginCompleter;
  static int _ingoreLoginResponses =0;

  static final Map<String, DizzbaseConnection> _connections = {};
  static bool _hasBeenDisconnected = false;

  static void configureConnection (String url, String apiAccessToken)
  {
    _url = url;
    DizzbaseSocket.apiAccessToken = apiAccessToken;
  }


  /// Adds the connection to the list of active connections of the DizzbaseSocket.
  /// Returns true, if the backend ist connected, false otherwise.
  static void addConnection (String uuid, DizzbaseConnection connection)
  {
    _connections[uuid] = connection;
    if (_socketManager.socket.connected) connection.handleFirstConnect();
  }

  static void closeConnection (String uuid)
  {
    _socketManager.socket.emit('close_connection', {"socketuuid": _socketManager.socketuuid, "data": uuid});
    _connections.remove(uuid);
  }

  static void sendDBRequestToServer (DizzbaseToServerPacket packet)
  {
    //print ("XXX sock out: ${_socketManager.socketuuid} ");
    String token = apiAccessToken;
    if (DizzbaseAuthentication.currentUser != null) token = DizzbaseAuthentication.currentUser!.jwt;
    _socketManager.socket.emit('dbrequest',  {"socketuuid": _socketManager.socketuuid, "token": token, "data": packet});    
  }

  static void _handleDBRequestResponse (dynamic data)
  {
    try
    {
      if (data["jwtError"] != null) throw Exception(data["jwtError"]);

      var fromServer = DizzbaseFromServerPacket.fromJson (data);
      var connection = _connections[data['uuid']];
      if (connection != null)
      {      
        connection.processDBRequestResponse(fromServer);
      } else {

        if (data['uuid'] == null) print ("Received null value in connection uuid");
        try
        {
          if (connection == null)
          {
            print ("WARNING: Received an invalid connection uuid ${data['uuid']} from server. This may happen after a flutter hot reload. Sending disconnect request to server.");
            DizzbaseSocket.closeConnection(data['uuid']);
          }
        } catch (e)
        {
          print ("_socket.on ('dbrequest_response') - error closing unindentified connection: $e");
        }
      }
    } catch (e) {
      print ("_socket.on ('dbrequest_response') - error: $e");
    }
  }

  static Future<dynamic> sendAuthRequest (Map<String,dynamic> authRequestData, String token) async
  {
    dynamic result;
    if (authRequestData['authRequestType'] == 'login')
    {
      if (_loginCompleter != null)
      {
        _loginCompleter!.completeError("New login request received while this request was still running - aborting request.");
        print ("New login request received while this request was still running - aborting request.");
        _ingoreLoginResponses++;
        _loginCompleter = null;
      } 
      _loginCompleter = Completer<dynamic>();
      result = _loginCompleter!.future;
    }
    _socketManager.socket.emit('dizzbase_auth_request', {"socketuuid": _socketManager.socketuuid, "token": token, "data": authRequestData});
    return result;
  }

  static void _handleAuthRequestResponse (dynamic data)
  {
    if (data['responseType'] == 'login')
    {
      if (_ingoreLoginResponses > 0)
      {
        print ("WARNNG: There were $_ingoreLoginResponses login request send before a previous login request was completed. Ignoring this login response.");
        _ingoreLoginResponses--;
        return;
      }
      _loginCompleter!.complete(data);
      _loginCompleter = null;
    }
  }

  static void _handleConnect (dynamic data)
  {
    if (_hasBeenDisconnected)
    {
      _ingoreLoginResponses = 0; // Responses to requests send before the connect will never arrive...
      print ("Reconnect: Sending reconnect notifications to queries.");
      _connections.forEach((uuid, con) {
        con.handleReconnect();
      });
      _hasBeenDisconnected = false;
    }
    else
    {
      print ("Socket.io link established - informing DizzbaseConnections.");
      _connections.forEach((uuid, con) {
        con.handleFirstConnect();
      });
    }
  } 

  static void _handleDisconnect (String msg)
  {
    print(msg);
    _socketManager.socketuuid = "";
    _hasBeenDisconnected = true;
    _connections.forEach((uuid, con) {
      con.handleDisconnect();
    });
  }
}

String gSocketuuid = "";


class _SocketManager
{
  static final _SocketManager _socketManager = _SocketManager._internal();
  late io.Socket socket;

  String get socketuuid {return gSocketuuid;}
  set socketuuid (String newUuid) {gSocketuuid = newUuid;}

  factory _SocketManager() {
    return _socketManager;
  }

  void sendInitToServer()
  {
      socketuuid = const Uuid().v4();
      print ("Initializing socket $socketuuid");
      socket.emit("dizzbase_socket_init", {"socketuuid": socketuuid, "data": {}});
  }

  void _handleDisconnectOrError (String msg)
  {
    socketuuid = "";
    DizzbaseSocket._handleDisconnect(msg);    
  }

  _SocketManager._internal()
  {
    print ("dizzbase _SocketManager: Creating socket connection.");
    socket= io.io(DizzbaseSocket._url, io.OptionBuilder()
      .setTransports(['websocket']) // Authorization header does not work with this option??
      .enableAutoConnect().enableForceNew().disableMultiplex().enableForceNewConnection()
      //.setExtraHeaders({'Authorization': "Bearer ${(gUserToken=="")?gApiAccessToken:gUserToken}"})
      //.setQuery({'token': gApiAccessToken})
      .build()
    );
    
    sendInitToServer();
    socket.onConnect((data) {
      if (socketuuid == "") {
        sendInitToServer(); // reconnect
      }
      DizzbaseSocket._handleConnect(data);
    });

    socket.onerror((data) {
      print ("Socket onerror: ${data.toString()}"); 
      //throw Exception(data.toString());
    });

    socket.on("error", (data) {
      print ("Socket on 'error': ${data.toString()}"); 
      //throw Exception(data.toString());
    });

    // Send from server on query transactions (eg SELECT)
    socket.on('dbrequest_response', (data) {
      //print ("XXX sock in: $socketuuid");
      DizzbaseSocket._handleDBRequestResponse(data);
    }); 

    socket.onDisconnect((_) => _handleDisconnectOrError("socket.io disconnect."));

    socket.onError((data) => _handleDisconnectOrError("socket.io onError: ${data.toString()}"));

    socket.on('dizzbase_auth_response', (data) => DizzbaseSocket._handleAuthRequestResponse(data));
  }
}
