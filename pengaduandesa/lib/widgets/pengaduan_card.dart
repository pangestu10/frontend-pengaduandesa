// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/pengaduan_model.dart';
import '../../theme/app_theme.dart';

class PengaduanCard extends StatelessWidget {
  final Pengaduan pengaduan;
  final VoidCallback? onTap;

  const PengaduanCard({
    super.key,
    required this.pengaduan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.white20, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan judul dan status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengaduan.judul,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(pengaduan.tanggalDiajukan),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: pengaduan.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pengaduan.statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pengaduan.statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: pengaduan.statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Deskripsi singkat
              Text(
                pengaduan.deskripsi,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.white80,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer dengan kategori dan lokasi
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.white30,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(pengaduan.kategori),
                          size: 14,
                          color: AppTheme.white60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pengaduan.kategoriText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (pengaduan.lokasi != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.white30,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pengaduan.lokasi!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.white60,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppTheme.white40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks minggu lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'infrastruktur':
        return Icons.construction;
      case 'sosial':
        return Icons.people;
      case 'ekonomi':
        return Icons.attach_money;
      case 'lingkungan':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }
}