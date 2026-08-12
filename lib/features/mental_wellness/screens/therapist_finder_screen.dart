import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/mental_wellness/therapist_finder_bloc/therapist_finder_bloc.dart';
import '../../../core/models/mental_wellness/therapist.dart';
import '../../../core/models/mental_wellness/search_criteria.dart';
import '../../../core/models/mental_wellness/booking_request.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/therapist_search_filter.dart';
import '../widgets/therapist_card.dart';

class TherapistFinderScreen extends StatefulWidget {
  final String userId;

  const TherapistFinderScreen({super.key, required this.userId});

  @override
  State<TherapistFinderScreen> createState() => _TherapistFinderScreenState();
}

class _TherapistFinderScreenState extends State<TherapistFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  SearchCriteria _criteria = const SearchCriteria();

  @override
  void initState() {
    super.initState();
    _loadTherapists();
    _loadTeletherapyProviders();
  }

  void _loadTherapists() {
    context.read<TherapistFinderBloc>().add(
      SearchTherapistsEvent(criteria: _criteria),
    );
  }

  void _loadTeletherapyProviders() {
    context.read<TherapistFinderBloc>().add(
      LoadTeletherapyProvidersEvent(),
    );
  }

  void _goBack() {
    context.go('/wellness?userId=${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Find a Therapist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters)
            TherapistSearchFilter(
              onApplyFilters: (criteria) {
                setState(() {
                  _criteria = criteria;
                  _loadTherapists();
                });
              },
            ),
          Expanded(
            child: BlocBuilder<TherapistFinderBloc, TherapistFinderState>(
              builder: (context, state) {
                if (state is TherapistSearchingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TherapistErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTherapists,
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _goBack,
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TherapistListLoadedState) {
                  if (state.therapists.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.therapists.length,
                    itemBuilder: (context, index) {
                      final therapist = state.therapists[index];
                      return TherapistCard(
                        therapist: therapist,
                        onTap: () {
                          _showTherapistDetails(context, therapist);
                        },
                        onBook: () {
                          _showBookingDialog(context, therapist);
                        },
                      );
                    },
                  );
                }

                if (state is TeletherapyProvidersLoadedState) {
                  return _buildTeletherapySection(state);
                }

                return const Center(
                  child: Text('Search for therapists or explore telehealth options'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, specialty, or location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (value) {
                setState(() {
                  _criteria = _criteria.copyWith(query: value);
                  _loadTherapists();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              final query = _searchController.text;
              setState(() {
                _criteria = _criteria.copyWith(query: query);
                _loadTherapists();
              });
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No therapists found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search filters',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _criteria = const SearchCriteria();
                    _searchController.clear();
                    _loadTherapists();
                  });
                },
                child: const Text('Clear Filters'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<TherapistFinderBloc>().add(
                    LoadTeletherapyProvidersEvent(),
                  );
                },
                child: const Text('Try Telehealth'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeletherapySection(TeletherapyProvidersLoadedState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Telehealth Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with licensed therapists online',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ...state.providers.map((provider) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                provider.name.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (provider.rating != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      Text(
                                        provider.rating!.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        ' rating',
                                        style: TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: provider.acceptsInsurance
                                  ? AppTheme.healthyGreen.withOpacity(0.1)
                                  : AppTheme.warningOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              provider.acceptsInsurance
                                  ? 'Accepts Insurance'
                                  : 'Self-Pay',
                              style: TextStyle(
                                fontSize: 10,
                                color: provider.acceptsInsurance
                                    ? AppTheme.healthyGreen
                                    : AppTheme.warningOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(provider.description),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.specialties.map((specialty) {
                          return Chip(
                            label: Text(
                              specialty,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      if (provider.pricingInfo != null)
                        Text(
                          '💰 ${provider.pricingInfo}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      if (provider.promoCode != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_offer,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${provider.promoDescription}: ${provider.promoCode}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Visit provider website
                              },
                              child: const Text('Learn More'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (provider.deepLinkUrl.isNotEmpty) {
                                  // Launch URL
                                }
                              },
                              child: const Text('Get Started'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showTherapistDetails(BuildContext context, Therapist therapist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          therapist.name.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              therapist.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              therapist.credentials,
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                              ),
                            ),
                            if (therapist.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  Text(
                                    therapist.rating!.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' (${therapist.reviewCount} reviews)',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (therapist.bio != null)
                    Text(
                      therapist.bio!,
                      style: const TextStyle(height: 1.5),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Specialties',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: therapist.specialties.map((specialty) {
                      return Chip(label: Text(specialty.displayName));
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Modalities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: therapist.modalities.map((modality) {
                      return Chip(
                        label: Text(modality.toString().split('.').last),
                        backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Insurance Accepted',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: therapist.acceptedInsurances.map((insurance) {
                      return Chip(label: Text(insurance));
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showBookingDialog(context, therapist);
                          },
                          child: const Text('Book Session'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, Therapist therapist) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedTime = '9:00 AM';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Book Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Therapist: ${therapist.name}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    items: ['9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM']
                        .map((time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedTime = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Session Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('In-Person'),
                          selected: !_criteria.onlyTeletherapy!,
                          onSelected: (selected) {
                            setState(() {
                              _criteria = _criteria.copyWith(
                                onlyTeletherapy: !selected,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Video'),
                          selected: _criteria.onlyTeletherapy ?? false,
                          onSelected: (selected) {
                            setState(() {
                              _criteria = _criteria.copyWith(
                                onlyTeletherapy: selected,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final bookingRequest = BookingRequest(
                      therapistId: therapist.id,
                      userId: widget.userId,
                      requestedDate: selectedDate,
                      requestedTime: DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        int.parse(selectedTime.split(':')[0]),
                        selectedTime.contains('PM') ? 0 : 0,
                      ),
                      isTeletherapy: _criteria.onlyTeletherapy ?? false,
                    );

                    context.read<TherapistFinderBloc>().add(
                      BookTherapySessionEvent(bookingRequest: bookingRequest),
                    );
                    Navigator.pop(context);
                    _showBookingConfirmation(context);
                  },
                  child: const Text('Confirm Booking'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Booking Requested'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your session request has been sent to the therapist.'),
              SizedBox(height: 12),
              Text(
                'You will receive a confirmation once they accept.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}