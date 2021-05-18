/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

class HttpApi {
  /// 心跳检测,返回成功即可
  static const String heartbeat = '?custom=1&cmd=3016';

  /// 检测固件版本 WIFIAPP_CMD_VERSION
  static const String queryVersion = '?custom=1&cmd=3012';

  /// 获取电量
  static const String getBatteryLevel = '?custom=1&cmd=3019';

  /// 拍照
  static const String capture = '?custom=1&cmd=1001';

  /// 可拍摄张数
  static const String freeCaptureNum = '?custom=1&cmd=1003';

  /// 查询当前状态
  static const String queryCurrentStatus = '?custom=1&cmd=3014';

  /// 更改模式 /// NOTE: 4/7/21 待注意 模式不匹配会导致拍摄异常
  static const String appModeChange = '?custom=1&cmd=3001&par=';

  /// RSTP拉流 rtsp://192.168.1.254/xxxx.mov
  static const String rtsp = 'rtsp://192.168.1.254/xxxx.mov';

  /// HTTP MJPG streaming
  static const String streamingUrl = 'http://192.168.1.254:8192';

  /// 获取硬件容量
  static const String getHardwareCapacity = '?custom=1&cmd=3022';

  /// 获取存储空间
  static const String getDiskFreeSpace = '?custom=1&cmd=3017';

  /// 获取文件列表
  static const String getFileList = '?custom=1&cmd=3015';

  /// 获取相机照片缩略图 http://192.168.1.254/NOVATEK/PHOTO/20210402_144607A.JPG?custom=1&cmd=4001
  static const String getThumbnail = '?custom=1&cmd=4001';

  /// 获取显示手机显示图片 http://192.168.1.254/NOVATEK/PHOTO/20210402_144607A.JPG?custom=1&cmd=4002
  static const String getScreennail = '?custom=1&cmd=4002';

  /// 删除照片 Http://192.168.1.254/?custom=1&cmd=4003&str=A:\CARDV\PHOTO\2014_0506_000000.0001.JPG
  static const String deleteFile = '?custom=1&cmd=4003&str=';

  /// NOTE: 4/19/21 新增 WIFIAPP_CMD_DISK_SPACE  3039
  static const String getDiskSpace = '?custom=1&cmd=3039';

  /// NOTE: 4/20/21 格式化相册 0 代表闪存、1 代表SD卡，硬件工程师说只执行1
  static const String format = '?custom=1&cmd=3010&par=1';

  /// 重置相机设置 http://192.168.1.254/?custom=1&cmd=3011
  static const String systemReset = '?custom=1&cmd=3011';

  /// 开启HDR http://192.168.1.254/?custom=1&cmd=2004&par=0
  static const String setHDR = '?custom=1&cmd=2004&par=';

  /// 设置日期 http://192.168.1.254/?custom=1&cmd=3005&str=2014-03-21
  static const String setDate = '?custom=1&cmd=3005&str=';

  /// 设置时间 http://192.168.1.254/?custom=1&cmd=3006&str=17:10:30
  static const String setTime = '?custom=1&cmd=3006&str=';

  /// 控制自动关机关机【0、1MIN、2MIN、3MIN、5MIN、10MIN】
  static const String powerOff = '?custom=1&cmd=3007&par=';

  /// save menu info http://192.168.1.254/?custom=1&cmd=3021

  /// 获取IQ信息 #define WIFIAPP_CMD_GET_PHOTO_IQ_INFO       3040
  static const String getIQInfo = '?custom=1&cmd=3040';

}
