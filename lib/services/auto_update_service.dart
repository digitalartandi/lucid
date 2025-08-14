import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:background_fetch/background_fetch.dart' as bg;
import '../prefs/app_prefs_auto.dart';
import '../research_feed/repo.dart';

const String kWorkTag = 'auto_research_feed_update';

@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    try {
      final q = await AutoUpdatePrefs.getQuery();
      await ResearchFeedRepo.refresh(q: q);
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}

class AutoUpdateService {
  static Future<void> init() async {
    if (Platform.isAndroid) {
      await wm.Workmanager().initialize(workmanagerCallbackDispatcher, isInDebugMode: kDebugMode);
    }
    await bg.BackgroundFetch.configure(
      bg.BackgroundFetchConfig(
        minimumFetchInterval: 60,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiredNetworkType: bg.NetworkType.ANY,
      ),
      _onFetch,
      _onFetchTimeout,
    );
    final enabled = await AutoUpdatePrefs.isEnabled();
    final mins = await AutoUpdatePrefs.getFreqMins();
    if (enabled) {
      await schedule(minutes: mins);
    } else {
      await cancel();
    }
  }

  static Future<void> schedule({int minutes = 1440}) async {
    final enabled = await AutoUpdatePrefs.isEnabled();
    if (!enabled) return;
    final wmInterval = Duration(minutes: minutes < 15 ? 15 : minutes);
    if (Platform.isAndroid) {
      await wm.Workmanager().cancelByUniqueName(kWorkTag);
      await wm.Workmanager().registerPeriodicTask(
        kWorkTag,
        kWorkTag,
        frequency: wmInterval,
        constraints: wm.Constraints(networkType: wm.NetworkType.connected),
        backoffPolicy: wm.BackoffPolicy.linear,
      );
    }
    await bg.BackgroundFetch.start();
  }

  static Future<void> cancel() async {
    if (Platform.isAndroid) {
      await wm.Workmanager().cancelByUniqueName(kWorkTag);
    }
    await bg.BackgroundFetch.stop();
  }

  static Future<void> _onFetch(String taskId) async {
    try {
      final q = await AutoUpdatePrefs.getQuery();
      await ResearchFeedRepo.refresh(q: q);
    } catch (_) {}
    bg.BackgroundFetch.finish(taskId);
  }

  static void _onFetchTimeout(String taskId) {
    bg.BackgroundFetch.finish(taskId);
  }
}
