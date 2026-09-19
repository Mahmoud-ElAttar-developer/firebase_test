import 'package:flutter/foundation.dart' show immutable;

// -----------------------------------------------------------------------------
// 1️⃣ استخدام الـ typedef لتعريف ألقاب (أسماء مستعارة) لشكل الدوال تسهيلاً للقراءة
// -----------------------------------------------------------------------------

// لقب لأي دالة وظيفتها تقفل شاشة التحميل وترجع قيمة بولين (صح/غلط)
typedef CloseLoadingScreen = bool Function();

// لقب لأي دالة وظيفتها تاخد نص (String) لتحديث الشاشة وترجع قيمة بولين (صح/غلط)
typedef UpdateLoadingScreen = bool Function(String text);

// -----------------------------------------------------------------------------
// 2️⃣ بناء كلاس الـ Controller (الريموت كنترول اللي بيتحكم في شاشة التحميل)
// -----------------------------------------------------------------------------

@immutable // الكلمة دي معناها إن البيانات جوه الكلاس ده ثابتة ومستحيل تتغير بعد ما يتصنع لتحسين الأداء
class LoadingScreenController {
  // زرار القفل جوه الريموت (نوعه دالة مطابقة للقب CloseLoadingScreen)
  final CloseLoadingScreen close;

  // زرار التحديث جوه الريموت (نوعه دالة مطابقة للقب UpdateLoadingScreen)
  final UpdateLoadingScreen update;

  // المصنع (Constructor) الخاص بصناعة الريموت كنترول
  const LoadingScreenController({
    required this.close, // إجباري نبرمج دالة القفل عند صناعة الـ controller
    required this.update, // إجباري نبرمج دالة التحديث عند صناعة الـ controller
  });
}
