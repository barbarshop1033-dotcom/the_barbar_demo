import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final bool showActions;
  final bool isSelected;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onToggle,
    this.showActions = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: BarberTheme.accentColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      BarberTheme.accentColor.withOpacity(0.1),
                      BarberTheme.accentColor.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: service.isActive
                      ? BarberTheme.accentColor.withOpacity(0.1)
                      : BarberTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(service.name),
                  color: service.isActive
                      ? BarberTheme.accentColor
                      : BarberTheme.textSecondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: GoogleFonts.poppins(
                              color: service.isActive
                                  ? BarberTheme.textPrimary
                                  : BarberTheme.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: service.isActive
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        if (service.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BarberTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CUSTOM',
                              style: GoogleFonts.poppins(
                                color: BarberTheme.accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Price
                        Text(
                          'Rs ${currencyFormat.format(service.price)}',
                          style: GoogleFonts.poppins(
                            color: BarberTheme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Duration
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: BarberTheme.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: BarberTheme.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.duration} min',
                                style: GoogleFonts.poppins(
                                  color: BarberTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (service.category != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BarberTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.category!,
                              style: GoogleFonts.poppins(
                                color: BarberTheme.accentColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              if (showActions)
                Column(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: BarberTheme.accentColor,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(height: 8),
                    if (onToggle != null)
                      Switch(
                        value: service.isActive,
                        onChanged: (_) => onToggle?.call(),
                        activeColor: BarberTheme.accentColor,
                        activeTrackColor:
                            BarberTheme.accentColor.withOpacity(0.3),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('haircut') || lowerName.contains('cut')) {
      return Icons.content_cut_rounded;
    } else if (lowerName.contains('beard') || lowerName.contains('trim')) {
      return Icons.face_rounded;
    } else if (lowerName.contains('facial') || lowerName.contains('face')) {
      return Icons.face_retouching_natural_rounded;
    } else if (lowerName.contains('color') || lowerName.contains('dye')) {
      return Icons.colorize_rounded;
    } else if (lowerName.contains('massage')) {
      return Icons.spa_rounded;
    } else if (lowerName.contains('wash')) {
      return Icons.shower_rounded;
    } else {
      return Icons.style_rounded;
    }
  }
}
