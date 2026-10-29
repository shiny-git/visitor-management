import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import 'visitor_details_screen.dart';

class VisitorFormScreen extends StatefulWidget {
  final Visitor? visitor;

  const VisitorFormScreen({super.key, this.visitor});

  bool get isEditing => visitor != null;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController purposeController;

  String visitorType = 'Customer';
  String project = 'Project A';

  @override
  void initState() {
    super.initState();

    final visitor = widget.visitor;

    nameController = TextEditingController(text: visitor?.name ?? '');

    mobileController = TextEditingController(text: visitor?.mobile ?? '');

    emailController = TextEditingController(text: visitor?.email ?? '');

    purposeController = TextEditingController(text: visitor?.purpose ?? '');

    visitorType = visitor?.visitorType ?? 'Customer';

    project = visitor?.project ?? 'Project A';
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    purposeController.dispose();

    super.dispose();
  }

  Future<void> saveVisitor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<VisitorProvider>();

    bool success;

    if (widget.isEditing) {
      final oldVisitor = widget.visitor!;

      final updatedVisitor = oldVisitor.copyWith(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        visitorType: visitorType,
        project: project,
        purpose: purposeController.text.trim(),
      );

      success = await provider.updateVisitor(updatedVisitor);
    } else {
      success = await provider.addVisitor(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        visitorType: visitorType,
        project: project,
        purpose: purposeController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Visitor updated successfully'
                : 'Visitor registered successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        // Find the newly created visitor.
        final visitors = provider.visitors;

        if (visitors.isNotEmpty) {
          final visitor = visitors.first;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Visitor' : 'Register Visitor'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Visitor Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Visitor name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mobile number is required';
                }

                if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                  return 'Enter exactly 10 digits';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: visitorType,
              decoration: const InputDecoration(
                labelText: 'Visitor Type',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                DropdownMenuItem(value: 'Vendor', child: Text('Vendor')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    visitorType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: project,
              decoration: const InputDecoration(
                labelText: 'Project',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Project A', child: Text('Project A')),
                DropdownMenuItem(value: 'Project B', child: Text('Project B')),
                DropdownMenuItem(value: 'Project C', child: Text('Project C')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    project = value;
                  });
                }
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: purposeController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Purpose of Visit',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Purpose is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : saveVisitor,
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Update Visitor'
                            : 'Register Visitor',
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
