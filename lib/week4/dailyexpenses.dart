import 'package:daily_expenses/Controller/request_controller.dart';
import 'package:flutter/material.dart';

import '../Model/expense.dart';

void main() {
  runApp(DailyExpensesApp(username: ""));
}

class DailyExpensesApp extends StatelessWidget {

  final String username;
  DailyExpensesApp({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: ExpenseList(username),
    );
  }
}

class ExpenseList extends StatefulWidget {
  final String username;
  ExpenseList(this.username);

  @override
  _ExpenseListState createState() => _ExpenseListState(username);
}

class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    descController.text = expense.desc;
    amountController.text = expense.amount as String;
    txtDateController.text = expense.dateTime;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              decoration: InputDecoration(
                  labelText: 'Date'
              ),
            ),
          ),
          ElevatedButton(
              onPressed: (){
                // edited
                onSave(
                    Expense(
                        (double.parse(amountController.text)),
                        descController.text,
                        expense.dateTime,
                    )
                );

                // var itemPassed = {
                //   "amount": amountController.text,
                //   "desc": descController.text,
                // };

                // Navigator.pop(context, itemPassed);
                Navigator.pop(context);
              },
              child: Text('Save')
          ),
        ],
      ),

    );
  }

}

class _ExpenseListState extends State<ExpenseList> {

  final List<Expense> expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sumController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double sum = 0;
  final String username;
  _ExpenseListState(this.username);

  void _addExpense() async {
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();
    // sum += double.parse(amountController.text.trim());
    if(description.isNotEmpty && amount.isNotEmpty){
      Expense exp =
          Expense(double.parse(amount), description, txtDateController.text);

      if(await exp.save()){
        setState(() {
          expenses.add(exp);
          descriptionController.clear();
          amountController.clear();
          calculateTotal();
        });
      }
      else{
        _showMessage("Failed to save Expense data");
      }
    }
  }

  void calculateTotal(){
    sum = 0;
    for(Expense ex in expenses){
      sum += ex.amount;
    }
    sumController.text = sum.toStringAsFixed(2);
  }

  void _removeExpense(int index){
    sum -= expenses[index].amount;
    setState((){
      expenses.removeAt(index);
      sumController.text = sum.toStringAsFixed(2);
    });
  }

  // function to display message at bottom of Scaffold
  void _showMessage(String msg){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  // Navigate to Edit Screen when long press on the itemlist
  // edited
  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) {
            setState((){
              sum += editedExpense.amount - expenses[index].amount;
              expenses[index] = editedExpense;
              sumController.text = sum.toStringAsFixed(2);
              //txtDateController.text =
            });
          },
        ),
      ),
    );
  }

  // new function - Date and time picker on textfield
  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if(pickedDate != null && pickedTime != null){
      setState((){
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} "
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  // new
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)
    async {
      _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org"
      );
      req.get().then((value) {
        dynamic res = req.result();
        txtDateController.text =
            res["datetime"].toString().substring(0,19).replaceAll('T', ' ');
      });

      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  labelText: 'Description'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                  labelText: 'Date'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: sumController,
              readOnly: true,
              decoration: InputDecoration(
                  labelText: 'Total Spend (RM):'
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(){
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context,index){
          return Dismissible(
            key: Key(expenses[index].amount as String),
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction){
              _removeExpense(index);
              // show message of item deleted == alert in javascript
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Row(
                  children: [
                    // edited
                    Text('Amount: ${expenses[index].amount}'),
                    const Spacer(),
                    Text('Date: ${expenses[index].dateTime}')
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: () {
                  _editExpense(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


// class Expense {
//   final String description;
//   final String amount;
//
//   Expense(this.description, this.amount);
// }