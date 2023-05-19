import 'dart:async';
import 'package:dizzbase_client/src/dizzbase_socket.dart';

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
    if ((userName != "") && (email != "")) {throw Exception("DizzbaseAuthentication.login: Pass either a userName *or* email to identify the user, not both.");}
    Map<String, dynamic> loginData = {};
    loginData["authRequestType"] = 'login';
    loginData["userName"] = userName;
    loginData["email"] = email;
    loginData["password"] = password;
    loginData["authType"] = 'local';

    DizzbaseLoginResult? result;
    try 
    {
      var data = await DizzbaseSocket.sendAuthRequest (loginData, DizzbaseSocket.apiAccessToken);
      if (data["error"]=="") 
      {
        _setCurrentUser (DizzbaseLoginData(id: data["userID"], userName: data["userName"], email: data["email"], 
          role: data["role"], verified: data["verified"], jwt: data["jwt"], uuid: data["uuid"]));
        result = DizzbaseLoginResult(true, "");
      } else {
        result = DizzbaseLoginResult(false, data["error"]);
      }
    } catch (err) {result = DizzbaseLoginResult(false, err.toString());}

    return result;
  }

  static void logout ()
  {
    if (_currentUser == null) return;
    Map<String, dynamic> logoutData = {};
    logoutData["authRequestType"] = 'logout';
    logoutData["userName"] = _currentUser!.userName;
    logoutData["uuid"] = _currentUser!.uuid;

    DizzbaseSocket.sendAuthRequest (logoutData, DizzbaseSocket.apiAccessToken);
    _setCurrentUser(null);
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

