import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/models/expense.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({Key? key}) : super(key: key);

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String _category = 'Food';
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: ['Food', 'Transport', 'Shopping', 'Rent', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Date: ${_date.toLocal().toString().split(' ')[0]}')),
                  TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: const Text('Select'))
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final amt = double.parse(_amountCtrl.text);
                    final e = Expense(amount: amt, category: _category, date: _date);
                    await prov.addExpense(e);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
