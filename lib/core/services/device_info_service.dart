import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  static DeviceInfoService get instance => _instance;

  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceString;

  Future<String> getDeviceString() async {
    if (_cachedDeviceString != null) return _cachedDeviceString!;

    final deviceData = await _collectDeviceData();
    _cachedDeviceString = _formatDeviceString(deviceData);

    await SharedPreferencesService.instance
        .setData(PreferenceKey.deviceInfo, _cachedDeviceString!);

    return _cachedDeviceString!;
  }

  String getCachedDeviceString() {
    return _cachedDeviceString ??
        SharedPreferencesService.instance
                .getData<String>(PreferenceKey.deviceInfo) ??
        'Unknown Device';
  }

  Future<Map<String, String>> _collectDeviceData() async {
    final data = <String, String>{
      'model': 'Unknown',
      'browser': 'Unknown Browser',
      'osVersion': 'Unknown OS',
    };

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        data['model'] = androidInfo.brand.isNotEmpty
            ? '${androidInfo.brand} ${androidInfo.model}'
            : androidInfo.model;
        data['osVersion'] = 'Android ${androidInfo.version.release}';
        data['browser'] = 'Chrome for Android';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        data['model'] = iosInfo.model;
        data['osVersion'] = 'iOS ${iosInfo.systemVersion}';
        data['browser'] = 'Safari';
      } else if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        data['model'] = webInfo.platform ?? 'Web Device';
        data['browser'] = webInfo.vendor ?? 'Web Browser';
        data['osVersion'] = webInfo.appVersion ?? '';
      }
    } catch (e) {
      // Keep default values
    }

    return data;
  }

  String _formatDeviceString(Map<String, String> data) {
    return '${data['model']};${data['browser']};${data['osVersion']}';
  }
}

class DeviceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final deviceString = DeviceInfoService.instance.getCachedDeviceString();
    final token =
        SharedPreferencesService.instance.getData<String>(PreferenceKey.authToken);

    options.headers['device'] = deviceString;
    if (token != null) {
      options.headers['x-api-key'] = token;
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - could trigger logout here
    }
    return handler.next(err);
  }
}