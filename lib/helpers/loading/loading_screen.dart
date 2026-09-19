import 'dart:async';
import 'package:firebase_test/helpers/loading/loading_screen_controller.dart';
import 'package:flutter/material.dart';

class LoadingScreen {
  // -------------------------------------------------------------
  // 1️⃣ نمط الـ Singleton: لضمان وجود نسخة واحدة فقط من الشاشة في التطبيق كله
  // -------------------------------------------------------------
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  // ده المتغير اللي هيشيل "الريموت كنترول" اللي بيتحكم في قفل وتحديث الشاشة
  LoadingScreenController? controller;

  // -------------------------------------------------------------
  // 2️⃣ دالة الـ show: الدالة الرئيسية اللي بنستدعيها عشان نظهر الشاشة
  // -------------------------------------------------------------
  void show({
    required BuildContext context,
    required String text,
  }) {
    // الـ if دي بتفحص: لو الشاشة مفتوحة بالفعل، حدث النص المكتوب جواها بس واقفل الدالة
    if (controller?.update(text) ?? false) {
      return;
    } else {
      // لو مش مفتوحة (أول مرة)، شغل دالة البناء وخزن الريموت بتاعها في الـ controller
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  // -------------------------------------------------------------
  // 3️⃣ دالة الـ hide: بنستدعيها عشان نقفل شاشة التحميل نهائياً
  // -------------------------------------------------------------
  void hide() {
    controller?.close(); // شغل زرار القفل من الريموت
    controller = null;   // فضّي المتغير عشان يستعد للمرة الجاية
  }

  // -------------------------------------------------------------
  // 4️⃣ دالة الـ showOverlay: الدالة المسؤول عن الرسم والبناء الحقيقي
  // -------------------------------------------------------------
  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    // إنشاء ماسورة بيانات (Stream) مخصصة للنصوص، وضخ النص الأول جواها
    final _text = StreamController<String>();
    _text.add(text);

    // الوصول للطبقة السحرية (Overlay) الشفافة اللي فوق التطبيق كله
    final state = Overlay.of(context);
    
    // حساب مقاس شاشة الموبايل الحالية بالظبط (طول وعرض بالبكسل)
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // إنشاء العنصر اللي هيتحط جوه الطبقة الشفافة (المربع الأبيض ومؤشر التحميل)
    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150), // خلفية سوداء شفافة تغطي التطبيق بالكامل
          child: Center(
            child: Container(
              // تحديد حجم المربع الأبيض بحيث مياخدش أكتر من 80% من حجم الشاشة
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white, // المربع الداخلي أبيض
                borderRadius: BorderRadius.circular(10.0), // حواف دائرية
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(), // الدائرة الزرقاء المتحركة للتحميل
                      const SizedBox(height: 20),
                      
                      // مستمع الـ Stream: قاعد مستني أي نص جديد ينزل من الماسورة عشان يعرضه فوراً
                      StreamBuilder(
                        stream: _text.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String, // عرض النص المحدث حالياً
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // حقن (إدخال) شاشة التحميل فوق التطبيق فوراً
    state.insert(overlay);

    // -------------------------------------------------------------
    // 5️⃣ تقفيل كائن الـ Controller (صناعة أزرار ريموت التحكم)
    // -------------------------------------------------------------
    return LoadingScreenController(
      // وظيفة زرار القفل (close): تقفل ماسورة الـ Stream وتشيل الشاشة من الـ Overlay
      close: () {
        _text.close();
        overlay.remove();
        return true;
      },
      // وظيفة زرار التحديث (update): ترمي النص الجديد في الماسورة عشان الشاشة تتحدث وهي مفتوحة
      update: (text) {
        _text.add(text);
        return true;
      },
    );
  }
}
