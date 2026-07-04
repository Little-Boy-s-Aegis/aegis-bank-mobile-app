class Account {
  final String accountNumber;
  final String fullName;
  final double balance;
  final String currency;
  final String email;

  Account({
    required this.accountNumber,
    required this.fullName,
    required this.balance,
    required this.currency,
    required this.email,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'] as String,
      fullName: json['fullName'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      email: json['email'] as String,
    );
  }
}
