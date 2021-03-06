/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:native_lib/native_lib.dart' as native_lib;
import 'package:oktoast/oktoast.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:ffi/ffi.dart';
import 'package:xcam_one/global/constants.dart';

import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/capture_entity.dart';
import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/hearbeat_entity.dart';
import 'package:xcam_one/models/notify_status_entity.dart';
import 'package:xcam_one/models/ssid_pass_entity.dart';
import 'package:xcam_one/models/version_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/camera_state.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/pages/camera/pages/camera_page.dart';
import 'package:xcam_one/pages/photo/pages/photo_page.dart';
import 'package:xcam_one/pages/setting/pages/setting_page.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/dialog_utils.dart';
import 'package:xcam_one/utils/socket_utils.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/photo.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera.png',
        width: 40,
        height: 40,
      ),
      activeIcon: Image.asset(
        'assets/images/select_camera.png',
        width: 70,
        height: 70,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/setting.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
  ];

  final List<BottomNavigationBarItem> cameraBottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_photo.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera.png',
        width: 40,
        height: 40,
      ),
      activeIcon: Image.asset(
        'assets/images/select_camera.png',
        width: 70,
        height: 70,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_setting.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
  ];

  /// TODO: 4/14/21 ???????????????????????????
  final List<BottomNavigationBarItem> disableCameraBottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_photo_disable.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_disable.png',
        width: 60,
        height: 60,
      ),
      label: '??????',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_setting_disable.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: '??????',
    ),
  ];

  int _currentIndex = 0;

  final _pages = [PhotoPage(), CameraPage(), SettingPage()];

  final Connectivity _connectivity = Connectivity();

  // final WifiInfo _wifiInfo = WifiInfo();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late Timer _timer;

  late Timer _batteryCheckTimer;

  late GlobalState _globalState;
  late CameraState _cameraState;

  PageController pageController = PageController();

  late BuildContext _context;

  late native_lib.NativeLibrary nativeLib;
  // late native_lib.StitchLibrary stitchLib;

  void onError(error, StackTrace trace) {
    switchConnect(false, msg: '???????????????');
  }

  /// ??????????????????
  void onCameraStatus(jsonData) {
    debugPrint(jsonData.toString());
    final map = parseData(jsonData);
    if (map != null) {
      final notifyStatusEntity = NotifyStatusEntity().fromJson(map);
      switch (notifyStatusEntity.function?.status) {
        case 0:
          // showToast('????????????');
          break;
        case 1:
          showToast('????????????');
          break;
        case 2:
          showToast('???????????????');
          break;
        case 3:
          showToast('????????????Wi-Fi??????');
          break;
        case 4:
          showToast('??????????????????');
          break;
        case 5:
          showToast('??????????????????');
          break;
        case 6:
          showToast('??????????????????');
          break;
        case 7:
          showToast('????????????????????????????????????????????????');
          break;
        case -1:
          showToast('????????????');
          break;
        case -2:
          showToast('??????EXIF??????');
          break;
        case -3:
          showToast('???????????????');
          break;
        case -4:
          showToast('???????????????');
          break;
        case -5:
          showToast('??????????????????');
          break;
        case -6:
          showToast('????????????');
          break;
        case -7:
          showToast('????????????????????????');
          break;
        case -8:
          showToast('?????????????????????????????????');
          break;
        case -9:
          showToast('Slow card while recording');
          break;
        case -10:
          showToast('????????????');
          break;
        case -11:
          showToast('??????????????????');
          break;
        case -12:
          showToast('???????????????');
          break;
        case -13:
          showToast('????????????');
          break;
        case -14:
          showToast('??????????????????');
          break;
        case -15:
          showToast('????????????????????????');
          break;
        case -16:
          showToast('????????????NAND??????');
          break;
        case -17:
          showToast('????????????????????????');
          break;
        case -18:
          showToast('??????????????????????????????');
          break;
        case -19:
          showToast('??????????????????');
          break;
        case -20:
          showToast('?????????????????????????????????');
          break;
        case -21:
          showToast('??????????????????');
          break;
        case -256:
          showToast('?????????????????????');
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nativeLib = native_lib.NativeLibrary();
    // stitchLib = native_lib.StitchLibrary();

    initVlcPlayer();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initConnectivity();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        /// NOTE: 4/9/21 ????????? ??????IOS??????Wi-Fi?????????????????????????????????????????????
        if (!kIsWeb && !_globalState.isCapture && mounted) {
          _updateConnectionStatus(ConnectivityResult.none);
        }
      });

      /// ?????????????????????????????????????????????????????????60s??????????????????
      _batteryCheckTimer = Timer.periodic(Duration(seconds: 60), (timer) {
        if (_globalState.isConnect && !_globalState.isCapture && mounted) {
          _cameraState.batteryLevelCheck();
        }
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await _connectivitySubscription.cancel();
    _timer.cancel();
    _batteryCheckTimer.cancel();
    SocketUtils().dispose();

    await GlobalStore.videoPlayerController?.stopRendererScanning();
    await GlobalStore.videoPlayerController?.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    /// ?????????????????????????????????????????????
    if (ConnectivityResult.wifi == result ||
        ConnectivityResult.none == result) {
      if (GlobalStore.startHeartbeat) {
        GlobalStore.startHeartbeat = false;
        await DioUtils.instance.requestNetwork<HearbeatEntity>(
            Method.get, HttpApi.heartbeat, onSuccess: (data) async {
          if (data?.function?.status == '0') {
            if (!_globalState.isConnect) {
              /// ??????????????????
              if (await _updateFW()) {
                /// ???????????????????????????????????????????????????????????????????????????????????????
                Timer.periodic(Duration(seconds: 5), (timer) async {
                  /// NOTE: 4/9/21 ????????? ??????IOS??????Wi-Fi?????????????????????????????????????????????
                  if (!kIsWeb && !_globalState.isCapture && mounted) {
                    await DioUtils.instance.requestNetwork<HearbeatEntity>(
                        Method.get, HttpApi.heartbeat,
                        onError: (int? code, String? msg) {
                      print('??????????????????');
                      GlobalStore.startHeartbeat = true;
                      timer.cancel();
                    });
                  }
                });
                return;
              }

              /// NOTE: 2021/7/13 ????????? ??????????????????????????????????????????SSID????????????
              /// ?????????Maps
              await _initMapFiles(onDeon: () {
                _globalState.initType = InitType.init;
                _globalState.isConnect = true;

                /// NOTE: 4/21/21 ????????? ??????????????????????????????????????????????????????????????????
                showCupertinoLoading(_context);

                /// NOTE: 4/22/21 ????????? ??????Socket ???????????????
                SocketUtils()
                    .initSocket(host: '192.168.1.254', port: 3333)
                    .then((value) {
                  /// ??????????????????
                  SocketUtils().listen(
                    onCameraStatus,
                    onError,
                  );
                });

                /// NOTE: 4/21/21 ????????? ????????????????????????????????????????????????wifiAppModePlayback????????????wifiAppModePhoto
                DioUtils.instance.asyncRequestNetwork<WifiAppModeEntity>(
                    Method.get,
                    HttpApi.appModeChange +
                        WifiAppMode.wifiAppModePhoto.index.toString(),
                    onSuccess: (modeEntity) {
                  GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePhoto;

                  /// NOTE: 4/22/21 ????????? ????????????????????????????????????????????????????????????
                  initVlcPlayer();
                  _cameraState.isShowVLCPlayer = true;

                  /// ????????????
                  _cameraState.diskSpaceCheck();

                  /// NOTE: 4/21/21 ??????????????????
                  final now = DateTime.now();
                  DioUtils.instance.asyncRequestNetwork<CmdStatusEntity>(
                      Method.get,
                      '${HttpApi.setDate}${now.year}-${now.month}-${now.day}',
                      onSuccess: (dateCmdStatus) {
                    if (dateCmdStatus?.function?.status != 0) {
                      NavigatorUtils.goBack(_context);
                      showToast('?????????????????????');
                    }
                  }, onError: (code, msg) {
                    NavigatorUtils.goBack(_context);
                    showToast('???????????????????????????');
                  });

                  /// NOTE: 4/21/21 ??????????????????
                  DioUtils.instance.asyncRequestNetwork<CmdStatusEntity>(
                      Method.get,
                      '${HttpApi.setTime}${now.hour}:${now.minute}:${now.second}',
                      onSuccess: (timeCmdStatus) {
                    NavigatorUtils.goBack(_context);
                    if (timeCmdStatus?.function?.status != 0) {
                      showToast('?????????????????????');
                    }
                  }, onError: (code, msg) {
                    NavigatorUtils.goBack(_context);
                    showToast('???????????????????????????');
                  });
                }, onError: (code, msg) {
                  /// NOTE: 4/22/21 ????????????????????????????????????????????????????????????????????????????????????
                  _globalState.isConnect = true;
                  _cameraState.diskSpaceCheck();
                  NavigatorUtils.goBack(_context);
                  showToast('????????????????????????');
                  _cameraState.isShowVLCPlayer = false;
                });

                GlobalStore.startHeartbeat = true;
              });
            } else {
              GlobalStore.startHeartbeat = true;
            }
          } else {
            await switchConnect(false, msg: '??????????????????????????????Wi-Fi??????????????????');
            GlobalStore.startHeartbeat = true;
          }
        }, onError: (e, m) async {
          if (_globalState.isConnect) {
            /// TODO: 4/22/21 ????????? ???????????????
            await Future.delayed(Duration(seconds: 1), () async {
              await DioUtils.instance.requestNetwork<HearbeatEntity>(
                  Method.get, HttpApi.heartbeat, onError: (e, m) async {
                await switchConnect(false, msg: '??????????????????????????????');
              });
            });
          }
          GlobalStore.startHeartbeat = true;
        });
      }
    } else {
      /// NOTE: 2021/7/13 ????????? wifi??????????????????????????????????????????????????????????????????
      if (_globalState.isConnect) {
        await Future.delayed(Duration(seconds: 1), () async {
          await DioUtils.instance.requestNetwork<HearbeatEntity>(
              Method.get, HttpApi.heartbeat, onError: (e, m) async {
            await switchConnect(false, msg: 'wifi????????????');
          });
        });
      } else {
        await switchConnect(false, msg: 'wifi????????????');
      }
    }
  }

  Future<void> _initMapFiles({required Function() onDeon}) async {
    _globalState.initType = InitType.checkMaps;

    /// NOTE: 2021/7/13 ????????? ??????????????????????????????????????????SSID????????????
    return DioUtils.instance.requestNetwork<SsidPassEntity>(
        Method.get, HttpApi.getSSIDAndPassphrase, onSuccess: (ssidPassEntity) {
      if (_globalState.currentSSID != ssidPassEntity?.xLIST?.sSID) {
        _globalState.currentSSID = ssidPassEntity?.xLIST?.sSID ?? 'xCam_one';
      }

      final savePath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/';
      final saveZipPath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/Maps.zip';
      if (!File('${savePath}Maps/maps_size').existsSync()) {
        _globalState.initType = InitType.downMaps;
        final url = '${GlobalStore.config[EConfig.baseUrl]}Maps.zip';
        final Dio dio = Dio();
        dio
            .download(url, '$saveZipPath',
                onReceiveProgress: true
                    ? null
                    : (received, total) {
                        if (total != -1) {
                          ///???????????????????????????
                          print((received / total * 100).toStringAsFixed(0) +
                              '%');
                        }
                      })
            .then((value) {
          _globalState.initType = InitType.zipDecoderMaps;
          final file = File('$saveZipPath');
          final fileBytes = file.readAsBytesSync();
          final archive = ZipDecoder().decodeBytes(fileBytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('$savePath' + filename)
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('$savePath' + filename).createSync(recursive: true);
            }
          }
          onDeon();
        });
      } else {
        onDeon();
      }
    });
  }

  /// ????????????????????????????????????
  Future<bool> _updateFW() async {
    /// NOTE: 2021/8/1 ????????? ???????????????????????????????????????false
    bool retValue = true;

    /// 1.??????????????????
    await DioUtils.instance
        .requestNetwork<VersionEntity>(Method.get, HttpApi.queryVersion,
            onSuccess: (VersionEntity? value) async {
      if (value?.function?.status == 0) {
        final String version = value!.function!.version!;
        // ??????????????? xCam_0729_005
        final List<String> versionValues = version.split(r'_');
        final List<String> myVersionValue = Constant.FWString.split(r'_');
        if (versionValues[0] != myVersionValue[0]) {
          showToast('??????????????????????????????????????????');
        } else {
          // ??????????????????????????????
          final int date = int.parse(versionValues[1]);
          final int myDate = int.parse(myVersionValue[1]);
          bool isUpdate = false;
          if (myDate > date) {
            isUpdate = true;
          } else if (date == myDate) {
            final int versionNum = int.parse(versionValues[2]);
            final int myVersionNum = int.parse(myVersionValue[2]);
            if (myVersionNum > versionNum) {
              isUpdate = true;
            }
          }

          if (isUpdate) {
            _globalState.initType = InitType.updateFW;

            /// 2.????????????
            final Map<String, dynamic> map = {};

            final Dio dio = Dio();

            final ByteData byteData =
                await rootBundle.load('assets/FW/FW96660A.bin');

            map['file'] = MultipartFile.fromBytes(byteData.buffer.asUint8List(),
                filename: 'FW96660A.bin');

            ///??????FormData
            final FormData formData = FormData.fromMap(map);

            // netUploadUrl
            await dio.post(
              'http://192.168.1.254',
              data: formData,
              // onSendProgress: (int progress, int total) {
              //   print('??????????????? $progress ???????????? $total');
              // },
            );

            /// 3.????????????
            await DioUtils.instance.requestNetwork<CmdStatusEntity>(
                Method.get, HttpApi.firmwareUpdate,
                onSuccess: (CmdStatusEntity? statusEntity) {
              if (statusEntity?.function?.status != 0) {
                showToast('??????????????????');
              } else {
                showToast('??????????????????');
              }
            });
            _globalState.initType = InitType.reconnect;
          } else {
            retValue = false;
          }
        }
      }
    });

    return Future.value(retValue);
  }

  Future switchConnect(bool isConnect, {String? msg}) async {
    if (_globalState.isConnect != isConnect) {
      if (msg != null) showToast(msg);

      _globalState.isConnect = false;
      _globalState.initType = InitType.connect;
      _cameraState.clearSpaceData();
      try {
        final bool? isPlay =
            await GlobalStore.videoPlayerController?.isPlaying();
        if (isPlay ?? false) {
          await GlobalStore.videoPlayerController?.stop();
        }
      } catch (e) {
        e.toString();
      }

      // ??????socket
      SocketUtils().dispose();
      _cameraState.isShowVLCPlayer = false;
    }
  }

  @override
  void didUpdateWidget(IndexPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      try {
        /// ????????????????????????
        GlobalStore.videoPlayerController?.stop().then((value) {
          GlobalStore.videoPlayerController?.play();
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void initVlcPlayer() {
    GlobalStore.videoPlayerController = VlcPlayerController.network(
      HttpApi.streamingUrl,
      hwAcc: HwAcc.AUTO,
      autoPlay: true,
      autoInitialize: true,
      onInit: () async {
        await GlobalStore.videoPlayerController?.startRendererScanning();
        // await GlobalStore.videoPlayerController?.play();
      },
      options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.clockJitter(0),
            VlcAdvancedOptions.clockSynchronization(0),
            // VlcAdvancedOptions.fileCaching(0),
            VlcAdvancedOptions.networkCaching(2000),
            // VlcAdvancedOptions.liveCaching(0)
          ]),
          extras: [
            '--network-caching=3000',
            '--live-caching=3000',
            '--udp-caching=1000',
            '--tcp-caching=1000',
            '--realrtsp-caching=1000',
          ]
          // video: VlcVideoOptions([
          //   VlcVideoOptions.dropLateFrames(true),
          //   VlcVideoOptions.skipFrames(true)
          // ]),
          ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    _globalState = context.read<GlobalState>();
    _cameraState = context.read<CameraState>();

    _context = context;
    final watchGlobalState = context.watch<GlobalState>();
    final watchPhotoState = context.watch<PhotoState>();

    return Scaffold(
      /// NOTE: 4/19/21 ????????? ?????????????????????????????????????????????bar???????????????
      backgroundColor: watchGlobalState.isConnect && _currentIndex == 1
          ? Colors.black
          : Colors.white,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        controller: pageController,
        children: _pages,
      ),
      bottomNavigationBar: watchPhotoState.isMultipleSelect
          ? null
          : BottomNavigationBar(
              backgroundColor: watchGlobalState.isConnect && _currentIndex == 1
                  ? Colors.black
                  : Colors.white,
              items: watchGlobalState.isConnect && _currentIndex == 1
                  ? watchGlobalState.isCapture
                      ? disableCameraBottomNavItems
                      : cameraBottomNavItems
                  : bottomNavItems,
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (index) => _changePage(index),
            ),
    );
  }

  void _changePage(int index) {
    if (_globalState.isCapture) {
      showToast('?????????????????????');
      return;
    }

    if (index != _currentIndex) {
      /// TODO: 4/17/21 ?????????????????????????????????????????????????????????????????????
      if (index == 1 && _globalState.isConnect) {
        /// ??????????????????????????????
        _cameraState.batteryLevelCheck();

        /// NOTE: 4/21/21 ????????? ?????????????????????????????????????????????????????????,????????????????????????????????????????????????????????????
        _cameraState.diskSpaceCheck();

        if (GlobalStore.wifiAppMode != WifiAppMode.wifiAppModePhoto) {
          /// ???????????????????????????????????????
          DioUtils.instance.requestNetwork<WifiAppModeEntity>(
              Method.get,
              HttpApi.appModeChange +
                  WifiAppMode.wifiAppModePhoto.index.toString(),
              onSuccess: (modeEntity) {
            GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePhoto;

            /// ?????????????????????
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          }, onError: (code, msg) {
            // GlobalStore.videoPlayerController?.stop();
            /// TODO: 4/16/21 ????????? ?????????????????????????????????????????????????????????????????????????????????????????????
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          });
        } else {
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }

      pageController.jumpToPage(index);
      // 1 ??????????????????????????????????????????????????????
    } else if (index == 1 && _globalState.isConnect) {
      try {
        /// NOTE: 4/21/21 ????????? ??????????????????????????????????????????
        GlobalStore.videoPlayerController?.isPlaying().then((isPlaying) {
          if (isPlaying != null && !isPlaying) {
            showToast('?????????????????????????????????????????????');
          } else {
            // globalState.batteryStatus == BatteryStatus.batteryLow
            // if (cameraState.batteryStatus == BatteryStatus.batteryEmpty ||
            //     cameraState.batteryStatus == BatteryStatus.batteryExhausted) {
            //   showToast('????????????????????????');
            // } else
            if (_cameraState.countdown != CountdownEnum.close) {
              showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return Center(
                      child: IgnorePointer(
                        child: Material(
                          color: Colors.transparent,
                          child: Center(
                            child: CircularCountDownTimer(
                              duration: _cameraState.countdown.value,
                              initialDuration: 0,
                              controller: CountDownController(),
                              width: 64,
                              height: 64,
                              ringColor: Colors.grey,
                              ringGradient: null,
                              fillColor: Theme.of(context).primaryColor,
                              fillGradient: null,
                              backgroundColor: Colors.black45,
                              backgroundGradient: null,
                              strokeWidth: 20.0,
                              strokeCap: StrokeCap.round,
                              textStyle: TextStyle(
                                  fontSize: 33.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textFormat: CountdownTextFormat.S,
                              isReverse: false,
                              isReverseAnimation: false,
                              isTimerTextShown: true,
                              autoStart: true,
                              onStart: () {
                                print('Countdown Started');
                              },
                              onComplete: () {
                                NavigatorUtils.goBack(context);
                                _capture();
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              _capture();
            }
          }
        });
      } catch (e) {
        showToast('??????????????????????????????????????????');
        e.toString();
      }
    }
  }

  void _capture() {
    // 1 ??????????????????????????????????????????????????????
    _cameraState.captureType = '?????????';
    _globalState.isCapture = true;
    GlobalStore.videoPlayerController?.stop().then((value) {
      DioUtils.instance.asyncRequestNetwork<CaptureEntity>(
        Method.get,
        HttpApi.capture,
        onSuccess: (data) {
          final status = data?.function?.status ?? '';
          switch (int.parse(status)) {
            case 0:
              _saveImage(data!.function!.file, () {
                _globalState.isCapture = false;
                try {
                  GlobalStore.videoPlayerController?.play();
                } catch (e) {
                  debugPrint(e.toString());
                }
              });
              return;
            case -5:
              showToast('???????????????????????????');
              break;
            case -11:
              showToast('?????????????????????????????????');
              break;
            case -12:
              showToast('?????????????????????????????????');
              break;
            default:
              showToast('????????????');
              break;
          }

          _globalState.isCapture = false;
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        onError: (code, msg) {
          _globalState.isCapture = false;
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      );
    });
  }

  Future<void> _saveImage(List<CaptureFunctionFile>? files, onDone) async {
    if (files != null) {
      final List<String> destFiles = [];
      final savePath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/';
      files.forEach((element) async {
        String filePath = element.fPATH ?? '';
        filePath = filePath.substring(3, filePath.length);
        filePath = filePath.replaceAll('\\', '/');
        final url = '${GlobalStore.config[EConfig.baseUrl]}$filePath';

        _cameraState.captureType = '?????????';
        final Dio dio = Dio();
        await dio
            .download(url, '$savePath${element.nAME}'
                /** onReceiveProgress: (received, total) {
              if (total != -1) {
              ///???????????????????????????
              print(element.nAME! +
              (received / total * 100).toStringAsFixed(0) +
              '%');
              }
              } **/
                )
            .then((value) async {
          destFiles.add('$savePath${element.nAME}');
          if (destFiles.length == 2) {
            _cameraState.captureType = '?????????';
            final mapPath =
                '${GlobalStore.applicationPath}/${_globalState.currentSSID}/Maps/';

            /// NOTE: 2021/8/1 ????????? AB?????????????????????????????????
            final bool isSwap = destFiles[1].toLowerCase().endsWith('a.jpg');

            /// 2.????????????
            final int result = nativeLib.fuse(
                isSwap
                    ? destFiles[1].toNativeUtf8().cast<ffi.Int8>()
                    : destFiles[0].toNativeUtf8().cast<ffi.Int8>(),
                isSwap
                    ? destFiles[0].toNativeUtf8().cast<ffi.Int8>()
                    : destFiles[1].toNativeUtf8().cast<ffi.Int8>(),
                mapPath.toNativeUtf8().cast<ffi.Int8>(),
                ('${mapPath}vignet.txt').toNativeUtf8().cast<ffi.Int8>(),
                ('${savePath}fuse.jpg').toNativeUtf8().cast<ffi.Int8>());
            print('????????????:$result');
            if (result != 1) {
              showToast('????????????');
              if (onDone != null) {
                onDone();
              }
            } else {
              /// 3.???????????????????????????
              destFiles[0].toLowerCase();

              final filename = element.nAME!
                  .replaceRange(element.nAME!.length - 5, null, '.jpg');

              final Map<String, dynamic> map = {};
              map['image'] = await MultipartFile.fromFile('${savePath}fuse.jpg',
                  filename: filename);

              ///??????FormData
              final FormData formData = FormData.fromMap(map);
              // netUploadUrl
              await dio.post(
                'http://192.168.1.254/NOVATEK/PHOTO/',
                data: formData,
                // onSendProgress: (int progress, int total) {
                //   print('??????????????? $progress ???????????? $total');
                // },
              );

              /// 4.?????????????????????
              await PhotoManager.editor
                  .saveImageWithPath('${savePath}fuse.jpg')
                  .then((asset) {
                if (asset != null) {
                  // showToast('????????????');
                  showToast('????????????,?????????????????????');
                } else {
                  showToast('????????????');
                }

                if (onDone != null) {
                  onDone();
                }
              });
            }
          }
        });
      });
    }
  }
}
