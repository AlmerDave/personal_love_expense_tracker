import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../services/api_key_service.dart';

class ApiKeySetupModal extends StatefulWidget {
  final Function(String) onApiKeySaved;

  const ApiKeySetupModal({
    super.key,
    required this.onApiKeySaved,
  });

  @override
  State<ApiKeySetupModal> createState() => _ApiKeySetupModalState();
}

class _ApiKeySetupModalState extends State<ApiKeySetupModal> {
  final TextEditingController _apiKeyController = TextEditingController();
  late ApiKeyService _apiKeyService;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initApiKeyService();
  }

  Future<void> _initApiKeyService() async {
    _apiKeyService = await ApiKeyService.getInstance();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Gemini API key';
      });
      return;
    }

    if (!_apiKeyService.isValidApiKey(apiKey)) {
      setState(() {
        _errorMessage = 'Invalid API key format. Please check your key.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _apiKeyService.saveApiKey(apiKey);
    
    if (success) {
      widget.onApiKeySaved(apiKey);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to save API key. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.key_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    'Setup Gemini API Key',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            const Text(
              'To use AI features, please enter your Google Gemini API key. This will be stored securely on your device.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // API Key Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gemini API Key',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'AIzaSy...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Key',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
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