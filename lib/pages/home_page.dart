import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/pages/add_expense_page.dart';
import 'package:expense_tracker/pages/report_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prompt for name after first frame if it's empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ExpenseProvider>(context, listen: false);
      if (prov.userName.isEmpty && !prov.askedForName) {
        _showNameDialog(prov);
      }
    });
  }

  Future<void> _showNameDialog(ExpenseProvider prov) async {
    _nameCtrl.text = prov.userName;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome!'),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isNotEmpty) {
                prov.setUserName(_nameCtrl.text.trim());
                prov.setAskedForName(true);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _showBudgetDialog(ExpenseProvider prov) async {
    final ctrl = TextEditingController(text: prov.monthlyBudget.toStringAsFixed(0));
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Monthly Budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Budget'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null) prov.setMonthlyBudget(val);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    final now = DateTime.now();
    final monthlyTotal = prov.expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (p, e) => p + e.amount);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Hi, ${prov.userName.isEmpty ? 'User' : prov.userName}')),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Budget: \$${prov.monthlyBudget.toStringAsFixed(0)}'),
                Text('Spent: \$${monthlyTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit budget',
            onPressed: () => _showBudgetDialog(prov),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Bar chart placeholder
            Card(
              child: SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BarChartWidget(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Pie chart placeholder
            Card(
              child: SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: PieChartWidget(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: ExpenseList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage())),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    if (prov.expenses.isEmpty) return const Center(child: Text('No data'));

    // Aggregate by date (day)
    final Map<DateTime, double> sums = {};
    for (final e in prov.expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      sums[day] = (sums[day] ?? 0) + e.amount;
    }

    final entries = sums.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // Limit to last N days for readability
    const int maxPoints = 10;
    final start = entries.length > maxPoints ? entries.length - maxPoints : 0;
    final visible = entries.sublist(start);

    final labels = visible.map((e) => DateFormat.Md().format(e.key)).toList();
    final values = visible.map((e) => e.value).toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue * 1.2).clamp(10, double.infinity);

    final barGroups = values.asMap().entries.map((entry) {
      final i = entry.key;
      final v = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: v, width: 18, borderRadius: BorderRadius.circular(6))],
      );
    }).toList();

    return BarChart(BarChartData(
      maxY: maxY.toDouble(),
      barGroups: barGroups,
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 5),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox.shrink();
              final txt = labels[i];
              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(txt, style: const TextStyle(fontSize: 10)));
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    ));
  }
}

class PieChartWidget extends StatelessWidget {
  PieChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    final byCat = <String, double>{};
    for (var e in prov.expenses) {
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
    }
    final items = byCat.entries.toList();
    if (items.isEmpty) return const Center(child: Text('No data'));

    final total = items.fold<double>(0, (p, e) => p + e.value);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];

    final sections = items.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final percent = total == 0 ? 0 : (e.value / total * 100);
      return PieChartSectionData(
        value: e.value,
        color: colors[i % colors.length],
        title: '${percent.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 20)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 12, color: colors[i % colors.length]),
                      const SizedBox(width: 6),
                      Text('${e.key} (\$${e.value.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}

class ExpenseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    return ListView.builder(
      itemCount: prov.expenses.length,
      itemBuilder: (context, i) {
        final e = prov.expenses[i];
        return ListTile(
          title: Text(e.category),
          subtitle: Text(DateFormat.yMMMd().format(e.date)),
          trailing: Text('\$${e.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
