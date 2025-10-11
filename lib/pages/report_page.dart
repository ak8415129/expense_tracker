import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    final monthlyTotal = prov.expenses.fold<double>(0, (p, e) => p + e.amount);
    final over = monthlyTotal - prov.monthlyBudget;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly total: \$${monthlyTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (over > 0)
              Text('Over budget by \$${over.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red))
            else
              Text('Under budget by \$${(-over).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => prov.shareCsv(),
              child: const Text('Export CSV & Share'),
            ),
            const SizedBox(height: 16),
            Expanded(child: Center(child: Text('Charts expanded view here'))),
          ],
        ),
      ),
    );
  }
}
