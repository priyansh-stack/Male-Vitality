import 'package:flutter/material.dart';
import '../../../core/models/mental_wellness/therapist.dart';
import '../../../core/models/mental_wellness/search_criteria.dart';
import '../../../core/theme/app_theme.dart';

class TherapistSearchFilter extends StatefulWidget {
  final Function(SearchCriteria) onApplyFilters;

  const TherapistSearchFilter({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<TherapistSearchFilter> createState() => _TherapistSearchFilterState();
}

class _TherapistSearchFilterState extends State<TherapistSearchFilter> {
  final List<TherapistSpecialty> _selectedSpecialties = [];
  final List<TherapyModality> _selectedModalities = [];
  final List<String> _selectedInsurances = [];
  bool _acceptsNewPatients = true;
  double? _minRating;

  final List<String> _insuranceOptions = [
    'Aetna',
    'Blue Cross',
    'Cigna',
    'Medicare',
    'Optum',
    'UnitedHealthcare',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Therapists',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSpecialtyFilter(),
          const SizedBox(height: 16),
          _buildModalityFilter(),
          const SizedBox(height: 16),
          _buildInsuranceFilter(),
          const SizedBox(height: 16),
          _buildOptionsRow(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSpecialties.clear();
                      _selectedModalities.clear();
                      _selectedInsurances.clear();
                      _acceptsNewPatients = true;
                      _minRating = null;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final criteria = SearchCriteria(
                      specialties: List.from(_selectedSpecialties),
                      modalities: List.from(_selectedModalities),
                      acceptedInsurances: List.from(_selectedInsurances),
                      acceptsNewPatients: _acceptsNewPatients,
                      minRating: _minRating,
                    );
                    widget.onApplyFilters(criteria);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialties',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TherapistSpecialty.values.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(specialty.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialties.add(specialty);
                  } else {
                    _selectedSpecialties.remove(specialty);
                  }
                });
              },
              selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModalityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modalities',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TherapyModality.values.map((modality) {
            final isSelected = _selectedModalities.contains(modality);
            return FilterChip(
              label: Text(modality.toString().split('.').last),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedModalities.add(modality);
                  } else {
                    _selectedModalities.remove(modality);
                  }
                });
              },
              selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInsuranceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insurance Accepted',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _insuranceOptions.map((insurance) {
            final isSelected = _selectedInsurances.contains(insurance);
            return FilterChip(
              label: Text(insurance),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInsurances.add(insurance);
                  } else {
                    _selectedInsurances.remove(insurance);
                  }
                });
              },
              selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text('Accepts New Patients'),
              const SizedBox(width: 8),
              Switch(
                value: _acceptsNewPatients,
                onChanged: (value) {
                  setState(() => _acceptsNewPatients = value);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              const Text('Min Rating:'),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: _minRating,
                hint: const Text('Any'),
                onChanged: (value) {
                  setState(() => _minRating = value);
                },
                items: [
                  const DropdownMenuItem<double>(value: null, child: Text('Any')),
                  const DropdownMenuItem<double>(value: 4.0, child: Text('4.0+')),
                  const DropdownMenuItem<double>(value: 4.5, child: Text('4.5+')),
                  const DropdownMenuItem<double>(value: 4.8, child: Text('4.8+')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}