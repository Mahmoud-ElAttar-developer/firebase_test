import 'dart:async';

import 'package:firebase_test/sevices/curd/crud_exception.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// --------------------------------------------------------------------------------------
//------------------------------ الكود الجديد للتحقق والأمان ------------------------------

// هذا هو الكلاس المسؤول عن تنفيذ العمليات
class NotesServices {
  Database? _db;
  // 1. القائمة المحلية المؤقتة المخزنة في الذاكرة (تكون فارغة في البداية)
  List<DatabaseNote> _notes = [];
   // تهيئة كائن الخدمة المشترك وتجهيز متحكم البث مع ميزة التحديث التلقائي الفوري عند الاستماع
  static final NotesServices _shared = NotesServices._sharedInstance();
  NotesServices._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesServices() => _shared;
  // بفضل هذا التصميم، نضمن بنسبة 100% أن الشاشة وقاعدة البيانات يتحدثان مع نفس 
  //"الصندوق المشترك" في ذاكرة الهاتف، فتظهر التحديثات فوراً.
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
   // جعل متحكم البث متغيراً يتم تهيئته لاحقاً بشكل احترافي لتجنب التكرار في الذاكرة
  late final StreamController<List<DatabaseNote>> _notesStreamController;
  // 1. المحاولة الأولى: جلب المستخدم من قاعدة البيانات باستخدام البريد الإلكتروني
  Future<DatabaseServices> getOrCreateUser({required String email}) async {
    try {
      // 1. المحاولة الأولى: جلب المستخدم من قاعدة البيانات باستخدام البريد الإلكتروني
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      // 2. إذا لم يجد المستخدم (رمى خطأ عدم العثور عليه)، قم بإنشائه فوراً كحساب جديد محلياً
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      // 3. إذا حدث أي خطأ آخر غير متوقع، قم بتمريره وإعادة رميه
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  // دالة التحقق والأمان من الكود الموجود في الكود السابق
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // 1. التأكد أولاً من أن الملاحظة موجودة في قاعدة البيانات قبل تعديلها
    await getNote(id: note.id);

    // 2. تحديث نص الملاحظة وإعادة تعيين حالة المزامنة إلى غير متزامن (0)
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      // جلب الملاحظة بعد تحديثها مباشرة من قاعدة البيانات
      final updatedNote = await getNote(id: note.id);
      // تحديث القائمة المحلية (الكاش)
      _notes.removeWhere(
        (note) => note.id == updatedNote.id,
      ); // إزالة النسخة القديمة
      _notes.add(updatedNote); // إضافة النسخة الجديدة المحدثة
      _notesStreamController.add(_notes); // بث التغيير فوراً للواجهة

      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // 1. الاستعلام عن كل الملاحظات الموجودة في الجدول بدون شروط
    final notes = await db.query(noteTable);

    // 2. تحويل القائمة كلها (List of Maps) إلى مجموعة كائنات قابلة للتكرار (Iterable)
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);

      // التعديل الجديد: تحديث القائمة المحلية (الكاش) بالبيانات الجديدة
      _notes.removeWhere(
        (note) => note.id == id,
      ); // حذف النسخة القديمة إن وجدت لتجنب التكرار
      _notes.add(note); // إضافة النسخة الأحدث المجلوبة من قاعدة البيانات
      _notesStreamController.add(_notes); // بث القائمة المحدثة للواجهة فوراً

      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);

    _notes = []; // تفريغ القائمة المحلية تماماً في الذاكرة
    _notesStreamController.add(
      _notes,
    ); // بث القائمة الفارغة للواجهة لتختفي كل الملاحظات فوراً من الشاشة

    return numberOfDeletions; // إرجاع عدد الملاحظات التي تم حذفها من قاعدة البيانات
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    // 1. تنفيذ أمر الحذف من جدول الملاحظات بناءً على الرقم التعريفي
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2. إذا عادت النتيجة بـ 0، هذا يعني أن الملاحظة لم تكن موجودة أصلاً
    if (deletedCount == 0) {
      throw CouldNotDeleteNote(); // أو اكتب اسم الـ Exception كما قمت بتعريفه في أعلى ملفك
    } else {
      // 3. حذف الملاحظة من قاعدة البيانات وإعادة تعيين الملاحظات إلى قائمة محلية
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseServices owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // 1. التأكد من أن صاحب الملاحظة (المستخدم) موجود بالفعل في قاعدة البيانات بنفس الإيميل
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    // 2. إدخال الملاحظة الفارغة الجديدة في جدول الملاحظات داخل قاعدة البيانات
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseServices> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseServices.fromRow(result.first);
    }
  }

  Future<DatabaseServices> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseServices(id: userId, email: email);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }
  // الدوال الأساسية لإدارة قاعدة البيانات
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      // محاولة فتح قاعدة البيانات
      await open();
    } on DatabaseAlreadyOpenException {
      // إذا كانت قاعدة البيانات مفتوحة بالفعل، فسترمي الدالة هذا الاستثناء
      // وهنا نتركه فارغاً (// empty) لأن هذا هو المطلوب ولا توجد مشكلة
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(cveateUserTable);
      // create the notes table
      await db.execute(craetNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

























// مخصص فقط لتمثيل جدول المستخدمين (userTable) في ذاكرة الهاتف.
@immutable
class DatabaseServices {
  final int id;
  final String email;

  // هذا هو الـ Constructor العادي الذي تستخدمه لإنشاء مستخدم جديد يدويًا في الكود إذا أردت
  const DatabaseServices({required this.id, required this.email});

  //  هذا يُسمى Named Constructor وهو أهم جزء في الصفحة!
  //عندما تقوم بعمل استعلام (Query) من قاعدة البيانات، تعود إليك
  //البيانات على هيئة خريطة Map<String, Object?>
  DatabaseServices.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person(id: $id, email: $email)';
  }

  @override
  bool operator ==(covariant DatabaseServices other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}




















//  يقوم بتحويل أسطر جدول الملاحظات 
//(notesTable) من قاعدة البيانات الصلبة إلى كائنات 
// (Objects)
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;

  @override
  String toString() {
    return 'Note(id: $id, userId: $userId, text: $text, isSyncedWithCloud: $isSyncedWithCloud)';
  }

  @override
  bool operator ==(covariant DatabaseNote other) =>
      id == other.id &&
      userId == other.userId &&
      text == other.text &&
      isSyncedWithCloud == other.isSyncedWithCloud;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      text.hashCode ^
      isSyncedWithCloud.hashCode;
}
























// هذه هي الكلمات الثابتة (Constants) لأسماء الجداول والأعمدة في SQL

const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';

//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------

//  حقيقية لإنشاء الجداول والكيفية إنشاء الجداول والكيفية إنشاء الجداول نصوص ضخمة مكتوبة بلغة SQL

const cveateUserTable = '''  CREATE TABLE IF NOT EXISTS "user"  (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const craetNotesTable = '''  CREATE TABLE IF NOT EXISTS "notes"  (
	"id"	INTEGER NOT NULL,
	"usrer_id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"is_synced_with_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
 ""
);
  ''';
