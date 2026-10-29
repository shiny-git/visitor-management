import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/visitor_provider.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VisitorProvider>();

      if (provider.visitors.isEmpty) {
        provider.fetchVisitors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Register'),
      ),
      body: Consumer<VisitorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search name or mobile number',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: provider.clearSearch,
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
              ),

              Expanded(child: _buildList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(VisitorProvider provider) {
    if (provider.isLoading && provider.visitors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.visitors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 15),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: provider.fetchVisitors,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final visitors = provider.filteredVisitors;

    if (visitors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 70, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No visitors found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchVisitors,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
        itemCount: visitors.length,
        itemBuilder: (context, index) {
          final visitor = visitors[index];

          return VisitorCard(
            visitor: visitor,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
                ),
              );

              if (mounted) {
                context.read<VisitorProvider>().fetchVisitors();
              }
            },
          );
        },
      ),
    );
  }
}
