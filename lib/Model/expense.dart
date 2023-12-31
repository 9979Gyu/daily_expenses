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
  static String ipAddress= "";

  Expense(this.id, this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['desc'] as String,
        amount = double.parse(json['amount'] as dynamic),
        dateTime = json['dateTime'] as String,
        id = json['id'] as int?;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'desc': desc, 'amount': amount, 'dateTime': dateTime, 'id': id};

  _loadStoredIPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String result = prefs.getString('ipAddress') ?? "no value accepted";
    ipAddress = "http://$result";
  }

  Future<bool> save() async {
    // Save to local SQLite
    int result = await SQLiteDB().insert(SQLiteTable, toJson());

    // API operation
    await _loadStoredIPAddress();
    RequestController req = RequestController(
        path: path,
        server: ipAddress
    );
    req.setBody(toJson());
    await req.post();

    if(req.status() == 200){
      return true;
    }
    else{
      if(result != 0) {
        return true;
      }
      else {
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
        server: ipAddress,
    );

    await req.get();
    if(req.status() == 200 && req.result() != null){
      for (var item in req.result()) {
        expenseList.add(Expense.fromJson(item));
      }
    }
    else{
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
    int result = await SQLiteDB().update(SQLiteTable, 'id', toJson());

    await _loadStoredIPAddress();
    RequestController req = RequestController(
        path: path,
        server: ipAddress
    );
    req.setBody(toJson());
    await req.put();
    if (req.status() == 200) {
      return true;
    }
    else {
      if (result != 0) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  Future<bool> delete() async {
    int result = await SQLiteDB().delete(SQLiteTable, 'id', id);

    // API operation
    await _loadStoredIPAddress();
    RequestController req = RequestController(
        path: path,
        server: ipAddress
    );

    req.setBody(toJson());
    await req.delete();
    if(req.status() == 200){
      return true;
    }
    else{
      if(result != 0) {
        return true;
      }
      else{
        return false;
      }
    }
  }
}