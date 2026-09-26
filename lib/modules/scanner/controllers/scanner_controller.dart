import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../models/paginated_meals_model.dart';
import '../models/scan_result_model.dart';
import '../services/meal_api_service.dart';

enum ScannerUiState { idle, scanning, result, error }

class ScannerController extends ChangeNotifier {
  final MealApiService mealApiService;

  ScannerController({required this.mealApiService});

  ScannerUiState _uiState = ScannerUiState.idle;
  ScanResultModel? _lastResult;
  Uint8List? _previewImageBytes;
  String? _errorMessage;
  bool _isLogging = false;

  // Meal Diary History state
  PaginatedMealsModel _paginatedMeals = PaginatedMealsModel.empty();
  bool _isLoadingHistory = false;
  String _selectedFilter = 'All'; // 'All', 'Today', 'Last 7 Days', 'This Month'
  int _currentPage = 1;

  ScannerUiState get uiState => _uiState;
  ScanResultModel? get lastResult => _lastResult;
  Uint8List? get previewImageBytes => _previewImageBytes;
  String? get errorMessage => _errorMessage;
  bool get isLogging => _isLogging;

  PaginatedMealsModel get paginatedMeals => _paginatedMeals;
  List<MealModel> get historyMeals => _paginatedMeals.items;
  bool get isLoadingHistory => _isLoadingHistory;
  String get selectedFilter => _selectedFilter;
  int get currentPage => _currentPage;
  int get totalPages => _paginatedMeals.totalPages;
  int get totalMeals => _paginatedMeals.total;

  /// Analyze food photo bytes via backend Gemini + clinical rules engine
  Future<bool> analyseImage(Uint8List bytes, {String filename = 'meal.jpg'}) async {
    _previewImageBytes = bytes;
    _uiState = ScannerUiState.scanning;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await mealApiService.analyseFoodImage(
        bytes: bytes,
        filename: filename,
      );
      _lastResult = result;
      _uiState = ScannerUiState.result;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ScannerController] analyseImage error: $e');
      _errorMessage = 'Could not analyze food photo. Please check lighting or try another image.';
      _uiState = ScannerUiState.error;
      notifyListeners();
      return false;
    }
  }

  /// Log the analyzed scan directly into the user's meal diary
  Future<MealModel?> logScannedMeal(String mealType) async {
    if (_lastResult == null || _isLogging) return null;

    _isLogging = true;
    notifyListeners();

    try {
      final meal = await mealApiService.logMealFromScan(
        scanId: _lastResult!.scanId,
        mealType: mealType,
      );
      // Reload history silently in background
      loadHistory(refresh: true);
      return meal;
    } catch (e) {
      debugPrint('[ScannerController] logScannedMeal error: $e');
      return null;
    } finally {
      _isLogging = false;
      notifyListeners();
    }
  }

  /// Manually log a meal item
  Future<MealModel?> logManualMeal({
    required String mealType,
    required String name,
    required double calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? quantity,
  }) async {
    _isLogging = true;
    notifyListeners();

    try {
      final meal = await mealApiService.logMealManual(
        mealType: mealType,
        name: name,
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        quantity: quantity,
      );
      loadHistory(refresh: true);
      return meal;
    } catch (e) {
      debugPrint('[ScannerController] logManualMeal error: $e');
      return null;
    } finally {
      _isLogging = false;
      notifyListeners();
    }
  }

  /// Load paginated meal history with applied date filters
  Future<void> loadHistory({bool refresh = false, int? page}) async {
    if (refresh) {
      _currentPage = 1;
    } else if (page != null) {
      _currentPage = page;
    }

    _isLoadingHistory = true;
    notifyListeners();

    DateTime? start;
    DateTime? end;
    final now = DateTime.now();

    if (_selectedFilter == 'Today') {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (_selectedFilter == 'Last 7 Days') {
      start = now.subtract(const Duration(days: 7));
      end = now;
    } else if (_selectedFilter == 'This Month') {
      start = DateTime(now.year, now.month, 1);
      end = now;
    }

    try {
      final res = await mealApiService.getMealsHistoryPaginated(
        startDate: start,
        endDate: end,
        page: _currentPage,
        pageSize: 15,
      );
      _paginatedMeals = res;
    } catch (e) {
      debugPrint('[ScannerController] loadHistory error: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Apply date filter chip and reload
  void setFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    _currentPage = 1;
    loadHistory(refresh: true);
  }

  /// Navigate between pagination pages
  void goToPage(int page) {
    if (page < 1 || page > _paginatedMeals.totalPages || page == _currentPage) return;
    loadHistory(page: page);
  }

  /// Reset the scanner state back to idle camera view
  void resetScanner() {
    _uiState = ScannerUiState.idle;
    _lastResult = null;
    _previewImageBytes = null;
    _errorMessage = null;
    notifyListeners();
  }
}
