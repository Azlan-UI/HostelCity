import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/room_category.dart';
import '../../../domain/enums/gender_type.dart';
import '../../../domain/enums/verification_enums.dart';
import '../../providers/hostel_providers.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/location_picker_screen.dart';
import '../../widgets/common/province_city_selector.dart';
import '../../widgets/common/document_upload_widget.dart';
import '../../providers/service_providers.dart';
import '../../../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';


class AddHostelScreen extends ConsumerStatefulWidget {
  final HostelModel? hostel;
  
  const AddHostelScreen({super.key, this.hostel});

  @override
  ConsumerState<AddHostelScreen> createState() => _AddHostelScreenState();
}

class _AddHostelScreenState extends ConsumerState<AddHostelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _minRentController = TextEditingController();
  final _maxRentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _totalBedsController = TextEditingController();
  
  String? _selectedProvince;
  String? _selectedCity;
  
  // Facilities and Rules
  final _facilitiesController = TextEditingController();
  final List<String> _facilities = [];
  final _rulesController = TextEditingController();
  final List<String> _rules = [];

  GenderType _selectedGender = GenderType.mixed;
  LatLng? _selectedLocation;
  final List<RoomCategory> _roomCategories = [];
  XFile? _registrationDoc;
  bool _isUploadingDoc = false;
  bool _isLoading = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (widget.hostel != null) {
      final hostel = widget.hostel!;
      _nameController.text = hostel.name;
      _addressController.text = hostel.address;
      _selectedProvince = hostel.province;
      _selectedCity = hostel.city;
      _areaController.text = hostel.area;
      _regNumberController.text = hostel.registrationNumber;
      _contactNumberController.text = hostel.contactNumber;
      _emailController.text = hostel.email;
      _minRentController.text = hostel.minRent.toString();
      _maxRentController.text = hostel.maxRent.toString();
      _descriptionController.text = hostel.description ?? '';
      _totalRoomsController.text = hostel.totalRooms?.toString() ?? '';
      _totalBedsController.text = hostel.totalBeds?.toString() ?? '';
      _selectedGender = hostel.genderType;
      _selectedLocation = hostel.coordinates;
      _facilities.addAll(hostel.facilities);
      _rules.addAll(hostel.rules);
      _roomCategories.addAll(hostel.roomCategories);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _regNumberController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _minRentController.dispose();
    _maxRentController.dispose();
    _descriptionController.dispose();
    _totalRoomsController.dispose();
    _totalBedsController.dispose();
    _facilitiesController.dispose();
    _rulesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    // Basic validation per step if needed, or just validate whole form at end
    // For a better UX, we validate the visible fields
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _regNumberController.text.isEmpty || 
          _contactNumberController.text.isEmpty || _emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return false;
      }
    } else if (_currentStep == 1) {
      if (_addressController.text.isEmpty || _selectedCity == null || _selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide full location details')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed<LatLng>(
      context,
      AppRouter.locationPicker,
      arguments: _selectedLocation,
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _addFacility() {
    if (_facilitiesController.text.isNotEmpty) {
      setState(() {
        _facilities.add(_facilitiesController.text.trim());
        _facilitiesController.clear();
      });
    }
  }

  void _addRule() {
    if (_rulesController.text.isNotEmpty) {
      setState(() {
        _rules.add(_rulesController.text.trim());
        _rulesController.clear();
      });
    }
  }

  void _showAddCategoryDialog() {
    final seaterController = TextEditingController();
    final rentController = TextEditingController();
    final bedsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Room Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: seaterController,
              decoration: const InputDecoration(labelText: 'Seater Type (e.g. 2 for 2-seater)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: rentController,
              decoration: const InputDecoration(labelText: 'Monthly Rent'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bedsController,
              decoration: const InputDecoration(labelText: 'Total Beds in this category'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (seaterController.text.isNotEmpty && rentController.text.isNotEmpty && bedsController.text.isNotEmpty) {
                setState(() {
                  _roomCategories.add(RoomCategory(
                    seaterType: int.parse(seaterController.text),
                    rent: double.parse(rentController.text),
                    totalBeds: int.parse(bedsController.text),
                    availableBeds: int.parse(bedsController.text),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('User not logged in');

      String? registrationDocumentUrl = widget.hostel?.registrationDocumentUrl;
      if (_registrationDoc != null) {
        setState(() => _isUploadingDoc = true);
        final storageService = ref.read(storageServiceProvider);
        registrationDocumentUrl = await storageService.uploadHostelRegistrationDoc(
          user.userId,
          _registrationDoc!,
        );
        setState(() => _isUploadingDoc = false);
      }

      final repository = ref.read(hostelRepositoryProvider);
      
      if (widget.hostel != null) {
        // Update existing hostel
        final updatedHostel = widget.hostel!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _selectedCity!,
          area: _areaController.text.trim(),
          province: _selectedProvince!,
          coordinates: _selectedLocation!,
          registrationNumber: _regNumberController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          email: _emailController.text.trim(),
          genderType: _selectedGender,
          minRent: double.parse(_minRentController.text),
          maxRent: double.parse(_maxRentController.text),
          facilities: _facilities,
          rules: _rules,
          description: _descriptionController.text.trim(),
          totalRooms: int.tryParse(_totalRoomsController.text),
          totalBeds: _roomCategories.map((rc) => rc.totalBeds).fold<int>(0, (prev, element) => prev + element),
          roomCategories: _roomCategories,
          registrationDocumentUrl: registrationDocumentUrl,
        );
        
        await repository.updateHostelFull(updatedHostel);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hostel updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new hostel
        final hostel = HostelModel(
          hostelId: '', // Will be assigned by Firestore
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _selectedCity!,
          area: _areaController.text.trim(),
          province: user.province,
          coordinates: _selectedLocation!,
          registrationNumber: _regNumberController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          email: _emailController.text.trim(),
          genderType: _selectedGender,
          minRent: double.parse(_minRentController.text),
          maxRent: double.parse(_maxRentController.text),
          facilities: _facilities,
          rules: _rules,
          imageUrls: [], // TODO: Add image upload
          nearbyUniversities: [], // Can be added later
          approved: true, // Auto-approve as per requirement
          adminId: user.userId,
          createdAt: DateTime.now(),
          description: _descriptionController.text.trim(),
          totalRooms: int.tryParse(_totalRoomsController.text),
          totalBeds: _roomCategories.map((rc) => rc.totalBeds).fold<int>(0, (prev, element) => prev + element),
          occupiedBeds: 0,
          roomCategories: _roomCategories,
          verificationStatus: VerificationStatus.pending,
          registrationDocumentUrl: registrationDocumentUrl,
        );

        await repository.createHostel(hostel);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hostel created successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.hostel != null ? 'Edit Hostel' : 'Add New Hostel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepCircle(0, 'Basics'),
              _buildStepLine(0),
              _buildStepCircle(1, 'Location'),
              _buildStepLine(1),
              _buildStepCircle(2, 'Management'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Center(
              child: isActive && _currentStep > step
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : Text(
                    (step + 1).toString(),
                    style: GoogleFonts.poppins(
                      color: isActive ? AppColors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: _currentStep > step ? AppColors.primary : AppColors.border,
    );
  }

  Widget _buildStep1() {
    return FadeInRight(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tell us about your hostel'),
            CustomTextField(
              label: 'Hostel Name',
              controller: _nameController,
              prefixIcon: Icons.business,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Registration Number',
              controller: _regNumberController,
              prefixIcon: Icons.app_registration,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DocumentUploadWidget(
              label: 'Registration Document (for verification)',
              onFileSelected: (file) => setState(() => _registrationDoc = file),
              initialImageUrl: widget.hostel?.registrationDocumentUrl,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Details'),
            CustomTextField(
              label: 'Contact Number',
              controller: _contactNumberController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
              hint: 'Describe your hostel facilities and unique features...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return FadeInRight(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Where is it located?'),
            CustomTextField(
              label: 'Full Address',
              controller: _addressController,
              prefixIcon: Icons.location_on,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ProvinceCitySelector(
              initialProvince: _selectedProvince,
              initialCity: _selectedCity,
              onSelectionChanged: (province, city) {
                setState(() {
                  _selectedProvince = province;
                  _selectedCity = city;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Area / Locality',
              controller: _areaController,
              prefixIcon: Icons.map,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Pin on Map'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  if (_selectedLocation != null) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Location pinned successfully',
                          style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(_selectedLocation == null ? 'Open Map Picker' : 'Update Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildStep3() {
    return FadeInRight(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Capacity & Policies'),
            DropdownButtonFormField<GenderType>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender Allowed',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.people_outline, color: AppColors.primary),
              ),
              items: GenderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Facilities & Rules'),
            _buildTagInput(
              label: 'Add Facility',
              controller: _facilitiesController,
              tags: _facilities,
              onAdd: _addFacility,
              onRemove: (f) => setState(() => _facilities.remove(f)),
              icon: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 16),
            _buildTagInput(
              label: 'Add Rule',
              controller: _rulesController,
              tags: _rules,
              onAdd: _addRule,
              onRemove: (r) => setState(() => _rules.remove(r)),
              icon: Icons.gavel_outlined,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Room Categories'),
            if (_roomCategories.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Text(
                    'No room categories added yet.\nPlease add at least one (e.g. 2-seater).',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ..._roomCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final rc = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  title: Text('${rc.seaterType}-Seater', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text('Rent: PKR ${rc.rent.toInt()} | Beds: ${rc.totalBeds}', style: GoogleFonts.inter(fontSize: 12)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => setState(() => _roomCategories.removeAt(index)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Seater Category'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTagInput({
    required String label,
    required TextEditingController controller,
    required List<String> tags,
    required VoidCallback onAdd,
    required Function(String) onRemove,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: label,
                controller: controller,
                prefixIcon: icon,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.white),
                onPressed: onAdd,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Chip(
            label: Text(tag, style: GoogleFonts.inter(fontSize: 12)),
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => onRemove(tag),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Text('Back', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep == 2 
                ? (widget.hostel != null ? 'Update Hostel' : 'Launch Hostel')
                : 'Continue',
              onPressed: _isLoading ? null : _nextStep,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}