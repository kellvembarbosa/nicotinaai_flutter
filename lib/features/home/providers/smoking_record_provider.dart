import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/smoking_record_repository.dart';

class SmokingRecordProvider extends ChangeNotifier {
  final SmokingRecordRepository _repository = SmokingRecordRepository();
  
  List<SmokingRecordModel> _records = [];
  bool _isLoading = false;
  String? _error;
  
  List<SmokingRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadRecordsForUser(String userId) async {
    _setLoading(true);
    try {
      _records = await _repository.getRecordsForUser(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> saveRecord(SmokingRecordModel record) async {
    _setLoading(true);
    try {
      final savedRecord = await _repository.saveRecord(record);
      _records = [savedRecord, ..._records];
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<int> getRecordCount(String userId) async {
    try {
      return await _repository.getRecordCountForUser(userId);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}