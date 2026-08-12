import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/bloc/mental_wellness/crisis_resource_bloc/crisis_resource_bloc.dart';
import '../../../core/models/mental_wellness/crisis_resource.dart';
import '../../../core/models/mental_wellness/emergency_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/crisis_quick_access_button.dart';

class CrisisResourceAccessScreen extends StatefulWidget {
  final String userId;

  const CrisisResourceAccessScreen({super.key, required this.userId});

  @override
  State<CrisisResourceAccessScreen> createState() => _CrisisResourceAccessScreenState();
}

class _CrisisResourceAccessScreenState extends State<CrisisResourceAccessScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CrisisResourceBloc>().add(
      const LoadCrisisResourcesEvent(),
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
        title: const Text('Crisis Resources'),
        backgroundColor: Colors.red.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: BlocBuilder<CrisisResourceBloc, CrisisResourceState>(
        builder: (context, state) {
          if (state is CrisisLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CrisisErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CrisisResourceBloc>().add(
                        const LoadCrisisResourcesEvent(),
                      );
                    },
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

          if (state is CrisisResourcesLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyAlertBanner(context),
                  const SizedBox(height: 24),
                  _buildQuickAccessSection(),
                  const SizedBox(height: 24),
                  _buildHotlinesSection(state.nationalResources),
                  const SizedBox(height: 24),
                  _buildLocalResourcesSection(state.localResources),
                  const SizedBox(height: 24),
                  _buildEmergencyServicesSection(state.emergencyServices),
                  const SizedBox(height: 24),
                  _buildSafetyPlanSection(),
                ],
              ),
            );
          }

          return const Center(child: Text('No crisis resources available'));
        },
      ),
    );
  }

  Widget _buildEmergencyAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Immediate Help Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'If you are in crisis and need immediate support, please reach out to one of the resources below.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CrisisResourceBloc>().add(
                      const CallCrisisLifelineEvent(phoneNumber: '988'),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 20),
                      SizedBox(width: 8),
                      Text('Call 988', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CrisisResourceBloc>().add(
                      const SendCrisisTextEvent(textNumber: '741741'),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms, size: 20),
                      SizedBox(width: 8),
                      Text('Text 741741', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showEmergencyProtocol(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Emergency Protocol'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CrisisQuickAccessButton(
                title: '988 Lifeline',
                subtitle: 'Call Now',
                icon: Icons.phone,
                color: Colors.red,
                onTap: () {
                  context.read<CrisisResourceBloc>().add(
                    const CallCrisisLifelineEvent(phoneNumber: '988'),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CrisisQuickAccessButton(
                title: 'Crisis Text',
                subtitle: 'Text HOME',
                icon: Icons.sms,
                color: Colors.blue,
                onTap: () {
                  context.read<CrisisResourceBloc>().add(
                    const SendCrisisTextEvent(textNumber: '741741'),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CrisisQuickAccessButton(
                title: 'SAMHSA',
                subtitle: '1-800-662-4357',
                icon: Icons.help,
                color: Colors.purple,
                onTap: () {
                  context.read<CrisisResourceBloc>().add(
                    const CallCrisisLifelineEvent(phoneNumber: '1-800-662-4357'),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CrisisQuickAccessButton(
                title: '911',
                subtitle: 'Emergency',
                icon: Icons.emergency,
                color: Colors.orange,
                onTap: () {
                  context.read<CrisisResourceBloc>().add(
                    const CallCrisisLifelineEvent(phoneNumber: '911'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHotlinesSection(List<CrisisResource> resources) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'National Hotlines',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...resources.map((resource) => _buildResourceCard(resource)),
      ],
    );
  }

  Widget _buildLocalResourcesSection(List<CrisisResource> resources) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Local Resources',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...resources.map((resource) => _buildResourceCard(resource)),
      ],
    );
  }

  Widget _buildResourceCard(CrisisResource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getResourceColor(resource.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getResourceIcon(resource.type),
                    color: _getResourceColor(resource.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (resource.isNational)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'National',
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),
                if (resource.is24Hours)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.healthyGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '24/7',
                      style: TextStyle(fontSize: 10, color: AppTheme.healthyGreen),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              resource.description,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (resource.phoneNumber != null)
                  _buildActionChip(
                    icon: Icons.phone,
                    label: resource.phoneNumber!,
                    onTap: () {
                      context.read<CrisisResourceBloc>().add(
                        CallCrisisLifelineEvent(
                          phoneNumber: resource.phoneNumber!,
                        ),
                      );
                    },
                  ),
                if (resource.textNumber != null)
                  _buildActionChip(
                    icon: Icons.sms,
                    label: 'Text ${resource.textNumber}',
                    onTap: () {
                      context.read<CrisisResourceBloc>().add(
                        SendCrisisTextEvent(
                          textNumber: resource.textNumber!,
                        ),
                      );
                    },
                  ),
                if (resource.website != null)
                  _buildActionChip(
                    icon: Icons.language,
                    label: 'Website',
                    onTap: () async {
                      final url = resource.website!;
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                  ),
                if (resource.chatUrl != null)
                  _buildActionChip(
                    icon: Icons.chat,
                    label: 'Chat',
                    onTap: () async {
                      final url = resource.chatUrl!;
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.surfaceSubtle,
    );
  }

  Widget _buildEmergencyServicesSection(List<EmergencyService> services) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Local Emergency Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...services.map((service) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red),
                title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.address != null) Text(service.address!),
                    if (service.is24Hours)
                      const Text('Open 24/7', style: TextStyle(color: Colors.green)),
                    if (service.services.isNotEmpty)
                      Text(
                        service.services.join(', '),
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue),
                  onPressed: () {
                    context.read<CrisisResourceBloc>().add(
                      CallCrisisLifelineEvent(
                        phoneNumber: service.phoneNumber,
                      ),
                    );
                  },
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSafetyPlanSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Safety Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A safety plan helps you identify warning signs and coping strategies during crisis moments.',
              style: TextStyle(color: AppTheme.textMedium),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SafetyPlanItem(
                    icon: Icons.warning,
                    text: 'Identify warning signs',
                  ),
                  _SafetyPlanItem(
                    icon: Icons.people,
                    text: 'Support contacts',
                  ),
                  _SafetyPlanItem(
                    icon: Icons.settings,
                    text: 'Coping strategies',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to safety plan
                },
                child: const Text('View My Safety Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyProtocol(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Emergency Protocol'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('If you are in immediate danger:'),
              SizedBox(height: 12),
              Text('1. Call 988 or 911 immediately'),
              Text('2. Contact your emergency contact'),
              Text('3. Go to the nearest emergency room'),
              SizedBox(height: 12),
              Text(
                'Resources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 988 Suicide & Crisis Lifeline'),
              Text('• Crisis Text Line: 741741'),
              Text('• SAMHSA: 1-800-662-4357'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand'),
            ),
          ],
        );
      },
    );
  }

  Color _getResourceColor(CrisisResourceType type) {
    switch (type) {
      case CrisisResourceType.nationalHotline:
        return Colors.blue;
      case CrisisResourceType.localHotline:
        return Colors.green;
      case CrisisResourceType.emergencyService:
        return Colors.red;
      case CrisisResourceType.crisisCenter:
        return Colors.purple;
      case CrisisResourceType.warmLine:
        return Colors.orange;
      case CrisisResourceType.textLine:
        return Colors.teal;
      case CrisisResourceType.onlineChat:
        return Colors.indigo;
    }
  }

  IconData _getResourceIcon(CrisisResourceType type) {
    switch (type) {
      case CrisisResourceType.nationalHotline:
        return Icons.phone;
      case CrisisResourceType.localHotline:
        return Icons.phone_in_talk;
      case CrisisResourceType.emergencyService:
        return Icons.emergency;
      case CrisisResourceType.crisisCenter:
        return Icons.location_city;
      case CrisisResourceType.warmLine:
        return Icons.record_voice_over;
      case CrisisResourceType.textLine:
        return Icons.sms;
      case CrisisResourceType.onlineChat:
        return Icons.chat;
    }
  }
}

class _SafetyPlanItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SafetyPlanItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryTeal),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}