import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/pakistan_location_config.dart';


class ProvinceCitySelector extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;
  final Function(String? province, String? city) onSelectionChanged;
  final bool enabled;

  const ProvinceCitySelector({
    super.key,
    this.initialProvince,
    this.initialCity,
    required this.onSelectionChanged,
    this.enabled = true,
  });

  @override
  State<ProvinceCitySelector> createState() => _ProvinceCitySelectorState();
}

class _ProvinceCitySelectorState extends State<ProvinceCitySelector> {
  String? _selectedProvinceCode;
  String? _selectedCity;
  List<String> _availableCities = [];

  @override
  void initState() {
    super.initState();
    _selectedProvinceCode = widget.initialProvince;
    _selectedCity = widget.initialCity;
    
    if (_selectedProvinceCode != null) {
      _availableCities = PakistanLocationConfig.getCitiesByProvinceCode(_selectedProvinceCode!);
    }
  }

  void _onProvinceChanged(String? provinceCode) {
    setState(() {
      _selectedProvinceCode = provinceCode;
      _selectedCity = null; // Reset city when province changes
      _availableCities = provinceCode != null
          ? PakistanLocationConfig.getCitiesByProvinceCode(provinceCode)
          : [];
    });
    widget.onSelectionChanged(_selectedProvinceCode, null);
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
    });
    widget.onSelectionChanged(_selectedProvinceCode, _selectedCity);
  }

  Future<void> _showCitySearchDialog() async {
    if (_availableCities.isEmpty) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CitySearchDialog(
        cities: _availableCities,
        selectedCity: _selectedCity,
      ),
    );

    if (result != null) {
      _onCityChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Province Dropdown
        DropdownButtonFormField<String>(
          value: _selectedProvinceCode,
          decoration: InputDecoration(
            labelText: 'Province',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.location_on),
            enabled: widget.enabled,
          ),
          items: PakistanLocationConfig.provinces.map((province) {
            return DropdownMenuItem(
              value: province.code,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: widget.enabled ? _onProvinceChanged : null,
          validator: (value) => value == null ? 'Please select a province' : null,
        ),
        const SizedBox(height: 16),
        
        // Searchable City Field
        GestureDetector(
          onTap: widget.enabled && _availableCities.isNotEmpty ? _showCitySearchDialog : null,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'City',
                hintText: _availableCities.isEmpty 
                    ? 'Select province first' 
                    : 'Tap to search cities',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_city),
                suffixIcon: Icon(
                  Icons.search,
                  color: _availableCities.isEmpty ? Colors.grey : AppColors.primary,
                ),
                enabled: widget.enabled && _availableCities.isNotEmpty,
              ),
              controller: TextEditingController(text: _selectedCity ?? ''),
              validator: (value) => value == null || value.isEmpty ? 'Please select a city' : null,
            ),
          ),
        ),
        if (_selectedCity != null && _availableCities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              '${_availableCities.length} cities available in this province',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

// Searchable City Dialog
class _CitySearchDialog extends StatefulWidget {
  final List<String> cities;
  final String? selectedCity;

  const _CitySearchDialog({
    required this.cities,
    this.selectedCity,
  });

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select City',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${widget.cities.length} cities available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search city name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            
            // City List
            Flexible(
              child: _filteredCities.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cities found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredCities.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        final isSelected = city == widget.selectedCity;
                        
                        return ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          title: Text(
                            city,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: AppColors.primary)
                              : null,
                          selected: isSelected,
                          onTap: () => Navigator.pop(context, city),
                        );
                      },
                    ),
            ),
            
            // Footer Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Showing ${_filteredCities.length} of ${widget.cities.length} cities',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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
}