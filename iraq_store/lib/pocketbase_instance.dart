// pocketbase_instance.dart
import 'package:pocketbase/pocketbase.dart';

// هام جداً:
// 1. افتح CMD واكتب ipconfig لتعرف IPv4 Address الخاص بك.
// 2. استبدل '192.168.1.X' بالرقم الذي ظهر لك.
// 3. تأكد أنك تشغل PocketBase بالأمر: .\pocketbase.exe serve --http="0.0.0.0:8090"

// مثال: final pb = PocketBase('http://192.168.0.100:8090');

final pb = PocketBase('http://127.0.0.1:8090'); // <--- عدل هذا الرقم!
