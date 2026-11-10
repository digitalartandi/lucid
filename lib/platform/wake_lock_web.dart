// lib/platform/wake_lock_web.dart
//
// Screen Wake Lock API des Browsers (navigator.wakeLock).
// ignore_for_file: invalid_runtime_check_with_js_interop_types
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSObject? _sentinel;

JSObject? _wakeLock() {
  final JSAny? nav = globalContext['navigator'];
  if (nav == null) return null;
  final JSAny? wl = (nav as JSObject)['wakeLock'];
  if (wl == null) return null;
  return wl as JSObject;
}

/// Ob die Plattform den Bildschirm wach halten kann.
bool get wakeLockSupported {
  try {
    return _wakeLock() != null;
  } catch (_) {
    return false;
  }
}

/// Fordert an, dass der Bildschirm an bleibt. true bei Erfolg.
///
/// Der Browser gibt die Sperre frei, sobald der Tab in den Hintergrund geht;
/// beim Zurückkehren muss sie erneut angefordert werden.
Future<bool> acquireWakeLock() async {
  try {
    final JSObject? wl = _wakeLock();
    if (wl == null) return false;
    final JSPromise<JSAny?> promise =
        wl.callMethod<JSPromise<JSAny?>>('request'.toJS, 'screen'.toJS);
    final JSAny? result = await promise.toDart;
    if (result == null) return false;
    _sentinel = result as JSObject;
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> releaseWakeLock() async {
  final JSObject? s = _sentinel;
  _sentinel = null;
  if (s == null) return;
  try {
    await s.callMethod<JSPromise<JSAny?>>('release'.toJS).toDart;
  } catch (_) {
    // Bereits freigegeben.
  }
}
