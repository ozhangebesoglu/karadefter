class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  static String? validateName(String? value) {
    final required = validateRequired(value, 'İsim');
    if (required != null) return required;

    if (value!.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }

    if (value.length > 50) {
      return 'İsim en fazla 50 karakter olabilir';
    }

    // Sadece harf, boşluk ve Türkçe karakterler
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'İsim sadece harf içerebilir';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Telefon opsiyonel
    }

    // Türkiye telefon numarası formatı
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Geçerli bir telefon numarası girin';
    }

    return null;
  }

  static String? validateAmount(String? value) {
    final required = validateRequired(value, 'Tutar');
    if (required != null) return required;

    final amount = double.tryParse(value!.replaceAll(',', '.'));
    if (amount == null) {
      return 'Geçerli bir tutar girin';
    }

    if (amount <= 0) {
      return 'Tutar 0\'dan büyük olmalıdır';
    }

    if (amount > 999999999) {
      return 'Tutar çok büyük';
    }

    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Açıklama opsiyonel
    }

    if (value.length > 500) {
      return 'Açıklama en fazla 500 karakter olabilir';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Adres opsiyonel
    }

    if (value.length < 10) {
      return 'Adres en az 10 karakter olmalıdır';
    }

    if (value.length > 200) {
      return 'Adres en fazla 200 karakter olabilir';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email opsiyonel
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }

    return null;
  }

  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Arama terimi gereklidir';
    }

    if (value.length < 2) {
      return 'Arama terimi en az 2 karakter olmalıdır';
    }

    return null;
  }

  static bool isValidCustomerData({
    required String name,
    String? phone,
    String? address,
  }) {
    return validateName(name) == null &&
        validatePhone(phone) == null &&
        validateAddress(address) == null;
  }

  static bool isValidTransactionData({
    required int customerId,
    required String amount,
    String? description,
  }) {
    return customerId > 0 &&
        validateAmount(amount) == null &&
        validateDescription(description) == null;
  }

  static String sanitizeInput(String input) {
    // HTML tag'lerini kaldır
    final withoutHtml = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // Fazla boşlukları temizle
    final withoutExtraSpaces =
        withoutHtml.replaceAll(RegExp(r'\s+'), ' ').trim();

    return withoutExtraSpaces;
  }

  static String formatPhoneNumber(String phone) {
    // Sadece rakamları al
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 10) {
      // 0 ile başlıyorsa kaldır
      if (digits.startsWith('0')) {
        return '+90${digits.substring(1)}';
      }
      return '+90$digits';
    } else if (digits.length == 11) {
      // 0 ile başlıyorsa kaldır
      if (digits.startsWith('0')) {
        return '+90${digits.substring(1)}';
      }
      return '+$digits';
    } else if (digits.length == 12 && digits.startsWith('90')) {
      return '+$digits';
    }

    return phone; // Değişiklik yapılamazsa orijinal değeri döndür
  }
}
