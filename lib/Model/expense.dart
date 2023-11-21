import '../Controller/request_controller.dart';

class Expense {
  int? id;
  String desc;
  double amount;
  String dateTime;
  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
    : desc = json['desc'] as String,
      amount = double.parse(json['amount'] as dynamic),
      dateTime = json['dateTime'] as String;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
    {'desc': desc, 'amount': amount, 'dateTime': dateTime};

  Future<bool> save() async {
    RequestController req = RequestController(path: "/api/expenses.php");
    req.setBody(toJson());
    await req.post();
    if(req.status() == 200){
      return true;
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
      print("is not connected");
    }
    return result;
  }
}