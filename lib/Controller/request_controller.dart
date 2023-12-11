import 'dart:convert'; //json encode/decode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestController{
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  _loadStoredIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipAddress = prefs.getString('ipAddress') ?? "no value accepted";
    return "http://$ipAddress";
  }

  // 10.0.2.16 - vm
  // 10.0.0.2 - vm devices
  // 10.131.76.215 - utem
  RequestController({required this.path, this.server = ""});

  setBody(Map<String, dynamic> data){
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    server = await _loadStoredIPAddress();
    print("This is $server");
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    print("response : ${_res}");
    _parseResult();
  }

  Future<void> get() async{
    if(server == ""){
      server = await _loadStoredIPAddress();
    }
    print("This is $server");
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  Future<void> put() async{
    server = await _loadStoredIPAddress();
    print("This is $server");
    _res = await http.put(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  Future<void> delete() async{
    server = await _loadStoredIPAddress();
    print("This is $server");
    _res = await http.delete(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  void _parseResult(){
    // parse result into json structure if possible
    try{
      print("raw response:${_res?.body}" );
      _resultData = jsonDecode(_res?.body?? "");
    }
    catch(ex){
      // otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }

  dynamic result(){
    return _resultData;
  }

  int status(){
    return _res?.statusCode ?? 0;
  }
}
