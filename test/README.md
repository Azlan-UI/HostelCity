# Testing Documentation

## Automated Tests for Document Uploads

This directory contains automated tests for the registration and document upload functionality.

### Test Files

#### 1. `services/document_upload_validation_test.dart`
**Unit tests** for document upload validation logic:
- Student card requirement validation
- Certificate requirement validation (1-5 certificates)
- CNIC requirement validation for hostel admins
- Email format validation
- Password strength validation
- Location (province/city) validation

**Run these tests:**
```bash
flutter test test/services/document_upload_validation_test.dart
```

#### 2. `integration/registration_flow_test.dart`
**Integration tests** for the complete registration flow:
- Complete student registration with all documents
- Complete hostel admin registration with CNIC
- Missing student card scenario
- Missing certificates scenario
- Too many certificates scenario
- Invalid email/password scenarios
- Missing location data

**Run these tests:**
```bash
flutter test test/integration/registration_flow_test.dart
```

### Running All Tests

To run all tests at once:
```bash
flutter test
```

To run with verbose output:
```bash
flutter test --reporter expanded
```

To run tests with coverage:
```bash
flutter test --coverage
```

### Test Coverage

These tests cover:
- ✅ Document validation for students (student card + certificates)
- ✅ Document validation for hostel admins (CNIC)
- ✅ Certificate count limits (0-5)
- ✅ Form field validation (email, password, location)
- ✅ Complete registration flow scenarios
- ✅ Error handling and validation messages

### What's NOT Covered (Requires Manual Testing)

These scenarios require Firebase integration and must be tested manually:
- ❌ Actual Firebase Storage uploads
- ❌ Firebase Auth account creation
- ❌ Firestore database writes
- ❌ Network timeout scenarios
- ❌ Duplicate account detection in Firestore
- ❌ Ghost account recovery/cleanup
- ❌ Verification status routing

See the main implementation plan for manual testing procedures.

### Writing Additional Tests

To add more tests:

1. **Unit tests**: Add to `test/services/` for single-function validation
2. **Integration tests**: Add to `test/integration/` for multi-step workflows
3. **Widget tests**: Add to `test/widgets/` for UI component testing

Example:
```dart
test('description of what you are testing', () {
  // Arrange - Set up test data
  final testData = ...;
  
  // Act - Execute the code being tested
  final result = functionUnderTest(testData);
  
  // Assert - Verify the result
  expect(result, expectedValue, reason: 'explain why this matters');
});
```

### Continuous Integration

These tests can be run automatically in CI/CD pipelines:
```yaml
# Example GitHub Actions workflow
- name: Run Flutter tests
  run: flutter test
```
