import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:petwise/data/models/vaccination_model.dart';
import 'package:petwise/providers/vaccination_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/presentation/widgets/petwise_add_edit_vaccination_sheet.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final petId = context.read<PetProvider>().selectedPet?.id;
      if (petId != null) {
        context.read<VaccinationProvider>().loadVaccinationsForPet(petId);
      }
    });
  }

  void _openSheet({VaccinationModel? existing}) {
    final petId = context.read<PetProvider>().selectedPet?.id;
    if (petId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditVaccinationSheet(petId: petId, existing: existing),
    );
  }

  Future<void> _confirmDelete(VaccinationModel v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Vaccination',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove "${v.vaccineName}" from the records?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<VaccinationProvider>().deleteVaccination(
        v.id,
        v.petId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().selectedPet;
    final provider = context.watch<VaccinationProvider>();
    final vaccinations = pet != null
        ? provider.forPet(pet.id)
        : <VaccinationModel>[];

    // Summary counts
    final valid = vaccinations
        .where((v) => v.status == VaccinationStatus.valid)
        .length;
    final expiringSoon = vaccinations
        .where((v) => v.status == VaccinationStatus.expiringSoon)
        .length;
    final expired = vaccinations
        .where((v) => v.status == VaccinationStatus.expired)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2D40)),
        title: Text(
          '${pet?.name ?? 'Pet'} — Vaccinations',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A2D40),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7A433)),
            )
          : Column(
              children: [
                if (vaccinations.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        _SummaryChip(
                          count: valid,
                          label: 'Valid',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          count: expiringSoon,
                          label: 'Expiring',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          count: expired,
                          label: 'Expired',
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: vaccinations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.vaccines_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No vaccinations recorded',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _openSheet(),
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFFF7A433),
                                ),
                                label: Text(
                                  'Add first vaccination',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF7A433),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vaccinations.length,
                          itemBuilder: (context, i) {
                            final v = vaccinations[i];
                            return _VaccinationCard(
                              vaccination: v,
                              onEdit: () => _openSheet(existing: v),
                              onDelete: () => _confirmDelete(v),
                              onMarkAdministered: v.isCompleted
                                  ? null
                                  : () => context
                                        .read<VaccinationProvider>()
                                        .markAsAdministered(v.id),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: vaccinations.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _openSheet(),
              backgroundColor: const Color(0xFFF7A433),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  final VaccinationModel vaccination;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMarkAdministered;

  const _VaccinationCard({
    required this.vaccination,
    required this.onEdit,
    required this.onDelete,
    this.onMarkAdministered,
  });

  @override
  Widget build(BuildContext context) {
    final v = vaccination;
    final statusColor = _statusColor(v.status);
    final statusLabel = _statusLabel(v.status);
    final fmt = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.vaccines_outlined,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              v.vaccineName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A2D40),
                              ),
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Given',
                        value: fmt.format(v.dateGiven),
                      ),
                      if (v.expiryDate != null) ...[
                        const SizedBox(height: 2),
                        _InfoRow(
                          icon: Icons.event_available_outlined,
                          label: 'Expires',
                          value: fmt.format(v.expiryDate!),
                          valueColor: statusColor,
                        ),
                      ],
                      if (v.status == VaccinationStatus.expiringSoon &&
                          v.daysUntilExpiry != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Expires in ${v.daysUntilExpiry} day${v.daysUntilExpiry == 1 ? '' : 's'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                    if (val == 'mark' && onMarkAdministered != null) {
                      onMarkAdministered!();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.plusJakartaSans()),
                        ],
                      ),
                    ),
                    if (!v.isCompleted)
                      PopupMenuItem(
                        value: 'mark',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mark Administered',
                              style: GoogleFonts.plusJakartaSans(),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (v.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Administered',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(VaccinationStatus s) {
    switch (s) {
      case VaccinationStatus.valid:
        return Colors.green;
      case VaccinationStatus.expiringSoon:
        return Colors.orange;
      case VaccinationStatus.expired:
        return Colors.redAccent;
    }
  }

  String _statusLabel(VaccinationStatus s) {
    switch (s) {
      case VaccinationStatus.valid:
        return 'Valid';
      case VaccinationStatus.expiringSoon:
        return 'Expiring Soon';
      case VaccinationStatus.expired:
        return 'Expired';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: valueColor ?? const Color(0xFF1A2D40),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
