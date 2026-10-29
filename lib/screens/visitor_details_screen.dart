import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/status_chip.dart';
import 'visitor_form_screen.dart';

class VisitorDetailsScreen extends StatefulWidget {
  final String visitorId;

  const VisitorDetailsScreen({super.key, required this.visitorId});

  @override
  State<VisitorDetailsScreen> createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  Visitor? visitor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVisitor();
  }

  Future<void> loadVisitor() async {
    final provider = context.read<VisitorProvider>();

    Visitor? result;

    try {
      result = provider.visitors.firstWhere(
        (item) => item.id == widget.visitorId,
      );
    } catch (_) {
      result = await provider.fetchVisitorById(widget.visitorId);
    }

    if (mounted) {
      setState(() {
        visitor = result;
        isLoading = false;
      });
    }
  }

  Future<void> checkIn() async {
    final success = await context.read<VisitorProvider>().checkIn(
      widget.visitorId,
    );

    if (!mounted) return;

    if (success) {
      await loadVisitor();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor checked in successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = context.read<VisitorProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Check-in failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> checkOut() async {
    final success = await context.read<VisitorProvider>().checkOut(
      widget.visitorId,
    );

    if (!mounted) return;

    if (success) {
      await loadVisitor();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor checked out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = context.read<VisitorProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Check-out failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteVisitor() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Visitor'),
          content: const Text('Are you sure you want to delete this visitor?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await context.read<VisitorProvider>().deleteVisitor(
      widget.visitorId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<VisitorProvider>().errorMessage ?? 'Delete failed',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not available';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (visitor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visitor Details')),
        body: const Center(child: Text('Visitor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitorFormScreen(visitor: visitor),
                ),
              );

              await loadVisitor();
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: deleteVisitor,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadVisitor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      child: Text(
                        visitor!.name.isNotEmpty
                            ? visitor!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      visitor!.name,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    StatusChip(status: visitor!.status),

                    const SizedBox(height: 20),

                    _InfoRow(
                      icon: Icons.phone,
                      title: 'Mobile',
                      value: visitor!.mobile,
                    ),

                    _InfoRow(
                      icon: Icons.email,
                      title: 'Email',
                      value: visitor!.email?.isNotEmpty == true
                          ? visitor!.email!
                          : 'Not provided',
                    ),

                    _InfoRow(
                      icon: Icons.badge,
                      title: 'Visitor Type',
                      value: visitor!.visitorType,
                    ),

                    _InfoRow(
                      icon: Icons.apartment,
                      title: 'Project',
                      value: visitor!.project,
                    ),

                    _InfoRow(
                      icon: Icons.description,
                      title: 'Purpose',
                      value: visitor!.purpose,
                    ),

                    _InfoRow(
                      icon: Icons.calendar_today,
                      title: 'Registered',
                      value: formatDate(visitor!.createdAt),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Visitor QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    QrImageView(
                      data: visitor!.id,
                      version: QrVersions.auto,
                      size: 220,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Visitor ID: ${visitor!.id}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Scan this QR code at the security desk.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visit Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _TimelineRow(
                      title: 'Check In',
                      value: formatDate(visitor!.checkInTime),
                      icon: Icons.login,
                    ),

                    _TimelineRow(
                      title: 'Check Out',
                      value: formatDate(visitor!.checkOutTime),
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (visitor!.status == 'Registered')
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: checkIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Check In'),
                ),
              ),

            if (visitor!.status == 'Checked In')
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: checkOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Check Out'),
                ),
              ),

            if (visitor!.status == 'Checked Out')
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(child: Text('This visit has been completed.')),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TimelineRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(radius: 18, child: Icon(icon, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
