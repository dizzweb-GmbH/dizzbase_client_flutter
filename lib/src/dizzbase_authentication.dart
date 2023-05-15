import 'dart:async';
import 'dizzbase_connection.dart';


class DizzbaseLoginResult
{
  DizzbaseLoginResult (this.loginSuccessful, this.error);
  bool loginSuccessful;
  String error;
}

class DizzbaseAuthentication
{
  static Completer<DizzbaseLoginResult>? _loginCompleter;

  /// Login via dizzbase authentication
  /// 
  /// Currently only authType 'local' is supported (might be Google, Facebook, etc. in the future).
  /// Pass either username or email, not both.
  /// You can await the login result: "OK"
  static Future<DizzbaseLoginResult> login ({String userName="", String email="", String password = "", String authType = 'local'}) async
  {
    if (_loginCompleter != null)
    {
      // Cancel already running login attempt and start again with a new completer
      if (!_loginCompleter!.isCompleted) {_loginCompleter!.complete(DizzbaseLoginResult(false, "New login request started while this request was still running"));}
    }
    _loginCompleter = Completer<DizzbaseLoginResult>();
    
    if ((userName != "") && (email != "")) {throw Exception("DizzbaseAuthentication.login: Pass either a userName *or* email, not both.");}
    Map<String, dynamic> loginData = {};
    loginData["userName"] = userName;
    loginData["email"] = email;
    loginData["password"] = password;
    loginData["authType"] = 'local';

    //DizzbaseConnection().sendMessageToServer('dizzbase_login', loginData);
    return _loginCompleter!.future;
  }

  static void loginMessageReceived (dynamic data)
  {
    if (_loginCompleter == null) {throw Exception("DizzbaseAuthentication.loginMessageReceived: Completer is null error.");}
    if (_loginCompleter!.isCompleted) {throw Exception("DizzbaseAuthentication.loginMessageReceived: Completer already completed.");}

    gUserToken = data["jwt"];
    _loginCompleter = null;
  }

  static logout ()
  {
    gUserToken = "";
    _loginCompleter = null;
  }
}

