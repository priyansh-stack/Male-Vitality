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
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        title: const Text(
          'CRISIS RESOURCES & SENTINEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppTheme.obsidianBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
        ),
      ),
      body: BlocBuilder<CrisisResourceBloc, CrisisResourceState>(
        builder: (context, state) {
          if (state is CrisisLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan));
          }

          if (state is CrisisErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.neonRed),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan, foregroundColor: const Color(0xFF080C14)),
                    onPressed: () {
                      context.read<CrisisResourceBloc>().add(
                        const LoadCrisisResourcesEvent(),
                      );
                    },
                    child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24)),
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

          return const Center(child: Text('No crisis resources available', style: TextStyle(color: Colors.white70)));
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
          'RAPID TRIAGE DISPATCH',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.neonCyan,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CrisisQuickAccessButton(
                title: '988 Lifeline',
                subtitle: 'Direct Voice',
                icon: Icons.phone,
                color: Colors.redAccent,
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
                subtitle: 'SMS HOME',
                icon: Icons.sms,
                color: AppTheme.neonCyan,
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
                icon: Icons.support_agent,
                color: const Color(0xFFA855F7),
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
                title: 'Emergency',
                subtitle: 'Dial 911',
                icon: Icons.emergency,
                color: Colors.orangeAccent,
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
          'NATIONAL 24/7 SUPPORT SERVICES',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
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
          'LOCAL CRISIS CLINICS & WARMLINES',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...resources.map((resource) => _buildResourceCard(resource)),
      ],
    );
  }

  Widget _buildResourceCard(CrisisResource resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getResourceColor(resource.type).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getResourceIcon(resource.type),
                  color: _getResourceColor(resource.type),
                  size: 22,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (resource.isNational)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.neonCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NATIONAL',
                          style: TextStyle(fontSize: 9, color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              if (resource.is24Hours)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '24/7 LIVE',
                    style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            resource.description,
            style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
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
                  color: const Color(0xFF10B981),
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
                  color: AppTheme.neonCyan,
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
                  color: const Color(0xFFA855F7),
                  onTap: () async {
                    final uri = Uri.parse(resource.website!);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              if (resource.chatUrl != null)
                _buildActionChip(
                  icon: Icons.chat,
                  label: 'Chat Room',
                  color: const Color(0xFF38BDF8),
                  onTap: () async {
                    final uri = Uri.parse(resource.chatUrl!);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServicesSection(List<EmergencyService> services) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOCAL EMERGENCY DEPARTMENTS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        ...services.map((service) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.redAccent, size: 20),
                ),
                title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.address != null)
                      Text(service.address!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    if (service.is24Hours)
                      const Text('Open 24/7 Emergency Room', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                    if (service.services.isNotEmpty)
                      Text(
                        service.services.join(', '),
                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Color(0xFF10B981)),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppTheme.neonCyan, size: 20),
              SizedBox(width: 8),
              Text(
                'PERSONAL CRISIS RESILIENCE PLAN',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pre-commit to immediate grounding protocols and trusted anchors before acute psychological distress occurs.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          const Column(
            children: [
              _SafetyPlanItem(
                icon: Icons.warning_amber_rounded,
                text: '1. Recognize Personal Somatic Warning Triggers',
              ),
              SizedBox(height: 8),
              _SafetyPlanItem(
                icon: Icons.self_improvement_rounded,
                text: '2. Execute 4-4-4-4 Autonomic Box Breathing Reset',
              ),
              SizedBox(height: 8),
              _SafetyPlanItem(
                icon: Icons.people_outline_rounded,
                text: '3. Contact Designated Primary Anchor Contact',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.neonCyan,
                side: const BorderSide(color: AppTheme.neonCyan),
              ),
              onPressed: () {
                context.go('/wellness?userId=${widget.userId}');
              },
              child: const Text('Access Mental Wellness Module'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyProtocol(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Emergency Protocol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('If you are in immediate danger or experiencing self-harm urges:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              SizedBox(height: 12),
              Text('1. Call 988 or 911 immediately', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('2. Connect with your emergency contact anchor', style: TextStyle(color: Colors.white)),
              Text('3. Proceed to the nearest emergency department', style: TextStyle(color: Colors.white)),
              SizedBox(height: 14),
              Text(
                'Active Lifelines:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonCyan, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text('• 988 Suicide & Crisis Lifeline (24/7, Free, Confidential)', style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text('• Crisis Text Line: Text HOME to 741741', style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text('• SAMHSA Helpline: 1-800-662-4357', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
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
        return AppTheme.neonCyan;
      case CrisisResourceType.localHotline:
        return const Color(0xFF10B981);
      case CrisisResourceType.emergencyService:
        return Colors.redAccent;
      case CrisisResourceType.crisisCenter:
        return const Color(0xFFA855F7);
      case CrisisResourceType.warmLine:
        return Colors.orangeAccent;
      case CrisisResourceType.textLine:
        return const Color(0xFF38BDF8);
      case CrisisResourceType.onlineChat:
        return const Color(0xFF6366F1);
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
        Icon(icon, size: 18, color: AppTheme.neonCyan),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}