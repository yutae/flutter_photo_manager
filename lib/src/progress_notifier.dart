import 'dart:async';

import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager/src/utils/convert_utils.dart';

typedef void ICloudProgressCallback(ICloudProgressEntity entity);

class ProgressNotifier {
  MethodChannel channel;

  ProgressNotifier(this.channel) {
    init();
  }

  void init() {
    channel.setMethodCallHandler(_onCall);
  }

  /// callbacks
  final _notifyCallback = <ICloudProgressCallback>[];

  /// add callback
  void addCallback(ICloudProgressCallback callback) =>
      _notifyCallback.add(callback);

  /// remove callback
  void removeCallback(ICloudProgressCallback callback) =>
      _notifyCallback.remove(callback);

  Future<void> _onCall(MethodCall call) async {
    if (call.method == "iCloudProgress") {
      final progress = ConvertUtils.convertProgressToEntity(call.arguments);
      _notifyProgress(progress);
    }
  }

  void _notifyProgress(ICloudProgressEntity progress) {
    for (final notifier in _notifyCallback) {
      notifier.call(progress);
    }
  }
}
