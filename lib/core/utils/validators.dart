class Validators {
  Validators._();

  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // RFC 5322 official standard regex for email validation
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  // Simple password validation (for login)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // Strong password validation (for registration)
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Must contain at least one special character';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }

  // Phone validation (optional)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  // Phone validation (required)
  static String? requiredPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and dashes for validation
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleaned.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d]{10,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number validation
  static String? number(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    
    return null;
  }

  // Min length validation
  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    
    return null;
  }

  // Max length validation
  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > max) {
      return '$fieldName must be less than $max characters';
    }
    
    return null;
  }

  // Rent validation
  static String? rent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Rent is required';
    }
    
    final rent = double.tryParse(value);
    if (rent == null) {
      return 'Enter a valid amount';
    }
    
    if (rent < 0) {
      return 'Rent cannot be negative';
    }
    
    return null;
  }
}
