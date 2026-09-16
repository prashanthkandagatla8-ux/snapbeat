import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';

class TesterFeedbackDialog extends StatefulWidget {
  const TesterFeedbackDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => const TesterFeedbackDialog(),
    );
  }

  @override
  State<TesterFeedbackDialog> createState() => _TesterFeedbackDialogState();
}

class _TesterFeedbackDialogState extends State<TesterFeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _copied = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: "snapbeat-testers@googlegroups.com"));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _sendFeedback() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please type your feedback or bug report first!"),
          backgroundColor: AppColors.redSurface,
        ),
      );
      return;
    }

    final shareText = "SnapBeat Beta Feedback:\n\n$text\n\nSent to: snapbeat-testers@googlegroups.com";
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: "SnapBeat Beta Feedback",
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBrass, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.canvasChassis,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(
                  bottom: BorderSide(color: AppColors.chassisBevelLight, width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.brassGold,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brassDark),
                    ),
                    child: const Icon(Icons.rate_review_rounded, color: AppColors.textEngraved, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TESTER FEEDBACK",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.textEngraved,
                          ),
                        ),
                        Text(
                          Platform.isIOS ? "Apple TestFlight Beta Channel" : "Google Play Closed Beta Channel",
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Content Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panelCreamDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.chassisBevelLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, color: AppColors.amberJewel, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "SnapBeat Beta Testers Community",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textEngraved,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Your feedback directly shapes our release builds and server queue speed.",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "SHARE YOUR THOUGHTS OR REPORT A BUG:",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textEngraved,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderBrass),
                      ),
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textEngraved,
                        ),
                        decoration: const InputDecoration(
                          hintText: "What did you like? Any bugs or feature ideas?",
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Send Feedback Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brassGold,
                          foregroundColor: AppColors.textEngraved,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.brassDark, width: 1.2),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text(
                          "SEND TESTER FEEDBACK",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        onPressed: _sendFeedback,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.chassisBevelLight, height: 1),
                    const SizedBox(height: 14),

                    // Tester Group Email Copy Button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "TESTER FEEDBACK EMAIL",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "snapbeat-testers@googlegroups.com",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textEngraved,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: _copied ? const Color(0xFFE8F5E9) : AppColors.panelCreamDark,
                            foregroundColor: _copied ? Colors.green.shade800 : AppColors.textEngraved,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: Icon(_copied ? Icons.check : Icons.copy, size: 14),
                          label: Text(
                            _copied ? "COPIED" : "COPY",
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: _copyEmail,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
