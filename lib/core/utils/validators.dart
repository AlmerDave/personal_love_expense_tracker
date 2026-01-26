class Validators {
  Validators._();

  /// Validate amount is positive
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    
    final cleaned = value
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    final amount = double.tryParse(cleaned);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    
    if (amount > 9999999.99) {
      return 'Amount is too large';
    }
    
    return null;
  }

  /// Validate merchant name
  static String? validateMerchant(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a merchant name';
    }
    
    if (value.trim().length < 2) {
      return 'Merchant name is too short';
    }
    
    if (value.trim().length > 100) {
      return 'Merchant name is too long';
    }
    
    return null;
  }

  /// Validate category is selected
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  /// Validate goal amount
  static String? validateGoalAmount(String? value) {
    final amountError = validateAmount(value);
    if (amountError != null) return amountError;
    
    final cleaned = value!
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    final amount = double.parse(cleaned);
    if (amount < 100) {
      return 'Goal must be at least ₱100';
    }
    
    return null;
  }

  /// Validate notes (optional, just length check)
  static String? validateNotes(String? value) {
    if (value != null && value.length > 500) {
      return 'Notes are too long (max 500 characters)';
    }
    return null;
  }

  /// Validate custom category name
  static String? validateCustomCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a category name';
    }
    
    if (value.trim().length < 2) {
      return 'Category name is too short';
    }
    
    if (value.trim().length > 30) {
      return 'Category name is too long';
    }
    
    // Check for special characters
    final validPattern = RegExp(r'^[a-zA-Z0-9\s&]+$');
    if (!validPattern.hasMatch(value.trim())) {
      return 'Only letters, numbers, spaces and & allowed';
    }
    
    return null;
  }
}
