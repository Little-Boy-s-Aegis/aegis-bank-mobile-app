class Transaction {
  final int id;
  final String sourceAccountNumber;
  final String targetAccountNumber;
  final double amount;
  final String description;
  final String timestamp;
  final String status;

  Transaction({
    required this.id,
    required this.sourceAccountNumber,
    required this.targetAccountNumber,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      sourceAccountNumber: json['sourceAccountNumber'] as String,
      targetAccountNumber: json['targetAccountNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: json['timestamp'] as String,
      status: json['status'] as String,
    );
  }
}
