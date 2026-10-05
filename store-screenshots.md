# صور المتجر — ترنيمنا

الصور المجهزة للمتاجر (Google Play و App Store):
- **iOS Mobile (iPhone 6.9")**: في `store-screenshots/ios/` بمقاس **1320×2868** (App Store إلزامي). التركيب بـ `store-screenshots/build_ios.py`.
- **iOS Tablet (iPad 13")**: في `store-screenshots/ipad/` بمقاس **2064×2752** (App Store iPad إلزامي). التركيب بـ `store-screenshots/build_ipad.py`.
- **Android (Google Play)**: في `store-screenshots/android/` بمقاس **1080×1920** (نسبة 9:16). التركيب بـ `store-screenshots/build.py`.

اللقطات الخام من التطبيق موجودة في `store-screenshots/raw/`، `store-screenshots/raw-ios/`، و `store-screenshots/raw-ipad/`.

---

## الستايل
- **الخلفية**: تدرج برتقالي دافئ من هوية التطبيق (`#ff9a56` إلى `#ff5733` ثم `#d63a1b`) مع كرات إضاءة ناعمة (blobs).
- **العناوين**: أبيض بخط **Tajawal ExtraBold** مع سطر شرح توضيحي بخط **Tajawal Medium**.
- **إطار الجهاز**:
  - **iPhone**: إطار أسود بحواف دائرية فخمة (`border-radius: 132px`) ومحاذاة تعزل شريط الحالة العلوي بدقة.
  - **iPad**: إطار تابلت متناسق الحواف (`border-radius: 64px`) مخصص لشاشات iPad الكبيرة.
  - **Android**: إطار موبايل أسود أنيق مع زوايا دائرية وظلال عميقة.
- **اللغة والاتجاه**: النصوص باللهجة المصرية المحببة مع دعم كامل لاتجاه اليمين لليسار (RTL).

---

## 1. شاشات iOS Mobile — iPhone 6.9" (جاهز)
> المقاس: **1320×2868** | المجلد: `store-screenshots/ios/`

| # | الملف | العنوان | الشرح | الشاشة |
|---|---|---|---|---|
| 1 | `01-search.png` | ابحث عن الترانيم بسهولة 🔍 | اكتب أي كلمة من الترنيمة وهتلاقيها في ثواني | الرئيسية بعد البحث عن «يسوع» |
| 2 | `02-player.png` | كل يوم ترنيمة جديدة 🎵 | مشغّل بسيط ومريح يعيشك جو العبادة | المشغّل الكامل مع أزرار التحكم والكلمات |
| 3 | `03-downloads.png` | حمّل ترانيمك واسمعها من غير نت 📥 | ترانيمك معاك في أي مكان، حتى من غير إنترنت | الترانيم المحملة في الذاكرة المحلية |
| 4 | `04-playlists.png` | نظّم مكتبة ترانيمك 📚 | اعمل قوائمك الخاصة: صباح، صوم، أعياد، تسبيح | قوائم التشغيل الخاصة بالمستخدم |

---

## 2. شاشات iOS Tablet — iPad 13" (جاهز)
> المقاس: **2064×2752** | المجلد: `store-screenshots/ipad/`

| # | الملف | العنوان | الشرح | الشاشة |
|---|---|---|---|---|
| 1 | `01-search.png` | ابحث عن الترانيم بسهولة 🔍 | اكتب أي كلمة من الترنيمة وهتلاقيها في ثواني | الرئيسية مع واجهة الآيباد المتسعة والبحث |
| 2 | `02-player.png` | كل يوم ترنيمة جديدة 🎵 | مشغّل بسيط ومريح يعيشك جو العبادة | مشغّل الآيباد مع تفاصيل الترنيمة |
| 3 | `03-downloads.png` | حمّل ترانيمك واسمعها من غير نت 📥 | ترانيمك معاك في أي مكان، حتى من غير إنترنت | مكتبة الترانيم بدون إنترنت |
| 4 | `04-playlists.png` | نظّم مكتبة ترانيمك 📚 | اعمل قوائمك الخاصة: صباح، صوم، أعياد، تسبيح | مجموعات وقوائم التشغيل |

---

## 3. شاشات Android — Google Play (جاهز)
> المقاس: **1080×1920** (9:16) | المجلد: `store-screenshots/android/`

| # | الملف | العنوان | الشرح | الشاشة |
|---|---|---|---|---|
| 1 | `01-search.png` | ابحث عن الترانيم بسهولة 🔍 | اكتب أي كلمة من الترنيمة وهتلاقيها في ثواني | الرئيسية بعد البحث عن «يسوع» |
| 2 | `02-player.png` | كل يوم ترنيمة جديدة 🎵 | مشغّل بسيط ومريح يعيشك جو العبادة | المشغّل الكامل |
| 3 | `03-downloads.png` | حمّل ترانيمك واسمعها من غير نت 📥 | ترانيمك معاك في أي مكان، حتى من غير إنترنت | الترانيم المحملة (10 ترانيم) |
| 4 | `04-playlists.png` | نظّم مكتبة ترانيمك 📚 | اعمل قوائمك الخاصة: صباح، صوم، أعياد، تسبيح | قوائم التشغيل (6 قوائم) |

---

## إزاي تعيد الإنشاء أو تعدل النصوص

1. **لتعديل النصوص والعناوين**:
   - غيّر العناوين في قائمة `SLIDES` داخل ملفات البناء:
     - لـ iOS Mobile: `store-screenshots/build_ios.py`
     - لـ iPad: `store-screenshots/build_ipad.py`
     - لـ Android: `store-screenshots/build.py`
2. **للتشغيل وإنشاء الصور**:
   - لـ iOS Mobile: `python3 store-screenshots/build_ios.py`
   - لـ iPad: `python3 store-screenshots/build_ipad.py`
   - لـ Android: `python3 store-screenshots/build.py`
   *(السكربتات بتستخدم Microsoft Edge افتراضياً أو المتصفح المحدد بالمتغير `CHROME`)*.

---

## إزاي اتصوّرت اللقطات على المحاكيات

### أ. محاكي iOS (iPhone 18 Pro Max & iPad Pro 13-inch)
1. **تظبيط شريط الحالة النظيف (Clean Status Bar)**:
   ```bash
   xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
   ```
2. **التقاط اللقطات**:
   ```bash
   # للآيفون
   xcrun simctl io booted screenshot store-screenshots/raw-ios/0X-name.png
   # للآيباد
   xcrun simctl io booted screenshot store-screenshots/raw-ipad/0X-name.png
   ```

### ب. محاكي Android
1. **تظبيط شريط الحالة**:
   ```bash
   adb shell am broadcast -a com.android.systemui.demo -e command enter
   adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
   adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
   ```
2. **التقاط اللقطات**:
   ```bash
   adb shell screencap -p > store-screenshots/raw/0X-name.png
   ```

---

## رفع الصور لـ App Store Connect
- تحت **iOS App**: اختر قسم **6.9" Display** وارفع الصور الأربعة من `store-screenshots/ios/`.
- تحت **iPad App**: اختر قسم **13" Display** وارفع الصور الأربعة من `store-screenshots/ipad/`.
- أول صورة (`01-search.png`) هي الصورة الأساسية التي تظهر في نتائج البحث بمتجر التطبيقات.
