import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bank_cyber_demo/data/repositories/repository_provider.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';
import 'package:bank_cyber_demo/domain/models/transaction.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final User user;

  const TransactionHistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _error = '';
  String _sqlErrorDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _sqlErrorDetails = '';
    });

    final registry = Provider.of<RepositoryRegistry>(context, listen: false);

    try {
      final list = await registry.transactionRepository.getTransactionHistory(
        widget.user.accountNumber,
        search: _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _transactions = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString().replaceAll("Exception: ", "");
        setState(() {
          _transactions = [];
          _error = errMsg;
          _isLoading = false;
          // Capture verbose SQL errors for demo purposes
          if (errMsg.toLowerCase().contains("sql") || errMsg.toLowerCase().contains("parser")) {
            _sqlErrorDetails = errMsg;
            _error = "Database Query Failed.";
          }
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
        title: const Text('Aegis Ledger', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFFE5E7EB),
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: Column(
        children: [
          // Filter Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search description...',
                      hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFFAFAF5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),

          // Verbose SQL Error Box (Info Disclosure vuln demo styled cleanly)
          if (_sqlErrorDetails.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.rose.withOpacity(0.08),
                border: Border.all(color: Colors.rose.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SYSTEM ERROR: DATABASE EXCEPTION DETAILS', style: TextStyle(color: Colors.roseAccent, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(height: 6),
                  Text(_sqlErrorDetails, style: const TextStyle(color: Colors.roseAccent, fontSize: 10, fontFamily: 'monospace')),
                ],
              ),
            )
          ] else if (_error.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.rose.withOpacity(0.08),
                border: Border.all(color: Colors.rose.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error, style: const TextStyle(color: Colors.roseAccent, fontSize: 11, fontFamily: 'monospace')),
            )
          ],

          // Transaction feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions match query.', style: TextStyle(color: Color(0xFF52796F), fontSize: 12)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
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
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.rose.withOpacity(0.1) : Colors.emerald.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSender ? Colors.rose.withOpacity(0.15) : Colors.emerald.withOpacity(0.15)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSender ? 'OUT' : 'IN',
                                      style: TextStyle(color: isSender ? Colors.roseAccent : Colors.emeraldAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                                        style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isSender ? "-" : "+"}${_formatVND(tx.amount)}',
                                      style: TextStyle(
                                        color: isSender ? Colors.roseAccent : Colors.emeraldAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '#${tx.id}',
                                      style: const TextStyle(color: Colors.white24, fontSize: 8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
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
