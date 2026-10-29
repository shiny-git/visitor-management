import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/visitor_provider.dart';
import '../widgets/dashboard_stat_card.dart';
import 'visitor_form_screen.dart';
import 'qr_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorProvider>().fetchVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitor Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return context.read<VisitorProvider>().fetchVisitors();
        },
        child: Consumer<VisitorProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.visitors.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  'Visitor activity overview',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                if (provider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Total Today',
                        value: provider.totalVisitorsToday.toString(),
                        icon: Icons.people,
                        iconColor: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Checked In',
                        value: provider.currentlyCheckedIn.toString(),
                        icon: Icons.login,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                DashboardStatCard(
                  title: 'Checked Out Today',
                  value: provider.checkedOutToday.toString(),
                  icon: Icons.logout,
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 30),

                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VisitorFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register Visitor'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const QRScannerScreen(openedFromDashboard: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
