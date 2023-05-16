import 'dart:async';
import 'dizzbase_connection.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Represents a login
class DizzbaseLoginData
{
  DizzbaseLoginData ({required this.id, required this.userName, required this.email, required this.role, required this.jwt, required this.verified, this.uuid="", this.authType='local'});
  int id;
  String userName;
  String email;
  String role;
  String jwt;
  bool verified;
  String uuid;
  String authType;
}

class DizzbaseLoginResult
{
  DizzbaseLoginResult (this.success, this.error);
  bool success;
  String error;
}

class DizzbaseAuthentication
{
  static DizzbaseLoginData? _currentUser;
  static void _setCurrentUser (DizzbaseLoginData? newUser)
  {
    _currentUser = newUser;
  }

  static DizzbaseLoginData? get currentUser
  {
    return _currentUser;
  }

  /// Login via dizzbase authentication
  /// 
  /// Currently only authType 'local' is supported (might be Google, Facebook, etc. in the future).
  /// Pass either username or email, not both.
  /// You can await the login result: "OK"
  static Future<DizzbaseLoginResult> login ({String userName="", String email="", String password = "", String authType = 'local'}) async
  {
    if ((userName != "") && (email != "")) {throw Exception("DizzbaseAuthentication.login: Pass either a userName *or* email, not both.");}
    Map<String, dynamic> loginData = {};
    loginData["authRequestType"] = 'login';
    loginData["userName"] = userName;
    loginData["email"] = email;
    loginData["password"] = password;
    loginData["authType"] = 'local';
    Completer<DizzbaseLoginResult> completer = Completer();
    _sendAuthRequest(loginData, _setCurrentUser, (data, setCurrentUserCallback) {
      if (data["error"]=="") 
      {
        setCurrentUserCallback (DizzbaseLoginData(id: data["userID"], userName: data["userName"], email: data["email"], 
          role: data["role"], verified: data["verified"], jwt: data["jwt"], uuid: data["uuid"]));
        completer.complete(DizzbaseLoginResult(true, ""));
      } else {
        completer.complete(DizzbaseLoginResult(false, data["error"]));
      }
      socket.off('dizzbase_auth_response');
    });

    return completer.future;
  }

  static logout ()
  {
    if (_currentUser == null) return;
    _sendAuthRequest({"authRequestType": "logout", "uuid": _currentUser!.uuid}, null, null);
    _setCurrentUser(null);
  }

  static io.Socket socket = io.io(gUrl, io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build());

  static void _sendAuthRequest (Map<String,dynamic> loginData,
    void Function (DizzbaseLoginData newUser)? setCurrentUserCallback,
    void Function (Map<String, dynamic> data, void Function (DizzbaseLoginData newUser) setCurrentUserCallback)? processResponse)
  {
    socket.onConnect((val) {});
    socket.onerror((data) { throw Exception ("LOGIN Socket onerror: ${data.toString()}"); });
    socket.on("error", (data) {throw Exception ("LOGIN Socket on 'error': ${data.toString()}"); });
    socket.on('dizzbase_auth_response', (data) {
      if (processResponse != null) processResponse (data, setCurrentUserCallback!);
    });
    socket.onDisconnect((_) {});
    socket.onError((data) {});

    socket.emit('dizzbase_auth_request', loginData);
  }

  static Future<int> getUserID (String emailOrName) async
  {
    throw Exception("Not yet implemented.");
  }
  static Future<void> deleteUser (String emailOrName) async
  {
    throw Exception("Not yet implemented.");
  }
  static Future<void> updateUser (int id, String newName, String newEmail, String newRole, String newPwd, bool verified) async 
  {
    throw Exception("Not yet implemented.");
  }
  static Future<int> insertUser (String newName, String newEmail, String newRole, String newPwd, bool verified) async 
  {
    throw Exception("Not yet implemented.");
  }
}

