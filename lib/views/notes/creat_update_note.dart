import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/sevices/cloud/cloud_note.dart';
import 'package:firebase_test/utilies/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:flutter/material.dart';
// شرح بالعربي: استيراد كلاس الملاحظة السحابية والـ Exceptions مع مراعاة اسم مجلدك 'sevices'
import 'package:firebase_test/sevices/cloud/fire_base_cloud_storage.dart';
// شرح بالعربي: استيراد خدمات SQLite المحلية مع تعديل المسار ليتطابق مع اسم مجلدك المكتوب 'curd' بدلاً من 'crud'
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:firebase_test/utilies/generics/get_arguments.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  CloudNote? _cloudNote;
  // تصحيح التسمية هنا باستخدام اسم كلاسك الخاص NotesServices والشرطة السفلية الصحيحة للمتغير
  late final NotesServices _notesService;
  late final FirebaseCloudStorage _cloudStorage;
  late final TextEditingController _textController;

  // تهيئة وتجهيز خدمة الملاحظات ومتحكم النص بمجرد فتح شاشة الملاحظة الجديدة
  @override
  void initState() {
    // شرح بالعربي: تهيئة الخدمة المحلية SQLite لكي تظل تعمل في الخلفية
    _notesService = NotesServices();
    // شرح بالعربي: تهيئة الخدمة السحابية FirebaseCloudStorage لكي تعمل بالتوازي مع الخدمة المحلية
    _cloudStorage = FirebaseCloudStorage();
    // شرح بالعربي: تهيئة متحكم النصوص لمتابعة الحقل أولاً بأول
    _textController = TextEditingController();
    super.initState();
  }

  // شرح بالعربي: دالة الاستماع الموحدة بالـ أندرسكور التي تقوم بتحديث الملاحظة في السيكوال المحلي والفايرستور السحابي بالتوازي مع كل حرف يكتبه المستخدم
  void _textControllerListener() async {
    final localNote = _note; // كائن الملاحظة المحلية SQLite بالـ أندرسكور
    final currentCloudNote =
        _cloudNote; // كائن الملاحظة السحابية Firestore بالـ أندرسكور
    final text = _textController.text; // متحكم النصوص بالـ أندرسكور

    // أولاً: تحديث الملاحظة المحلية في SQLite (إذا كانت موجودة وعمل المستخدم أي تعديل)
    if (localNote != null && text.isNotEmpty) {
      await _notesService.updateNote(note: localNote, text: text);
    }

    // ثانياً: تحديث الملاحظة السحابية في Firestore (إذا كانت موجودة وعمل المستخدم أي تعديل)
    if (currentCloudNote != null && text.isNotEmpty) {
      await _cloudStorage.updateNote(
        documentId: currentCloudNote.documentId,
        text: text,
      );
    }
  }

  // دالة إنشاء الملاحظة وتثبيت المستمع اللحظي في الخلفية بشكل آمن لضمان بث التحديثات تلقائياً
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  // شرح بالعربي: دالة سحابية جديدة لجلب الملاحظة السحابية الحالية أو إنشاء واحدة جديدة فارغة على Firestore إذا لم تكن موجودة
  Future<CloudNote> createOrGetExistingCloudNote(BuildContext context) async {
    final widgetCloudNote = context.getArgument<CloudNote>();

    if (widgetCloudNote != null) {
      _cloudNote = widgetCloudNote;
      _textController.text = widgetCloudNote.text;
      return widgetCloudNote;
    }

    final existingCloudNote = _cloudNote;
    if (existingCloudNote != null) {
      return existingCloudNote;
    }

    // شرح بالعربي: جلب بيانات المستخدم الحالي المسجل في الـ Firebase Auth
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;

    // شرح بالعربي: إنشاء الملاحظة الجديدة مباشرة على السحاب باستخدام الـ _cloudStorage المعرف سابقاً
    final newCloudNote = await _cloudStorage.createNewNote(ownerUserId: userId);
    _cloudNote = newCloudNote;
    return newCloudNote;
  }

  // شرح بالعربي: دالة لحذف الملاحظة تلقائياً إذا خرج المستخدم وتركها فارغة (تحذف محلياً ومن السحاب معاً)
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    final cloudNote = _cloudNote;

    // أولاً: الحذف من السيكوال المحلي
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }

    // ثانياً: الحذف من الفايرستور السحابي
    if (_textController.text.isEmpty && cloudNote != null) {
      _cloudStorage.deleteNote(documentId: cloudNote.documentId);
    }
  }

  // شرح بالعربي: دالة لحفظ أو تحديث الملاحظة تلقائياً عند الخروج إذا كانت تحتوي على نص (تحفظ محلياً وفي السحاب معاً)
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final cloudNote = _cloudNote;
    final text = _textController.text;

    // أولاً: التحديث في السيكوال المحلي
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text);
    }

    // ثانياً: التحديث في الفايرستور السحابي
    if (cloudNote != null && text.isNotEmpty) {
      await _cloudStorage.updateNote(
        documentId: cloudNote.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty(); // 1. فحص وحذف الملاحظة لو تركت فارغة
    _saveNoteIfTextNotEmpty(); // 2. فحص وحفظ الملاحظة تلقائياً لو تم كتابة نص
    _textController
        .dispose(); // 3. تدمير متحكم النص لتوفير ذاكرة الهاتف (إجباري)
    super.dispose();
  }

  // شرح بالعربي: دالة لربط وتفعيل الـ Listener الموحد مع متحكم النصوص بعد إزالة القديم لمنع تكرار الاستماع في الذاكرة
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.start_typing_your_note,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
        ),

        // 💡 HINT بالعربي:
        // هنا بنحط زرار الشير في شريط التطبيق فوق (AppBar).
        // أول ما المستخدم يدوس عليه، الفانكشن دي هتروح تبص على النص المكتوب في الـ textController.
        // لو النص فاضي، أو لو لسه مفيش نوت اتخلقت أصلاً (سواء محلي _note أو سحابي _cloudNote)، بنطلع له ديالوج التنبيه اللي عملناه سوا.
        // أما لو النوت فيها كلام، بننادي على مكتبة Share.share وبنبعت لها النص، فتفتح قائمة الشير بتاعة الموبايل فوراً!
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;

              // 👇 بنفحص الشرطين سوا: لو النص فاضي أو لو الكائنين بتوع النوتس لسه بـ null
              if (text.isEmpty || (_note == null && _cloudNote == null)) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                // لو تمام وفيها نص، بنعمل شير للمكتوب
                await SharePlus.instance.share(ShareParams(text: text));
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      // شرح بالعربي: دمج الـ FutureBuilder المحلي والسحابي بالتوازي بدون أخطاء في الأقواس
      body: FutureBuilder<DatabaseNote>(
        future: createOrGetExistingNote(context),
        builder: (context, localSnapshot) {
          return FutureBuilder<CloudNote>(
            future: createOrGetExistingCloudNote(context),
            builder: (context, cloudSnapshot) {
              // شرح بالعربي: التأكد من انتهاء المحركين المحلي والسحابي معاً قبل عرض الحقل وتفعيل الـ Listener
              if (localSnapshot.connectionState == ConnectionState.done &&
                  cloudSnapshot.connectionState == ConnectionState.done) {
                // شرح بالعربي: استدعاء دالة الـ Setup الموحدة بعد فتح الأقواس وتوفير تعريفها بالأعلى فوراً
                _setupTextControllerListener();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller:
                        _textController, // تأكد من الـ أندرسكور هنا لتطابق تعريفه فوق
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    maxLength: 1000,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_note,
                      border: InputBorder.none,
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
} // قوس قفل الكلاس الأساسي للشاشة بالكامل

  
  








  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('New Note')),
//       body: FutureBuilder(
//         future: createNewNote(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             // فحص أمان للتأكد من نجاح إنشاء الملاحظة قبل عرض حقل النص ومنع انهيار الشاشة
//             case ConnectionState.done:
//               if (snapshot.hasData) {
//                 _note = snapshot.data as DatabaseNote;
//                 _setupTextControllerListener();
//                 return TextField(
//                   controller: _textController,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   decoration: const InputDecoration(
//                     hintText: 'Start typing your note...',
//                   ),
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Database Error: ${snapshot.error}'));
//               } else {
//                 return const Center(child: Text('No note data found.'));
//               }

//             default:
//               return const CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }