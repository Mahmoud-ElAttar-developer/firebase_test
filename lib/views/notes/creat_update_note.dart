import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:firebase_test/utilies/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
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
    await _notesService.updateNote(
      note: note,
      text: text,
    ); // تحديث الملاحظة في قاعدة البيانات
  }

  // دالة لتنظيم وربط مستمع النص بحقل الكتابة ومنع تكرار الاستماع في الذاكرة
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
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
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
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
        future: createOrGetExistingNote( context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // في حالة أن الـ Future انتهى من العمل وقاعدة البيانات ردت علينا
            case ConnectionState.done:
              // فحص أمان: نتأكد أولاً أن قاعدة البيانات نجحت في إنشاء الملاحظة ولم ترجع قيمة فارغة
              if (snapshot.hasData && snapshot.data != null) {
                // حفظ الملاحظة داخل المتغير العام لكي يتمكن الـ Listener من تعديلها أثناء الكتابة
                // _note = snapshot.data as DatabaseNote;

                // تشغيل الـ Listener لمراقبة الكيبورد وحفظ الكلمات فوراً في الداتابيز
                _setupTextControllerListener();
                // عرض واجهة الكتابة (التكست فيلد) للمستخدم بعد التأكد من أمان البيانات
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
              } else {
                // في حالة وجود مشكلة في الداتابيز ولم ترجع بيانات، نعرض رسالة خطأ بدلاً من الانهيار بشاشة حمراء
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Error: ${snapshot.error ?? "No note data found."}',
                    ),
                  ),
                );
              }

            // في حالة أن قاعدة البيانات لسه بتحمل، نعرض مؤشر تحميل دائري
            default:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
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