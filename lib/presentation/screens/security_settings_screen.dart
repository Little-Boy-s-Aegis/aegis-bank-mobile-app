import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_cyber_demo/data/repositories/repository_provider.dart';
import 'package:bank_cyber_demo/presentation/bloc/security_cubit.dart';
import 'package:bank_cyber_demo/data/api/dio_client.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ipController.text = DioClient.baseIp;
    _portController.text = DioClient.port;
  }

  @override
  Widget build(BuildContext context) {
    final registry = Provider.of<RepositoryRegistry>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('Aegis Environment', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
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
              'ENVIRONMENT CONFIGURATION',
              style: TextStyle(color: Color(0xFF228B22), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Switch between Mock API repository (offline) and Real API backend server connection.',
              style: TextStyle(color: Color(0xFF52796F), fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Mock Mode Toggle Switch (White card background)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mock API Offline Mode', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          registry.useMock ? 'Using locally simulated repository' : 'Communicating with real backend API',
                          style: const TextStyle(color: Color(0xFF52796F), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: registry.useMock,
                    onChanged: (val) {
                      registry.toggleMockMode(val);
                    },
                    activeColor: const Color(0xFF228B22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Server connection configuration (Visible when Mock mode is OFF)
            if (!registry.useMock) ...[
              const Text(
                'BACKEND SERVER PATH',
                style: TextStyle(color: Color(0xFF228B22), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SERVER HOST IP', style: TextStyle(color: Color(0xFF52796F), fontSize: 9)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _ipController,
                                style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 10.0.2.2',
                                  filled: true,
                                  fillColor: Color(0xFFFAFAF5),
                                  border: OutlineInputBorder(borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SERVER PORT', style: TextStyle(color: Color(0xFF52796F), fontSize: 9)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _portController,
                                style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 8080',
                                  filled: true,
                                  fillColor: Color(0xFFFAFAF5),
                                  border: OutlineInputBorder(borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          registry.updateServerConfig(
                            _ipController.text.trim(),
                            _portController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Server configuration updated successfully.'),
                              backgroundColor: Color(0xFF1B4332),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: const Text('Save Server Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Remote Security Configuration control switches (Connected to backend)
              const Text(
                'REMOTE VULNERABILITY TOGGLES (SPRING BOOT)',
                style: TextStyle(color: Color(0xFF228B22), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              
              BlocProvider(
                create: (_) => SecurityCubit()..fetchStatus(),
                child: BlocBuilder<SecurityCubit, SecurityState>(
                  builder: (context, state) {
                    if (state is SecurityLoading) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)));
                    }
                    if (state is SecurityLoaded) {
                      final status = state.status;
                      
                      return Column(
                        children: [
                          _buildVulnerabilityTile(context, 'SQLI', 'SQL Injection (SQLi)', status.sqliEnabled),
                          _buildVulnerabilityTile(context, 'XSS', 'Stored Cross-Site Scripting', status.xssEnabled),
                          _buildVulnerabilityTile(context, 'IDOR', 'IDOR / BOLA Details', status.idorEnabled),
                          _buildVulnerabilityTile(context, 'PARAM_TAMPERING', 'Parameters Tampering Rules', status.paramTamperingEnabled),
                          _buildVulnerabilityTile(context, 'BRUTE_FORCE', 'Brute Force Rate Limiting', status.bruteForceEnabled),
                        ],
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.rose.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'Failed to load remote vulnerability configurations. Is the Spring Boot backend server running?',
                        style: TextStyle(color: Colors.roseAccent, fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildVulnerabilityTile(BuildContext context, String key, String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  active ? 'SHIELD INACTIVE (VULNERABLE)' : 'SHIELD ACTIVE (MITIGATED)',
                  style: TextStyle(color: active ? Colors.roseAccent : Colors.emeraldAccent, fontSize: 9, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: (val) {
              context.read<SecurityCubit>().toggleSetting(key, val);
            },
            activeColor: Colors.roseAccent,
          )
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
