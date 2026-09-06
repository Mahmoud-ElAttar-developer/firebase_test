import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  // تصحيح التسمية هنا باستخدام اسم كلاسك الخاص NotesServices والشرطة السفلية الصحيحة للمتغير
  late final NotesServices _notesService;
  late final TextEditingController _textController;

  // تهيئة وتجهيز خدمة الملاحظات ومتحكم النص بمجرد فتح شاشة الملاحظة الجديدة
  @override
  void initState() {
    _notesService = NotesServices(); // توحيد المتغير بدون أخطاء إملائية
    _textController = TextEditingController();
    super.initState();
  }

  // دالة الاستماع لحقل الكتابة وتحديث الملاحظة في قاعدة البيانات فوراً مع كل حرف يكتبه المستخدم
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  // دالة لتنظيم وربط مستمع النص بحقل الكتابة ومنع تكرار الاستماع في الذاكرة
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // دالة إنشاء الملاحظة وتثبيت المستمع اللحظي في الخلفية بشكل آمن لضمان بث التحديثات تلقائياً
  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getOrCreateUser(email: email);

    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;

    // تأكد من وجود هذا السطر هنا لتفعيل الحفظ اللحظي مع كل حرف يكتبه المستخدم
    _setupTextControllerListener();

    return newNote;
  }

  //   اذا دخل المستخدم و خرج فورا تقوم بمسح اى مذكرة من قاعدة البيانات
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  //  هذه الدالة مسؤولة عن الحفظ التلقائي الذكي؛ فعندما يقرر المستخدم الخروج من شاشة الملاحظة أو إغلاقها، تقوم الدالة بحفظ ملاحظة جديدة
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text);
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

  // بناء الشاشة الرسومية للملاحظة الجديدة والاعتماد التلقائي على الحفظ اللحظي المستقر
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;

              // 👈 هذا هو السطر المفقود الذي يجب أن تتأكد من وجوده هنا بالملي
              _setupTextControllerListener();
              // التعديل الذكي: عرض حقل الكتابة مباشرة والاعتماد على الحفظ اللحظي المربوط مسبقاً في الخلفية
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                    border: InputBorder.none,
                  ),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}







  
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