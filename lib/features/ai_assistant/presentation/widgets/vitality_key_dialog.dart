import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/vitality_copilot_cubit.dart';

class VitalityKeyDialog extends StatefulWidget {
  final VitalityCopilotCubit cubit;

  const VitalityKeyDialog({super.key, required this.cubit});

  @override
  State<VitalityKeyDialog> createState() => _VitalityKeyDialogState();
}

class _VitalityKeyDialogState extends State<VitalityKeyDialog> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _keyController.text = data.text!.trim();
        _testResult = null;
      });
    }
  }

  Future<void> _testConnection() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = 'Please paste your Gemini API key first.';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final success = await widget.cubit.testApiKey(key);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = success;
        _testResult = success
            ? 'Success! Gemini 2.5 connection verified.'
            : 'Connection failed. Verify your key from Google AI Studio.';
      });
    }
  }

  Future<void> _openAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkCanvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AppTheme.cyberCyan.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vpn_key_rounded, color: AppTheme.cyberCyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Gemini API Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Enter your Google Gemini API key to activate real-time clinical reasoning, biometric guidance, and longevity coaching with your Gemini Pro plan.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              obscureText: _obscureKey,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: AppTheme.darkCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.cyberCyan),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_paste_rounded, color: AppTheme.cyberCyan, size: 20),
                      tooltip: 'Paste from clipboard',
                      onPressed: _pasteFromClipboard,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _openAiStudio,
                  icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.cyberCyan),
                  label: const Text(
                    'Get API Key from AI Studio',
                    style: TextStyle(color: AppTheme.cyberCyan, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
                TextButton(
                  onPressed: _isTesting ? null : _testConnection,
                  child: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyberCyan),
                        )
                      : const Text(
                          'Test Key',
                          style: TextStyle(color: AppTheme.bioEmerald, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _testSuccess
                      ? const Color(0xFF065F46).withValues(alpha: 0.4)
                      : const Color(0xFF991B1B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    color: _testSuccess ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final key = _keyController.text.trim();
                      if (key.isNotEmpty) {
                        await widget.cubit.saveApiKey(key);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gemini API key saved successfully.'),
                              backgroundColor: AppTheme.bioEmerald,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyberCyan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Save & Connect',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
