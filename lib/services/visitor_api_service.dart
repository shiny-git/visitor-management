import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/visitor.dart';

class VisitorApiService {
  // IMPORTANT:
  // Replace this with your actual MockAPI project URL.
  static const String baseUrl =
      'https://6ae18f58be3bc8fead98bc7d.mockapi.io/api/v1';

  Future<List<Visitor>> getVisitors() async {
    final response = await http.get(Uri.parse('$baseUrl/visitors'));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => Visitor.fromJson(json)).toList();
    }

    throw Exception('Failed to load visitors. Status: ${response.statusCode}');
  }

  Future<Visitor> getVisitor(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/visitors/$id'));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Visitor.fromJson(jsonDecode(response.body));
    }

    throw Exception('Visitor not found. Status: ${response.statusCode}');
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visitors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visitor.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Visitor.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create visitor. Status: ${response.statusCode}');
  }

  Future<Visitor> updateVisitor(String id, Visitor visitor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/visitors/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visitor.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Visitor.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update visitor. Status: ${response.statusCode}');
  }

  Future<Visitor> patchVisitor(String id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/visitors/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Visitor.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update visitor. Status: ${response.statusCode}');
  }

  Future<void> deleteVisitor(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/visitors/$id'));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception('Failed to delete visitor. Status: ${response.statusCode}');
  }
}
