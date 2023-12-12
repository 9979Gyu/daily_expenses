import '../Controller/request_controller.dart';
import '../Controller/sqlite_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {
  static const String SQLiteTable = "expense";
  int? id;
  String desc;
  double amount;
  String dateTime;
  String path = "/api/expenses.php";
  static String ipAddress = "http://192.168.124.174";

  _loadStoredIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String result = prefs.getString('ipAddress') ?? "no value accepted";
    ipAddress = "http://$result";
  }

  Expense(this.id, this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
    : desc = json['desc'] as String,
      amount = double.parse(json['amount'] as dynamic),
      dateTime = json['dateTime'] as String,
      id = json['id'] as int?;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
    {'desc': desc, 'amount': amount, 'dateTime': dateTime, 'id': id};

  Future<bool> save() async {
    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());

    // API operation
    _loadStoredIPAddress();
    RequestController req = RequestController(
        path: path,
        server: ipAddress,
    );
    req.setBody(toJson());
    await req.post();

    if(req.status() == 200){
      return true;
    }
    else{
      if(await SQLiteDB().insert(SQLiteTable, toJson()) != 0) {
        return true;
      }
      else{
        return false;
      }
    }
  }

  static Future<List<Expense>> loadAll() async {
    List<Expense> expenseList = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String result = prefs.getString('ipAddress') ?? "no value accepted";
    ipAddress = "http://$result";
    RequestController req = RequestController(
        path: "/api/expenses.php",
        server: ipAddress
    );

    await req.get();
    print("response : $req");
    if(req.status() == 200 && req.result() != null){
      for (var item in req.result()) {
        expenseList.add(Expense.fromJson(item));
      }
    }
    else {
      List<Map<String, dynamic>> rawResult =
        await SQLiteDB().queryAll(SQLiteTable);

      for (var item in rawResult) {
        expenseList.add(Expense.fromJson(item));
      }
    }
    return expenseList;
  }

  Future<bool> edit() async {
    // Update local
    int re = await SQLiteDB().update(SQLiteTable, 'id', toJson());

    _loadStoredIPAddress();
    RequestController req = RequestController(
      path: path,
      server: ipAddress,
    );
    req.setBody(toJson());
    await req.put();
    if(req.status() == 200){
      return true;
    }
    else{
      if(re != 0) {
        return true;
      }
      else{
        return false;
      }
    }
    // return false;
  }

  Future<bool> delete() async {
    await SQLiteDB().delete(SQLiteTable, 'id', id);

    _loadStoredIPAddress();
    RequestController req = RequestController(
      path: path,
      server: ipAddress,
    );
    req.setBody(toJson());
    await req.delete();
    if(req.status() == 200){
      return true;
    }
    else{
      print("HTTP return: ${req.status()}");
      print("HTTP return: ${req.result()}");
      if(await SQLiteDB().delete(SQLiteTable, 'id', id) != 0) {
        return true;
      }
      else{
        return false;
      }
    }
  }
}