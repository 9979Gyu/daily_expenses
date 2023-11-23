import 'package:daily_expenses/Controller/request_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/expense.dart';

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

class _ExpenseListState extends State<ExpenseList> {

  final List<Expense> expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sumController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double sum = 0.00;
  final String username;
  _ExpenseListState(this.username);

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
            res["datetime"].toString().
            substring(0,19).replaceAll('T', ' ');
      });

      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  void _addExpense() async {
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();
    // sum += double.parse(amountController.text.trim());
    if(description.isNotEmpty && amount.isNotEmpty){
      Expense exp =
      Expense(null, double.parse(amount), description,
          txtDateController.text);

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

  void _removeExpense(int index) async {
    sum -= expenses[index].amount;

    Expense exp = Expense(expenses[index].id, 0, "", "");

    print(exp.id);

    if(await exp.delete()){
      setState((){
        expenses.removeAt(index);
        sumController.text = sum.toStringAsFixed(2);
      });

      _showMessage("Data successfully deleted");
    }
    else{
      _showMessage("Failed to delete data");
    }
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
          onSave: (editedExpense) async {
            if (await editedExpense.edit()) {
              setState(() {
                sum += editedExpense.amount - expenses[index].amount;
                expenses[index] = editedExpense;
                sumController.text = sum.toStringAsFixed(2);
              });
              _showMessage("Expense updated successfully");

            }
            else {
              _showMessage("Failed to update Expense data");
            }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                  labelText: 'Date'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: sumController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Total Spend (RM):'
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: const Text('Add Expense'),
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
            key: Key(expenses[index].amount.toString()),
            background: Container(
              color: Colors.red,
              child: const Center(
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
                  .showSnackBar(
                    const SnackBar(
                      content: Text('Item dismissed')
                    )
                  );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Column(
                  children: [
                    // edited
                    Text('Amount: ${expenses[index].amount}'),
                    // const Spacer(),
                    Text('Date: ${expenses[index].dateTime}')
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
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

class EditExpenseScreen extends StatefulWidget {
  // const EditExpenseScreen({super.key});

  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  int? id;

  @override
  void initState() {
    super.initState();
    id = widget.expense.id;
    descController.text = widget.expense.desc;
    amountController.text = widget.expense.amount.toString();
    txtDateController.text = widget.expense.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                  labelText: 'Date'
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                widget.onSave(
                  Expense(id,
                    double.parse(amountController.text),
                    descController.text,
                    txtDateController.text,
                  ),
                );

                Navigator.pop(context);
              },

              child: const Text('Save')
          ),
        ],
      ),

    );
  }
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
}
