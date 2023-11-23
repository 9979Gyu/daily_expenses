import '../Controller/sqlite_db.dart';
import '../Controller/request_controller.dart';

class Expense {
  static const String SQLiteTable = "expense";
  int? id;
  String desc;
  double amount;
  String dateTime;
  String path = "/api/expenses.php";
  Expense(this.id, this.amount, this.desc, this.dateTime);
  // Expense.getDataById(this.id, this.amount, this.desc, this.dateTime);

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
    RequestController req = RequestController(path: path);
    req.setBody(toJson());
    await req.post();
    if(req.status() == 200){
      return true;
    }
    else{
      if(await SQLiteDB().insert(SQLiteTable, toJson()) != 0) {
        return true;
      }else{
        return false;
      }
    }
  }

  Future<bool> edit() async {
    RequestController req = RequestController(path: path);
    req.setBody(toJson());
    await req.put();
    if(req.status() == 200){
      return true;
    }
    else{
      print("HTTP return: ${req.status()}");
      print("HTTP return: ${req.result()}");
    }
    return false;
  }

  Future<bool> delete() async {
    RequestController req = RequestController(path: path);
    req.setBody(toJson());
    await req.delete();
    if(req.status() == 200){
      return true;
    }
    else{
      print("HTTP return: ${req.status()}");
      print("HTTP return: ${req.result()}");
    }
    return false;
  }

  static Future<List<Expense>> loadAll() async{
    List<Expense> result = [];
    RequestController req = RequestController(path: "/api/expenses.php");
    await req.get();
    if(req.status() == 200 && req.result() != null){
      for(var item in req.result()){
        result.add(Expense.fromJson(item));
      }
    }
    else{
      List<Map<String, dynamic>> result =
        await SQLiteDB().queryAll(SQLiteTable);
      List<Expense> expenses = [];
      for(var item in result) {
        result.add(Expense.fromJson(item) as Map<String, dynamic>);
      }
    }
    return result;
  }
}