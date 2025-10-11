class Expense {
  int? id;
  double amount;
  String category;
  DateTime date;

  Expense({this.id, required this.amount, required this.category, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as int?,
        amount: (m['amount'] as num).toDouble(),
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
      );
}
