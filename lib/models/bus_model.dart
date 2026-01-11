class Bus {
  final int? id;
  final String namaBus;
  final String rute;
  final double harga; 
  final String deskripsi;
  final String fasilitas;
  final int jumlahKursi;
  final String titikJemput;
  final String? fotoUrl;
  final String jamBerangkat;

  Bus({
    this.id,
    required this.namaBus,
    required this.rute,
    required this.harga,
    required this.deskripsi,
    required this.fasilitas,
    required this.jumlahKursi,
    required this.titikJemput,
    this.fotoUrl,
    required this.jamBerangkat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_bus': namaBus,      
      'rute': rute,
      'harga': harga,
      'deskripsi': deskripsi,
      'fasilitas': fasilitas,
      'jumlah_kursi': jumlahKursi,
      'titik_jemput': titikJemput,
      'foto_url': fotoUrl,      
      'jam_berangkat': jamBerangkat,
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map) {
    return Bus(
      id: map['id'],
      namaBus: map['nama_bus'],
      rute: map['rute'],
      harga: (map['harga'] as num).toDouble(), 
      deskripsi: map['deskripsi'],
      fasilitas: map['fasilitas'],
      jumlahKursi: map['jumlah_kursi'],
      titikJemput: map['titik_jemput'],
      fotoUrl: map['foto_url'],
      jamBerangkat: map['jam_berangkat'] ?? 'Pagi (07:00 WIB)',
    );
  }
}