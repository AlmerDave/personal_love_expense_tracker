import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'gemini_service.dart';
import 'connectivity_service.dart';

class ReceiptScannerService {
  ReceiptScannerService._();

  static final ReceiptScannerService instance = ReceiptScannerService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Take photo with camera
  Future<XFile?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Process receipt image and extract total
  Future<ReceiptScanResult> processReceipt(XFile imageFile) async {
    // Check connectivity first
    final hasConnection = await ConnectivityService.instance.hasInternetConnection();
    if (!hasConnection) {
      return ReceiptScanResult(
        success: false,
        errorMessage: 'No internet connection. Please connect to the internet to scan receipts.',
      );
    }

    try {
      // Read image bytes
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Extract total using Gemini
      final extractedAmount = await GeminiService.instance.extractReceiptTotal(base64Image);

      if (extractedAmount != null) {
        return ReceiptScanResult(
          success: true,
          extractedAmount: extractedAmount,
          imagePath: imageFile.path,
        );
      } else {
        return ReceiptScanResult(
          success: false,
          errorMessage: 'Could not find the total amount on the receipt. Please enter it manually.',
          imagePath: imageFile.path,
        );
      }
    } catch (e) {
      return ReceiptScanResult(
        success: false,
        errorMessage: 'Failed to process receipt: ${e.toString()}',
      );
    }
  }
}

class ReceiptScanResult {
  final bool success;
  final double? extractedAmount;
  final String? imagePath;
  final String? errorMessage;

  ReceiptScanResult({
    required this.success,
    this.extractedAmount,
    this.imagePath,
    this.errorMessage,
  });
}
