/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

import 'package:xcam_one/notifiers/camera_state.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraConnectPage extends StatefulWidget {
  const CameraConnectPage({
    Key? key,
  }) : super(key: key);

  @override
  _CameraConnectPageState createState() => _CameraConnectPageState();
}

class _CameraConnectPageState extends State<CameraConnectPage>
    with AutomaticKeepAliveClientMixin {
  late GlobalState _watchGlobalState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _watchGlobalState = context.watch<GlobalState>();

    final size = MediaQuery.of(context).size;
    final imageHeight = 283 * size.width / 375;
    return Scaffold(
      appBar: AppBar(
        title: Text('连接相机'),
        centerTitle: true,
      ),
      body: _buildConnect(context, size, imageHeight),
    );
  }

  Widget _buildConnect(BuildContext context, Size size, double imageHeight) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size.width,
            height: imageHeight,
            child: FadeInImage(
              image: AssetImage('assets/images/main_wifi.png'),
              placeholder: MemoryImage(kTransparentImage),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 31),
            child: Text(
              'Wi-Fi密码：12345678',
              style: TextStyles.textBold18.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '相机开机后，在手机Wi-Fi列表中点击“xCam”开头的相机WiFi进行连接，默认密码：12345678',
              style: TextStyles.textSize12,
              textAlign: TextAlign.center,
            ),
          ),
          MyButton(
            minWidth: 248,
            onPressed: (_watchGlobalState.initType == InitType.connect ||
                    _watchGlobalState.initType == InitType.reconnect)
                ? () {
                    AppSettings.openWIFISettings();
                  }
                : null,
            buttonText: _watchGlobalState.initType.value,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
