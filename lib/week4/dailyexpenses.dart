import 'package:flutter/material.dart';

void main() {
  runApp(DailyExpensesApp(username: ""));
}

class Expense {
  final String description;
  final String amount;

  Expense(this.description, this.amount);
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

  @override
  Widget build(BuildContext context) {

    descController.text = expense.description;
    amountController.text = expense.amount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          ElevatedButton(
              onPressed: (){
                onSave(
                    Expense(
                        descController.text, amountController.text
                    )
                );

                var itemPassed = {
                  "amount": amountController.text,
                  "desc": descController.text,
                };

                Navigator.pop(context, itemPassed);
              },
              child: Text('Save me')
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

  double sum = 0;
  final String username;
  _ExpenseListState(this.username);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text('Welcome $username'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void _addExpense() {
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();
    sum += double.parse(amountController.text.trim());
    if(description.isNotEmpty && amount.isNotEmpty){
      setState(() {
        expenses.add(Expense(description, amount));
        descriptionController.clear();
        amountController.clear();
        sumController.text = sum.toStringAsFixed(2);
      });
    }
  }

  void _removeExpense(int index){
    sum -= double.parse(expenses[index].amount);
    setState((){
      expenses.removeAt(index);
      sumController.text = sum.toStringAsFixed(2);
    });
  }

  void _editExpense(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) {
            setState((){
              sum += double.parse(editedExpense.amount) -
                  double.parse(expenses[index].amount);
              expenses[index] = editedExpense;
              sumController.text = sum.toString();
            });
          },
        ),
      ),
    );
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
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  labelText: 'Description'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: sumController,
                readOnly: true,
                decoration: InputDecoration(
                    labelText: 'Total Spend (RM):'
                ),
              )
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
            key: Key(expenses[index].amount),
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
                title: Text(expenses[index].description),
                subtitle: Text('Amount: ${expenses[index].amount}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: () => _editExpense(index),
              ),
            ),
          );
        },
      ),
    );
  }
}