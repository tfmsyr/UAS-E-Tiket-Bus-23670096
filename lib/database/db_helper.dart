import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bus_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tfmsyr_trans_v5.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Users 
    await db.execute('''
    CREATE TABLE users (
      username TEXT PRIMARY KEY,
      password TEXT,
      role TEXT
    )
    ''');

    // 2. Tabel Bus
    await db.execute('''
    CREATE TABLE buses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_bus TEXT,
      rute TEXT,
      harga REAL,          -- Pakai REAL untuk menyimpan Double (Desimal)
      deskripsi TEXT,
      fasilitas TEXT,
      jumlah_kursi INTEGER,
      titik_jemput TEXT,
      foto_url TEXT,       -- Menyimpan Path File Gambar dari HP
      jam_berangkat TEXT   -- Kolom Baru untuk Jam
    )
    ''');

    // 3. Tabel Booking
    await db.execute('''
    CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_bus TEXT,
      rute TEXT,
      harga INTEGER,
      nama_penumpang TEXT,
      nomor_wa TEXT,
      tanggal_booking TEXT,
      tanggal_berangkat TEXT,
      lokasi_jemput TEXT,
      nomor_kursi TEXT,
      status TEXT
    )
    ''');

    // Insert Akun 
    await db.insert('users', {'username': 'admin', 'password': '123', 'role': 'admin'});
    await db.insert('users', {'username': 'Edi', 'password': '123', 'role': 'user'});
    await db.insert('users', {'username': 'Agung', 'password': '123', 'role': 'user'});
  }

  //  CRUD  BUS
  Future<int> createBus(Bus bus) async {
    final db = await instance.database;
    return await db.insert('buses', bus.toMap());
  }

  Future<List<Bus>> readAllBuses() async {
    final db = await instance.database;
    final result = await db.query('buses');
    return result.map((json) => Bus.fromMap(json)).toList();
  }

  Future<int> updateBus(Bus bus) async {
    final db = await instance.database;
    return db.update(
      'buses', 
      bus.toMap(), 
      where: 'id = ?', 
      whereArgs: [bus.id]
    );
  }

  Future<int> deleteBus(int id) async {
    final db = await instance.database;
    return await db.delete(
      'buses', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  //  AUTH 
  Future<Map<String, dynamic>?> login(String user, String pass) async {
    final db = await instance.database;
    final res = await db.query(
      'users', 
      where: 'username = ? AND password = ?', 
      whereArgs: [user, pass]
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  //  BOOKING 
  Future<int> createBooking(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('bookings', row);
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await instance.database;
    return await db.query('bookings', orderBy: "id DESC");
  }
}