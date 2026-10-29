import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/visitor.dart';
import '../services/visitor_api_service.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorApiService _apiService = VisitorApiService();

  List<Visitor> _visitors = [];

  bool _isLoading = false;
  bool _isSubmitting = false;

  String? _errorMessage;

  String _searchQuery = '';

  List<Visitor> get visitors => _visitors;

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  List<Visitor> get filteredVisitors {
    if (_searchQuery.trim().isEmpty) {
      return _visitors;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _visitors.where((visitor) {
      return visitor.name.toLowerCase().contains(query) ||
          visitor.mobile.contains(query);
    }).toList();
  }

  Future<void> fetchVisitors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visitors = await _apiService.getVisitors();
    } catch (e) {
      _errorMessage = e.toString();
      log('error1:$_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Visitor?> fetchVisitorById(String id) async {
    try {
      return await _apiService.getVisitor(id);
    } catch (e) {
      _errorMessage = e.toString();
      log('error2:$_errorMessage');

      notifyListeners();
      return null;
    }
  }

  Future<bool> addVisitor({
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final visitor = Visitor(
        id: '',
        name: name,
        mobile: mobile,
        email: email,
        visitorType: visitorType,
        project: project,
        purpose: purpose,
        status: 'Registered',
        createdAt: DateTime.now().toIso8601String(),
        checkInTime: null,
        checkOutTime: null,
      );

      final createdVisitor = await _apiService.createVisitor(visitor);

      _visitors.insert(0, createdVisitor);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      log('error3:$_errorMessage');

      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateVisitor(Visitor visitor) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedVisitor = await _apiService.updateVisitor(
        visitor.id,
        visitor,
      );

      final index = _visitors.indexWhere((item) => item.id == visitor.id);

      if (index != -1) {
        _visitors[index] = updatedVisitor;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      log('error4:$_errorMessage');

      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVisitor(String id) async {
    _errorMessage = null;

    try {
      await _apiService.deleteVisitor(id);

      _visitors.removeWhere((visitor) => visitor.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      log('error5:$_errorMessage');

      notifyListeners();

      return false;
    }
  }

  Future<bool> checkIn(String id) async {
    final visitor = _findVisitor(id);

    if (visitor == null) {
      _errorMessage = 'Visitor not found.';
      log('error6:$_errorMessage');

      notifyListeners();
      return false;
    }

    if (visitor.status != 'Registered') {
      _errorMessage = 'Visitor cannot be checked in from current status.';
      log('error7:$_errorMessage');

      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();

      final updatedVisitor = await _apiService.patchVisitor(id, {
        'status': 'Checked In',
        'check_in_time': now,
      });

      _replaceVisitor(updatedVisitor);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      log('error8:$_errorMessage');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut(String id) async {
    final visitor = _findVisitor(id);

    if (visitor == null) {
      _errorMessage = 'Visitor not found.';
      log('error9:$_errorMessage');
      notifyListeners();
      return false;
    }

    if (visitor.status != 'Checked In') {
      _errorMessage = 'Visitor cannot be checked out from current status.';
      log('error10:$_errorMessage');
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();

      final updatedVisitor = await _apiService.patchVisitor(id, {
        'status': 'Checked Out',
        'check_out_time': now,
      });

      _replaceVisitor(updatedVisitor);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      log('error11:$_errorMessage');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Visitor? _findVisitor(String id) {
    try {
      return _visitors.firstWhere((visitor) => visitor.id == id);
    } catch (_) {
      return null;
    }
  }

  void _replaceVisitor(Visitor updatedVisitor) {
    final index = _visitors.indexWhere(
      (visitor) => visitor.id == updatedVisitor.id,
    );

    if (index != -1) {
      _visitors[index] = updatedVisitor;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // -------------------------
  // DASHBOARD STATISTICS
  // -------------------------

  bool _isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return false;
    }

    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (_) {
      return false;
    }
  }

  int get totalVisitorsToday {
    return _visitors.where((visitor) {
      return _isToday(visitor.createdAt);
    }).length;
  }

  int get currentlyCheckedIn {
    return _visitors.where((visitor) {
      return visitor.status == 'Checked In';
    }).length;
  }

  int get checkedOutToday {
    return _visitors.where((visitor) {
      return visitor.status == 'Checked Out' && _isToday(visitor.checkOutTime);
    }).length;
  }
}
