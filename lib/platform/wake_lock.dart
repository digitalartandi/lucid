// lib/platform/wake_lock.dart
//
// Bildschirm wach halten (nur Web; auf anderen Plattformen ohne Wirkung,
// bis dort eine native Umsetzung ergänzt wird).
export 'wake_lock_stub.dart' if (dart.library.js_interop) 'wake_lock_web.dart';
