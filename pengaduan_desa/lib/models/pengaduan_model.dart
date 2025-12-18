import 'package:flutter/material.dart';

enum PengaduanStatus { diajukan, diproses, ditolak, selesai }
enum PengaduanKategori { infrastruktur, sosial, ekonomi, lingkungan, lainnya }

class Pengaduan {
  int id;
  int userId;
  String judul;
  String deskripsi;
  String kategori;
  String? lokasi;
  String? foto;
  String status;
  String? tindakan;
  int? diatasiOleh;
  String? pelaporNama;
  String? pelaporNik;
  String? pelaporFoto;
  String? ditanganiNama;
  DateTime tanggalDiajukan;
  DateTime? tanggalDitindak;
  DateTime? tanggalSelesai;

  Pengaduan({
    required this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    this.lokasi,
    this.foto,
    required this.status,
    this.tindakan,
    this.diatasiOleh,
    this.pelaporNama,
    this.pelaporNik,
    this.pelaporFoto,
    this.ditanganiNama,
    required this.tanggalDiajukan,
    this.tanggalDitindak,
    this.tanggalSelesai,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) => Pengaduan(
        id: json["id"] as int,
        userId: json["user_id"] as int,
        judul: json["judul"]?.toString() ?? '',
        deskripsi: json["deskripsi"]?.toString() ?? '',
        kategori: json["kategori"]?.toString() ?? 'lainnya',
        lokasi: json["lokasi"]?.toString(),
        foto: json["foto"]?.toString(),
        status: json["status"]?.toString() ?? 'diajukan',
        tindakan: json["tindakan"]?.toString(),
        diatasiOleh: json["diatasi_oleh"] as int?,
        pelaporNama: json["pelapor_nama"]?.toString(),
        pelaporNik: json["pelapor_nik"]?.toString(),
        pelaporFoto: json["pelapor_foto"]?.toString(),
        ditanganiNama: json["ditangani_nama"]?.toString(),
        tanggalDiajukan: json["tanggal_diajukan"] != null
            ? DateTime.parse(json["tanggal_diajukan"].toString())
            : DateTime.now(),
        tanggalDitindak: json["tanggal_ditindak"] == null
            ? null
            : DateTime.parse(json["tanggal_ditindak"].toString()),
        tanggalSelesai: json["tanggal_selesai"] == null
            ? null
            : DateTime.parse(json["tanggal_selesai"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "judul": judul,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "lokasi": lokasi,
        "foto": foto,
        "status": status,
        "tindakan": tindakan,
        "diatasi_oleh": diatasiOleh,
        "pelapor_nama": pelaporNama,
        "pelapor_nik": pelaporNik,
        "pelapor_foto": pelaporFoto,
        "ditangani_nama": ditanganiNama,
        "tanggal_diajukan": tanggalDiajukan.toIso8601String(),
        "tanggal_ditindak": tanggalDitindak?.toIso8601String(),
        "tanggal_selesai": tanggalSelesai?.toIso8601String(),
      };

  String get statusText {
    switch (status) {
      case 'diajukan':
        return 'Diajukan';
      case 'diproses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'diajukan':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'ditolak':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get kategoriText {
    switch (kategori) {
      case 'infrastruktur':
        return 'Infrastruktur';
      case 'sosial':
        return 'Sosial';
      case 'ekonomi':
        return 'Ekonomi';
      case 'lingkungan':
        return 'Lingkungan';
      case 'lainnya':
        return 'Lainnya';
      default:
        return kategori;
    }
  }
}

class PengaduanStats {
  int total;
  int diajukan;
  int diproses;
  int ditolak;
  int selesai;

  PengaduanStats({
    required this.total,
    required this.diajukan,
    required this.diproses,
    required this.ditolak,
    required this.selesai,
  });

  factory PengaduanStats.fromJson(Map<String, dynamic> json) {
    return PengaduanStats(
      total: json['total'] ?? 0,
      diajukan: json['diajukan'] ?? 0,
      diproses: json['diproses'] ?? 0,
      ditolak: json['ditolak'] ?? 0,
      selesai: json['selesai'] ?? 0,
    );
  }
}

class Notifikasi {
  int id;
  int userId;
  int? pengaduanId;
  String judul;
  String pesan;
  bool isRead;
  DateTime createdAt;
  String? pengaduanJudul;

  Notifikasi({
    required this.id,
    required this.userId,
    this.pengaduanId,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
    this.pengaduanJudul,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) => Notifikasi(
        id: json["id"],
        userId: json["user_id"],
        pengaduanId: json["pengaduan_id"],
        judul: json["judul"],
        pesan: json["pesan"],
        isRead: json["is_read"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        pengaduanJudul: json["pengaduan_judul"],
      );
}