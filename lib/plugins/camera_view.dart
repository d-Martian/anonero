import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

typedef QRCallBack = Function(String text);

class CameraView extends StatefulWidget {
  final QRCallBack callBack;

  const CameraView({Key? key, required this.callBack}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static const platform = MethodChannel('anon_camera');
  static const eventChannel = EventChannel("anon_camera:events");
  int? id;
  bool? permissionGranted = null;
  double? width;
  double? height;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startCamera();
    });
  }

  void startCamera() async {
    bool? permission =
        await platform.invokeMethod<bool>("checkPermissionState");
    setState(() {
      permissionGranted = permission;
    });
    if (permission == true) {
      platform.invokeMethod<Map>("startCam");
    } else {
      platform.invokeMethod<Map>("requestPermission");
    }
    eventChannel.receiveBroadcastStream().listen((event) {
      if (event['id'] != null) {
        permissionGranted = true;
        setState(() {
          id = event["id"];
          width = event["width"];
          height = event["height"];
        });
      }
      if (event["result"] != null) {
        platform.invokeMethod<Map>("stopCam");
        widget.callBack(event["result"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (permissionGranted == false) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    "To capture QR code, allow ANON to access your camera",
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center),
              ),
              const Padding(padding: EdgeInsets.all(6)),
              TextButton(
                  onPressed: () {
                    platform.invokeMethod<Map>("requestPermission");
                  },
                  child: Text("Allow camera"))
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ClipRect(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: id != null
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        width: width!,
                        height: height!,
                        child: Texture(
                            textureId: id!,
                            filterQuality: FilterQuality.medium),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          CupertinoIcons.qrcode_viewfinder,
                          size: 68,
                        )
                      ],
                    ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.all(68),
          child: SvgPicture.asset("assets/scanner_frame.svg",
              color: Colors.white24),
        )
      ],
    );
  }

  @override
  void dispose() {
    platform.invokeMethod<Map>("stopCam");
    super.dispose();
  }
}
