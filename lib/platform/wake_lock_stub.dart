// lib/platform/wake_lock_stub.dart

/// Ob die Plattform den Bildschirm wach halten kann.
bool get wakeLockSupported => false;

/// Fordert an, dass der Bildschirm an bleibt. true bei Erfolg.
Future<bool> acquireWakeLock() async => false;

Future<void> releaseWakeLock() async {}
