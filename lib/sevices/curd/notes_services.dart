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

  // دالة التحقق والأمان من الكود الموجود في الكود السابق

  Future<DatabaseNote> updateNote({
  required DatabaseNote note,
  required String text,
}) async {
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
    // 3. جلب الملاحظة المحدثة مجدداً وإعادتها للتطبيق
    return await getNote(id: note.id);
  }
}


Future<Iterable<DatabaseNote>> getAllNotes() async {
  final db = _getDatabaseOrThrow();
  
  // 1. الاستعلام عن كل الملاحظات الموجودة في الجدول بدون شروط
  final notes = await db.query(noteTable);
  
  // 2. تحويل القائمة كلها (List of Maps) إلى مجموعة كائنات قابلة للتكرار (Iterable)
  return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
}


  Future<DatabaseNote> getNote({required int id}) async {
  final db = _getDatabaseOrThrow();
  
  // 1. الاستعلام عن الملاحظة بناءً على الـ id وتحديد النتيجة بملاحظة واحدة فقط
  final notes = await db.query(
    noteTable,
    limit: 1,
    where: 'id = ?',
    whereArgs: [id],
  );
  
  // 2. التحقق من وجود الملاحظة وتحويلها إلى كائن يفهمه فلاتر
  if (notes.isEmpty) {
    throw CouldNotFindNote();
  } else {
    return DatabaseNote.fromRow(notes.first);
  }
}


  Future<int> deleteAllNotes() async {
  final db = _getDatabaseOrThrow();
  return await db.delete(noteTable);
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
  }
}


Future<DatabaseNote> createNote({required DatabaseServices owner}) async {
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
  
  return note;
}


  Future<DatabaseServices> getUser({required String email}) async {
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
      final db = _getDatabaseOrThrow();
      final deletedCount = await db.delete(
       noteTable ,
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
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentDirectory();
      }
    }
  }

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// ------------------------------ الكود السابق للتحقق والأمان ------------------------------

// كلمة سحرية تخبر لغة Dart أن هذا الكلاس "غير قابل للتعديل المباشر"
// تحويل صفوف جداول الـ SQL إلى كائنات يفهمها فلاتر لعرضها في الواجهات
@immutable
class DatabaseServices {
  final int id;
  final String email;

  // هذا هو الـ Constructor العادي الذي تستخدمه لإنشاء مستخدم جديد يدويًا في الكود إذا أردت
  const DatabaseServices({required this.id, required this.email});

  void hello() {
    debugPrint('Hello');
  }

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
