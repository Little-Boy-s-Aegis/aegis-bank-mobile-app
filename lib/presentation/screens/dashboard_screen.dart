import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bank_cyber_demo/data/repositories/repository_provider.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';
import 'package:bank_cyber_demo/domain/models/account.dart';
import 'package:bank_cyber_demo/domain/models/transaction.dart';
import 'transfer_screen.dart';
import 'transaction_history_screen.dart';
import 'security_settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Account? _account;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final registry = Provider.of<RepositoryRegistry>(context, listen: false);

    try {
      final account = await registry.accountRepository.getAccountDetails(widget.user.accountNumber);
      final txs = await registry.transactionRepository.getTransactionHistory(widget.user.accountNumber);
      
      if (mounted) {
        setState(() {
          _account = account;
          _recentTransactions = txs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  String _formatVND(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('Aegis Account', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFFE5E7EB),
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF228B22)),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.roseAccent),
            onPressed: () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome header
                    Text(
                      'Welcome, ${widget.user.fullName}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Here is your financial status overview.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF52796F)),
                    ),
                    const SizedBox(height: 24),

                    // Credit Card (Visual premium dark brand card)
                    GestureDetector(
                      onDoubleTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                        ).then((_) => _fetchData());
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B4332), Color(0xFF0F2818)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE9D8A6).withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B4332).withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PRIMARY DEBIT CARD', style: TextStyle(color: Color(0xFFE9D8A6), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Text(widget.user.fullName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Text('VISA', style: TextStyle(color: Colors.white24, fontSize: 18, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AVAILABLE BALANCE', style: TextStyle(color: Colors.white.withOpacity(0.54), fontSize: 9)),
                                const SizedBox(height: 4),
                                Text(
                                  _account != null ? _formatVND(_account!.balance) : '---',
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ACCOUNT NUMBER', style: TextStyle(color: Colors.white.withOpacity(0.54), fontSize: 8)),
                                    Text(widget.user.accountNumber, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Text('VND', style: TextStyle(color: Color(0xFFE9D8A6), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransferScreen(user: widget.user),
                                ),
                              ).then((_) => _fetchData());
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('TRANSFER'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F5E9),
                              foregroundColor: const Color(0xFF1B4332),
                              side: const BorderSide(color: Color(0xFF228B22)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionHistoryScreen(user: widget.user),
                                ),
                              ).then((_) => _fetchData());
                            },
                            icon: const Icon(Icons.history_rounded, size: 16),
                            label: const Text('HISTORY'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B4332),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TransactionHistoryScreen(user: widget.user),
                              ),
                            ).then((_) => _fetchData());
                          },
                          child: const Text('View All', style: TextStyle(color: Color(0xFF228B22), fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_error.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.rose.withOpacity(0.08), border: Border.all(color: Colors.rose.withOpacity(0.15)), borderRadius: BorderRadius.circular(16)),
                        child: Text('Error loading dashboard: $_error', style: const TextStyle(color: Colors.roseAccent, fontSize: 11, fontFamily: 'monospace')),
                      )
                    ] else if (_recentTransactions.isEmpty) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text('No transaction history found', style: TextStyle(color: Color(0xFF52796F), fontSize: 12)),
                        ),
                      )
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentTransactions.length > 3 ? 3 : _recentTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = _recentTransactions[index];
                          final isSender = tx.sourceAccountNumber == widget.user.accountNumber;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.rose.withOpacity(0.1) : Colors.emerald.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSender ? Colors.rose.withOpacity(0.2) : Colors.emerald.withOpacity(0.2)),
                                  ),
                                  child: Icon(
                                    isSender ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                                    color: isSender ? Colors.roseAccent : Colors.emeraldAccent,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                                        style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSender ? 'To: ${tx.targetAccountNumber}' : 'From: ${tx.sourceAccountNumber}',
                                        style: const TextStyle(color: Color(0xFF52796F), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${isSender ? "-" : "+"}${_formatVND(tx.amount)}',
                                  style: TextStyle(
                                    color: isSender ? Colors.roseAccent : Colors.emeraldAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}

class Colors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color purple = Color(0xFFD500F9);
  static const Color purpleAccent = Color(0xFFD500F9);
  static const Color rose = Color(0xFFFF1744);
  static const Color roseAccent = Color(0xFFFF1744);
  static const Color emerald = Color(0xFF00E676);
  static const Color emeraldAccent = Color(0xFF00E676);
  static const Color black = Color(0xFF000000);
  static const Color slateLines = Color(0xFF64748B);
  static const Color transparent = Color(0x00000000);
  static const Color yellowAccent = Color(0xFFFFEA00);
  static const Color greenAccent = Color(0xFF00E676);
}
