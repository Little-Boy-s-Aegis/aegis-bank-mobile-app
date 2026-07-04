import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bank_cyber_demo/data/repositories/repository_provider.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';

class TransferScreen extends StatefulWidget {
  final User user;

  const TransferScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _sourceAccountController = TextEditingController();
  final _targetAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  String _success = '';

  @override
  void initState() {
    super.initState();
    _sourceAccountController.text = widget.user.accountNumber;
  }

  Future<void> _executeTransfer() async {
    final String finalSource = _sourceAccountController.text.trim();
    final String finalTarget = _targetAccountController.text.trim();
    final double? amount = double.tryParse(_amountController.text);
    final String finalDescription = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
      _error = '';
      _success = '';
    });

    // 1. Recipient account format validation
    final RegExp accRegex = RegExp(r'^ACC-\d{6}$');
    if (!accRegex.hasMatch(finalTarget)) {
      setState(() {
        _error = "Recipient account must be in ACC-XXXXXX format (e.g., ACC-123456).";
        _isLoading = false;
      });
      return;
    }

    if (finalSource == finalTarget) {
      setState(() {
        _error = "Source and recipient account numbers must be different.";
        _isLoading = false;
      });
      return;
    }

    // 2. Positive amount validation
    if (amount == null || amount <= 0) {
      setState(() {
        _error = "Transfer amount must be a valid positive number greater than zero.";
        _isLoading = false;
      });
      return;
    }

    // 3. Description validation
    if (finalDescription.isEmpty) {
      setState(() {
        _error = "Description message is required.";
        _isLoading = false;
      });
      return;
    }

    final double finalAmount = amount;
    final registry = Provider.of<RepositoryRegistry>(context, listen: false);

    try {
      await registry.transactionRepository.transferMoney(
        finalSource,
        finalTarget,
        finalAmount,
        finalDescription,
      );

      setState(() {
        _success = "Transfer completed successfully.";
        _isLoading = false;
        _targetAccountController.clear();
        _amountController.clear();
        _descriptionController.clear();
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('Aegis Transfer', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFFE5E7EB),
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEW TRANSACTION',
              style: TextStyle(color: Color(0xFF228B22), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill recipient details to transfer funds inside Aegis Bank.',
              style: TextStyle(color: Color(0xFF52796F), fontSize: 12),
            ),
            const SizedBox(height: 24),

            if (_error.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.rose.withOpacity(0.08),
                  border: Border.all(color: Colors.rose.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error, style: const TextStyle(color: Colors.roseAccent, fontSize: 11, fontFamily: 'monospace')),
              )
            ],

            if (_success.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.emerald.withOpacity(0.08),
                  border: Border.all(color: Colors.emerald.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_success, style: const TextStyle(color: Colors.emeraldAccent, fontSize: 11, fontFamily: 'monospace')),
              )
            ],

            // Transfer From Account
            const Text('TRANSFER FROM ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF52796F))),
            const SizedBox(height: 8),
            TextField(
              controller: _sourceAccountController,
              style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Source account number',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recipient Account
            const Text('RECIPIENT ACCOUNT NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF52796F))),
            const SizedBox(height: 8),
            TextField(
              controller: _targetAccountController,
              style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. ACC-987654',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount
            const Text('AMOUNT (VND)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF52796F))),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. 500000',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF52796F))),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Electricity bill payment',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _executeTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'EXECUTE TRANSFER',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
              ),
            ),
          ],
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
