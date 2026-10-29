# จัดก๊วนตีแบด

แอป Flutter สำหรับจัดก๊วนตีแบดแบบไม่เป็นทางการ — นับผู้เล่น นำเข้ารายชื่อจากข้อความ LINE จัดคู่เดี่ยว/คู่ และหมุนเวียนคนที่ตีน้อยที่สุดขึ้นคอร์ทก่อน

แพลตฟอร์ม: **iOS**, **Android**, และ **Flutter web** (สำหรับพรีวิว)

## ความต้องการของเครื่อง

- [Flutter](https://docs.flutter.dev/get-started/install) 3.24 ขึ้นไป (พัฒนาด้วย 3.47)
- บน Mac: Xcode + CocoaPods สำหรับ iPhone
- บน Windows/Linux/Mac: Android Studio หรือ cmdline-tools สำหรับแอนดรอยด์

ตรวจเครื่อง:

```bash
flutter doctor
```

## รันบนเว็บ (พรีวิวเร็วสุด)

```bash
cd <โฟลเดอร์โปรเจกต์>
flutter pub get
flutter run -d chrome
```

หรือบิลด์สแตติก:

```bash
flutter build web
```

## รันบน iPhone จากเครื่อง Mac (Apple ID ฟรี)

1. ติดตั้ง Xcode จาก App Store แล้วเปิดครั้งหนึ่งเพื่อยอมรับไลเซนส์
2. ติดตั้งเครื่องมือเสริม:

   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. เสียบ iPhone ด้วยสาย ปลดล็อกเครื่อง แล้วแตะ **Trust This Computer**
4. เปิด `ios/Runner.xcworkspace` ใน Xcode
5. ที่ **Signing & Capabilities** ของทาร์เก็ต `Runner`
   - เลือก **Team** เป็น Apple ID ของคุณ (เมนู Xcode → Settings → Accounts → เพิ่ม Apple ID ฟรีได้)
   - เปลี่ยน Bundle Identifier ให้ไม่ซ้ำ เช่น `com.yourname.kwanbad`
   - Xcode จะสร้าง provisioning แบบ Personal Team ให้อัตโนมัติ
6. บน iPhone: **Settings → General → VPN & Device Management** แล้ว Trust ใบรับรองของ Apple ID
7. จากโฟลเดอร์โปรเจกต์:

   ```bash
   flutter pub get
   flutter run
   ```

   หรือเลือกเครื่องจาก `flutter devices` แล้วระบุ `-d <deviceId>`

หมายเหตุของบัญชีฟรี: แอปหมดอายุในประมาณ 7 วัน ต้องเสียบเครื่องแล้วรันใหม่ และใช้ได้เฉพาะอุปกรณ์ที่ลงทะเบียนกับเครื่อง Mac นั้น

## รันบน Android

1. เปิด **Developer options** และ **USB debugging** บนมือถือ
2. เสียบสาย อนุญาตการดีบัก
3. ตรวจว่าเครื่องขึ้นใน `flutter devices`
4. รัน:

   ```bash
   flutter pub get
   flutter run
   ```

จำลองเครื่อง:

```bash
flutter emulators
flutter emulators --launch <emulator_id>
flutter run
```

## ทดสอบและวิเคราะห์

```bash
flutter analyze
flutter test
```

## ฟีเจอร์หลัก

- **ก๊วนวันนี้** — วันที่/เวลา จำนวนคอร์ท (แก้ได้) จำนวนผู้เล่น ปุ่มนำเข้า LINE และเริ่มจัดคู่
- **รายชื่อผู้เล่น** — ค้นหา เพิ่ม แก้ชื่อ ลบ (มียืนยัน) ติดแท็กระดับ A / B+ / B / C …
- **นำเข้าจาก LINE** — วางข้อความจากแชท (เลขลำดับ, อีโมจิ, `+1`, ชื่อไม่มีเลข) ติ๊กเลือกก่อนเพิ่ม ข้ามชื่อที่มีอยู่แล้ว ไม่เรียก LINE API
- **จัดคู่** — สลับโหมดเดี่ยว / ทีม (คู่) จัดลงคอร์ท มีคิวรอ ปุ่มสุ่มใหม่ และจบเกมเพื่อหมุนคนที่ตีน้อยที่สุดขึ้นก่อน ถ้าระบุระดับจะบาลานซ์ฝีมือ
- **ประวัติ** — เกมที่ผ่านมา และจำนวนเกมต่อคน

ข้อมูลเก็บในเครื่องด้วย `shared_preferences` สถานะใช้ Riverpod
