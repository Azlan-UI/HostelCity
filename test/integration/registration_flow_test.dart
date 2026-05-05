import 'package:flutter_test/flutter_test.dart';


/// Integration tests for registration flow with document uploads
/// These tests simulate the full registration workflow
void main() {
  group('Registration Flow Integration Tests', () {
    test('Complete student registration flow validation', () {
      // Arrange - Simulate a complete student registration
      final registrationData = {
        'name': 'Test Student',
        'email': 'student@test.com',
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 2,
      };
      
      // Act - Validate all fields
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], true);
      expect(validationResults['errors'], isEmpty);
    });

    test('Should fail student registration without student card', () {
      // Arrange
      final registrationData = {
        'name': 'Test Student',
        'email': 'student@test.com',
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': false, // Missing!
        'certificateCount': 2,
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('Student card is required'));
    });

    test('Should fail student registration without certificates', () {
      // Arrange
      final registrationData = {
        'name': 'Test Student',
        'email': 'student@test.com',
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 0, // Missing!
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('At least one certificate is required'));
    });

    test('Should fail student registration with too many certificates', () {
      // Arrange
      final registrationData = {
        'name': 'Test Student',
        'email': 'student@test.com',
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 6, // Too many!
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('Maximum 5 certificates allowed'));
    });

    test('Complete hostel admin registration flow validation', () {
      // Arrange
      final registrationData = {
        'name': 'Test Admin',
        'email': 'admin@test.com',
        'password': 'Admin123!@#',
        'phone': '0987654321',
        'province': 'Sindh',
        'city': 'Karachi',
        'role': 'hostelAdmin',
        'hasCNIC': true,
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], true);
      expect(validationResults['errors'], isEmpty);
    });

    test('Should fail hostel admin registration without CNIC', () {
      // Arrange
      final registrationData = {
        'name': 'Test Admin',
        'email': 'admin@test.com',
        'password': 'Admin123!@#',
        'phone': '0987654321',
        'province': 'Sindh',
        'city': 'Karachi',
        'role': 'hostelAdmin',
        'hasCNIC': false, // Missing!
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('CNIC is required'));
    });

    test('Should fail registration with invalid email', () {
      // Arrange
      final registrationData = {
        'name': 'Test User',
        'email': 'invalid-email', // Invalid!
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 1,
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('Invalid email format'));
    });

    test('Should fail registration with weak password', () {
      // Arrange
      final registrationData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': '123', // Too weak!
        'phone': '1234567890',
        'province': 'Punjab',
        'city': 'Lahore',
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 1,
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], isNotEmpty);
      final errors = validationResults['errors'] as List;
      expect(
        errors.any((e) => e.toString().contains('Password must be')),
        true,
        reason: 'Should have password-related error',
      );
    });

    test('Should fail registration without province/city', () {
      // Arrange
      final registrationData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'Test123!@#',
        'phone': '1234567890',
        'province': null, // Missing!
        'city': null, // Missing!
        'role': 'student',
        'hasStudentCard': true,
        'certificateCount': 1,
      };
      
      // Act
      final validationResults = _validateRegistration(registrationData);
      
      // Assert
      expect(validationResults['isValid'], false);
      expect(validationResults['errors'], contains('Province and city are required'));
    });
  });
}

/// Validation helper that mimics the actual registration validation logic
Map<String, dynamic> _validateRegistration(Map<String, dynamic> data) {
  final List<String> errors = [];
  
  // Validate name
  if (data['name'] == null || data['name'].toString().isEmpty) {
    errors.add('Name is required');
  }
  
  // Validate email
  final email = data['email']?.toString() ?? '';
  if (email.isEmpty) {
    errors.add('Email is required');
  } else if (!_isValidEmail(email)) {
    errors.add('Invalid email format');
  }
  
  // Validate password
  final password = data['password']?.toString() ?? '';
  if (password.isEmpty) {
    errors.add('Password is required');
  } else if (!_isStrongPassword(password)) {
    errors.add('Password must be at least 8 characters with uppercase, number, and special character');
  }
  
  // Validate location
  if (data['province'] == null || data['city'] == null) {
    errors.add('Province and city are required');
  }
  
  // Validate role-specific documents
  final role = data['role']?.toString() ?? '';
  
  if (role == 'student') {
    if (data['hasStudentCard'] != true) {
      errors.add('Student card is required');
    }
    
    final certCount = data['certificateCount'] as int? ?? 0;
    if (certCount == 0) {
      errors.add('At least one certificate is required');
    } else if (certCount > 5) {
      errors.add('Maximum 5 certificates allowed');
    }
  } else if (role == 'hostelAdmin') {
    if (data['hasCNIC'] != true) {
      errors.add('CNIC is required');
    }
  }
  
  return {
    'isValid': errors.isEmpty,
    'errors': errors,
  };
}

bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool _isStrongPassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
  return true;
}
