import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../health/controllers/home_controller.dart';
import '../controllers/scanner_controller.dart';
import 'widgets/log_meal_sheet.dart';
import 'widgets/meal_history_view.dart';
import 'widgets/scan_result_view.dart';

class ScannerScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const ScannerScreen({super.key, this.onNavigateTab});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  int _activeSegment = 0; // 0: Food Scanner, 1: Meal Diary
  final ImagePicker _picker = ImagePicker();
  late AnimationController _beamController;

  @override
  void initState() {
    super.initState();
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerController>().loadHistory();
    });
  }

  @override
  void dispose() {
    _beamController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          final controller = context.read<ScannerController>();
          await controller.analyseImage(bytes, filename: file.name);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _handleLogScannedMeal() async {
    final scannerController = context.read<ScannerController>();
    final result = scannerController.lastResult;
    if (result == null) return;

    final mealType = await LogMealSheet.show(context, result);
    if (mealType != null && mounted) {
      final meal = await scannerController.logScannedMeal(mealType);
      if (meal != null && mounted) {
        // Also refresh Home dashboard so calories and rings update
        context.read<HomeController>().fetchDashboardData(silent: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.foodName} logged to your meal diary!'),
            backgroundColor: AppColors.brand,
            action: SnackBarAction(
              label: 'View Diary',
              textColor: Colors.white,
              onPressed: () {
                setState(() => _activeSegment = 1);
              },
            ),
          ),
        );

        // Switch to Diary view to see logged meal
        setState(() {
          _activeSegment = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerController = context.watch<ScannerController>();
    final uiState = scannerController.uiState;
    final lastResult = scannerController.lastResult;
    final isScanning = uiState == ScannerUiState.scanning;

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Segmented Control
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.backgroundCard,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeSegment = 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _activeSegment == 0
                                      ? AppColors.brand
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 15,
                                        color: _activeSegment == 0
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Food Scanner',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _activeSegment == 0
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeSegment = 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _activeSegment == 1
                                      ? AppColors.brand
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_book_rounded,
                                        size: 15,
                                        color: _activeSegment == 1
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Meal Diary',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _activeSegment == 1
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 0: Food Scanner View / Tab 1: Meal Diary View
            Expanded(
              child: _activeSegment == 1
                  ? const MealHistoryView()
                  : uiState == ScannerUiState.result && lastResult != null
                      ? ScanResultView(
                          result: lastResult,
                          imageBytes: scannerController.previewImageBytes,
                          onLogMeal: _handleLogScannedMeal,
                          onAskAi: () => widget.onNavigateTab?.call(2), // Switch to Chat tab
                          onScanAnother: () => scannerController.resetScanner(),
                        )
                      : Column(
                          children: [
                            // Dark Tech Viewfinder matching prototype design
                            Container(
                              height: 310,
                              width: double.infinity,
                              color: const Color(0xFF09101F),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Grid overlay
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _ScannerGridPainter(),
                                    ),
                                  ),

                                  // Center Reticle with glowing green corner brackets
                                  SizedBox(
                                    width: 190,
                                    height: 190,
                                    child: Stack(
                                      children: [
                                        // Top-left bracket
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: _buildCorner(true, true),
                                        ),
                                        // Top-right bracket
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: _buildCorner(true, false),
                                        ),
                                        // Bottom-left bracket
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          child: _buildCorner(false, true),
                                        ),
                                        // Bottom-right bracket
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: _buildCorner(false, false),
                                        ),

                                        // Scanning animated laser beam
                                        if (isScanning)
                                          AnimatedBuilder(
                                            animation: _beamController,
                                            builder: (ctx, child) {
                                              return Positioned(
                                                top: 20 + (_beamController.value * 150),
                                                left: 10,
                                                right: 10,
                                                child: Container(
                                                  height: 3,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        AppColors.brand,
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.brand.withValues(alpha: 0.8),
                                                        blurRadius: 10,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                        // Center Icon or Spinner
                                        Center(
                                          child: isScanning
                                              ? const SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: CircularProgressIndicator(
                                                    color: AppColors.brand,
                                                    strokeWidth: 3,
                                                  ),
                                                )
                                              : Container(
                                                  width: 52,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.brand.withValues(alpha: 0.15),
                                                    border: Border.all(
                                                      color: AppColors.brand,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.camera_alt_rounded,
                                                    color: AppColors.brand,
                                                    size: 24,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status bar at bottom of viewfinder
                                  Positioned(
                                    bottom: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isScanning
                                            ? 'Analyzing food with NEURON AI…'
                                            : 'Position meal within frame',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action buttons & Guidelines below viewfinder
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Column(
                                  children: [
                                    if (scannerController.errorMessage != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 14),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.dangerLight,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                scannerController.errorMessage!,
                                                style: TextStyle(fontSize: 12, color: AppColors.danger),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Main capture buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 48,
                                            child: ElevatedButton.icon(
                                              onPressed: isScanning
                                                  ? null
                                                  : () => _pickImage(ImageSource.camera),
                                              icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                              label: const Text(
                                                'Take Photo',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.brand,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: SizedBox(
                                            height: 48,
                                            child: OutlinedButton.icon(
                                              onPressed: isScanning
                                                  ? null
                                                  : () => _pickImage(ImageSource.gallery),
                                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                                              label: const Text(
                                                'From Gallery',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColors.textPrimary,
                                                side: const BorderSide(color: AppColors.border, width: 1.5),
                                                backgroundColor: AppColors.backgroundCard,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // What NEURON scans card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundCard,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppColors.border),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Point camera at any meal',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'NEURON AI identifies Nigerian and continental dishes, calculates calories and macronutrients, and returns a tailored clinical safety verdict.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            alignment: WrapAlignment.center,
                                            children: [
                                              'Nigerian dishes',
                                              'Fresh produce',
                                              'Packaged foods',
                                              'Home cooking',
                                            ].map((badge) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.brandLight,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  badge,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.brand,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    const size = 26.0;
    const thickness = 3.0;
    const color = AppColors.brand;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

class _ScannerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
