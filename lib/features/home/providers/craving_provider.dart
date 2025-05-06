import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';

class CravingProvider extends ChangeNotifier {
  final CravingRepository _repository = CravingRepository();
  
  List<CravingModel> _cravings = [];
  bool _isLoading = false;
  String? _error;
  
  List<CravingModel> get cravings => _cravings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadCravingsForUser(String userId) async {
    _setLoading(true);
    try {
      _cravings = await _repository.getCravingsForUser(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> saveCraving(CravingModel craving) async {
    _setLoading(true);
    try {
      final savedCraving = await _repository.saveCraving(craving);
      _cravings = [savedCraving, ..._cravings];
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<int> getCravingCount(String userId) async {
    try {
      return await _repository.getCravingCountForUser(userId);
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