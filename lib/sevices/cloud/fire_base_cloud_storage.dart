import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/sevices/cloud/cloud_note.dart';
import 'package:firebase_test/sevices/cloud/cloud_storage_constants.dart';
import 'package:firebase_test/sevices/cloud/cloud_storage_exceptions.dart';



// هو مدير العمليات السحابية، والملف الأهم على الإطلاق.
// شرح بالعربي: هذا الكلاس هو المسؤول الأساسي عن إدارة كل العمليات السحابية مع Firestore (إنشاء، قراءة، تحديث، حذف)
class FirebaseCloudStorage {
  // شرح بالعربي: نحدد هنا المجلد الرئيسي (Collection) المسمى 'notes' داخل قاعدة البيانات للتعامل معه
  final notes = FirebaseFirestore.instance.collection('notes');

  // شرح بالعربي: دالة لحذف ملاحظة معينة من السحاب باستخدام المعرف الفريد الخاص بها (documentId)
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // شرح بالعربي: دالة لتحديث نص الملاحظة السحابية الحالية باستخدام معرفها والنص الجديد
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

   // شرح بالعربي: دالة allNotes تجلب دفق مستمر (Stream) يتحدث تلقائياً عند حدوث أي تغيير في السحاب
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          // شرح بالعربي: هنا نقوم بفلترة الملاحظات لتظهر فقط الملاحظات التي يملكها المستخدم الحالي
          .where((note) => note.ownerUserId == ownerUserId));

  // شرح بالعربي: دالة getNotes تجلب الملاحظات السحابية مرة واحدة فقط (Future) عند طلبها بدلاً من المراقبة المستمرة
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          // شرح بالعربي: نستخدم الكونستركتور الذكي fromSnapshot لتحويل مستندات الفايرستور تلقائياً إلى كائنات كلاس CloudNote في دارت
          .then((value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }


  // شرح بالعربي: دالة لإنشاء ملاحظة جديدة فارغة على سحابة فايرستور وترجع كائن من نوع CloudNote يحتوي على الـ ID الجديد
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }


  // -------------------------------------------------------------
  // شرح بالعربي: (Singleton Pattern) السطور التالية تضمن إنشاء نسخة واحدة ثابتة فقط 
  // من هذا الكلاس ومشاركتها في كل أنحاء التطبيق لمنع تكرار استهلاك الذاكرة
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
