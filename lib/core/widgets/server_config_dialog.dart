import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  final List<Map<String, String>> _presets = const [
    {
      'label': 'Physical Device (ADB Reverse)',
      'url': 'http://127.0.0.1:8000',
      'hint': 'Works via USB / Wi-Fi adb reverse',
    },
    {
      'label': 'Local Wi-Fi (LAN)',
      'url': 'http://192.168.0.5:8000',
      'hint': 'Host IP on same Wi-Fi',
    },
    {
      'label': 'Android Emulator',
      'url': 'http://10.0.2.2:8000',
      'hint': 'Standard Android Studio emulator',
    },
    {
      'label': 'Cloud Production',
      'url': 'https://nbend.ch-farm.com.ng',
      'hint': 'Live hosted backend',
    },
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: AppConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final rawUrl = _urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
    if (rawUrl.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final response = await dio.get('$rawUrl/health');
      if (response.statusCode == 200) {
        setState(() {
          _testSuccess = true;
          _testResult = 'Connected successfully! Server is online.';
        });
      } else {
        setState(() {
          _testSuccess = false;
          _testResult = 'Server returned HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Connection failed: ${e.toString().split('\n').first}';
      });
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  void _saveAndApply() {
    final rawUrl = _urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
    if (rawUrl.isEmpty) return;

    final apiClient = context.read<ApiClient>();
    apiClient.updateBaseUrl(rawUrl);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Server URL set to: $rawUrl'),
        backgroundColor: AppColors.brand,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.dns_rounded,
                    color: AppColors.brand,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Server Configuration',
                        style: AppTypography.heading2.copyWith(fontSize: 18),
                      ),
                      Text(
                        'Configure host endpoint for local testing or cloud production',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Text input
            Text(
              'Server Base URL',
              style: AppTypography.bodyBold.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              style: AppTypography.body.copyWith(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'http://127.0.0.1:8000 or https://...',
                filled: true,
                fillColor: AppColors.backgroundPage,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick presets
            Text(
              'Quick Presets:',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = _urlController.text.trim() == preset['url'];
                return ActionChip(
                  label: Text(
                    preset['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.brandDark : AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: isSelected ? AppColors.brandLight : AppColors.backgroundPage,
                  side: BorderSide(
                    color: isSelected ? AppColors.brand : AppColors.border,
                  ),
                  onPressed: () {
                    setState(() {
                      _urlController.text = preset['url']!;
                      _testResult = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Test result feedback
            if (_testResult != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _testSuccess ? AppColors.brandLight : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess
                        ? AppColors.brand.withValues(alpha: 0.4)
                        : AppColors.danger.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess ? AppColors.brand : AppColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess ? AppColors.brandDark : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actions: Test & Save
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: OutlinedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.brand),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isTesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Test Connection',
                            style: TextStyle(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: AppButton(
                    text: 'Save & Connect',
                    onPressed: _saveAndApply,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
