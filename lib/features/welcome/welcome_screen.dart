import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/life_stage.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      body: Stack(
        children: [
          // Ambient neon glow orbs
          Positioned(
            top: -100,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonCyan.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonEmerald.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Top Brand HUD Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.obsidianCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonCyan.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.hub_rounded, color: AppTheme.neonCyan, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MALE VITALITY HUD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Archetype chips
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: LifeStage.values.map((stage) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.obsidianGlass,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: stage.badgeColor.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: stage.badgeColor.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(stage.icon, color: stage.badgeColor, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${stage.name.toUpperCase()} (${stage.ageRange})',
                                    style: TextStyle(
                                      color: stage.badgeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'CLINICAL LONGEVITY & BIOMETRIC MESH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Continuous adaptive surveillance calibrated to your exact life-stage archetype. Real-time telemetry, pharmacotherapy monitoring, and predictive risk scoring.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Futuristic Telemetry Feature Cards
                        Row(
                          children: [
                            _buildFeatureItem(Icons.security_rounded, 'HIPAA\nENCLAVE', AppTheme.neonCyan),
                            const SizedBox(width: 10),
                            _buildFeatureItem(Icons.sensors_rounded, 'HARDWARE\nBRIDGES', AppTheme.neonEmerald),
                            const SizedBox(width: 10),
                            _buildFeatureItem(Icons.sos_rounded, 'CRISIS\nSENTINEL', AppTheme.neonCrimson),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Call to Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/auth');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonCyan,
                        foregroundColor: AppTheme.obsidianBase,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'INITIALIZE COMMAND ACCESS',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.obsidianCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.obsidianBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}