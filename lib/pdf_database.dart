import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'pdf_model.dart';

class PdfDatabase {
  static final PdfDatabase instance = PdfDatabase._init();

  static Database? _database;

  PdfDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('pdfs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE pdfs (
  ${PdfFields.id} $idType,
  ${PdfFields.name} $textType,
  ${PdfFields.path} $textType
  )
''');
  }

  Future<PdfModel> create(PdfModel pdf) async {
    final db = await instance.database;

    final id = await db.insert('pdfs', pdf.toMap());
    return pdf.copyWith(id: id);
  }

  Future<PdfModel> readPdf(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'pdfs',
      columns: PdfFields.values,
      where: '${PdfFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PdfModel.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<PdfModel>> readAllPdfs() async {
    final db = await instance.database;

    const orderBy = '${PdfFields.name} ASC';
    final result = await db.query('pdfs', orderBy: orderBy);

    return result.map((json) => PdfModel.fromMap(json)).toList();
  }

  Future<int> update(PdfModel pdf) async {
    final db = await instance.database;

    return db.update(
      'pdfs',
      pdf.toMap(),
      where: '${PdfFields.id} = ?',
      whereArgs: [pdf.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'pdfs',
      where: '${PdfFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}