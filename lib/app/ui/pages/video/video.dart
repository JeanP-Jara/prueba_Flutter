
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class VideoCam extends StatefulWidget {
  const VideoCam({Key? key}) : super(key: key);

  @override
  State<VideoCam> createState() => _VideoCamState();
}

class _VideoCamState extends State<VideoCam> {
  List <CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex=0;
  bool _isRecording = false;
  String _filePath='';


  @override
  void initState(){
    super.initState();
    availableCameras().then((cameras) {
      _cameraIndex = 0;
      _cameras = cameras;
      _initCamera(_cameras[_cameraIndex]);
    });
  }

  _initCamera(CameraDescription camera) async {
    if(_controller != null){
      await _controller!.dispose();
    }
    _controller = CameraController(camera, ResolutionPreset.medium);
    _controller!.addListener(() => setState(() {}));
    _controller!.initialize();
  }

  Widget _buildCamera(){
    if(_controller == null || !_controller!.value.isInitialized){
      return const Center(child: Text('loading'),);
    }
    return AspectRatio(aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!)
    );
  }

  Widget _builderControls(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: _onSwitchCamera,
          icon: Icon(_getCameraIcon(_cameras[_cameraIndex].lensDirection))
        ),
        IconButton(
          onPressed: _isRecording ? null : _onRecord, 
          icon: const Icon(Icons.radio_button_checked)
        ),
        IconButton(
          onPressed: _isRecording ? _onStop : null, 
          icon: const Icon(Icons.stop)
        ),
        IconButton(
          onPressed: _isRecording ? null : _onPlay, 
          icon: const Icon(Icons.play_arrow)
        )
      ],
    );
  }

  void _onPlay(){
    print(_filePath);
    OpenFile.open(_filePath);
  }

  void _onStop() async{
    await _controller!.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });
  }

  void _onRecord() async {
    var directiry = await getTemporaryDirectory();
    _filePath = directiry.path + '/${DateTime.now()}.mp4';
    print("asdddddddddd"+_filePath);
    _controller!.startVideoRecording();
    setState(() {
      _isRecording = true;
    });
  }

  IconData _getCameraIcon(CameraLensDirection lensDirection){
    if(lensDirection == CameraLensDirection.back){
      return Icons.camera_front;
    }else{
      return Icons.camera_rear;
    }
  }

  void _onSwitchCamera(){
    if(_cameras.length < 2 ) return;
    _cameraIndex = (_cameraIndex+1)%2;
    print(_cameraIndex);
    _initCamera(_cameras[_cameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: 500, child: Center(child: _buildCamera()),),
          _builderControls(),
        ],
      ),
    );
  }
}