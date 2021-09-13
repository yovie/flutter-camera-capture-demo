import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {

    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

    final firstCamera = cameras.first;
       
    runApp(MyApp(
        camera: firstCamera
    ));
}

class MyApp extends StatelessWidget {
    MyApp({Key? key, required this.camera}) : super(key:key);
  
    final CameraDescription camera;

    @override
    Widget build(BuildContext context) { 
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: MyHomePage(
                title: 'Flutter Demo Home Page',
                camera: this.camera
            ),
        );
    }
}

class MyHomePage extends StatefulWidget {
    MyHomePage({Key? key, required this.title, required this.camera}) : super(key: key);

    final String title;

    final CameraDescription camera;

    @override 
    _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    int _counter = 0;
    late CameraController _controller;
    late Future<void> _initializeControllerFuture;

    void _incrementCounter() {
        setState(() {
            _counter++;
        });
    }

    void _capture(BuildContext context) async {
        try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                        imagePath: image.path
                    )
                )
            );
        } catch (e) {
            print(e);
        }
    }

    @override
    void initState() {
        super.initState();
        _controller = CameraController (
            widget.camera,
            ResolutionPreset.medium
        );
        _initializeControllerFuture = _controller.initialize();
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    Widget buildCameraPreview(CameraController cameraController) {
        final double previewAspectRatio = 0.7;
        return AspectRatio(
            aspectRatio: 1 / previewAspectRatio,
            child: ClipRect(
                child: Transform.scale(
                    scale: cameraController.value.aspectRatio / previewAspectRatio,
                    child: Center(
                        child: CameraPreview(cameraController),
                    ),
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
            ),
            body: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                        // return CameraPreview(_controller);
                        return buildCameraPreview(_controller);
                    } else {
                        return const Center(child: CircularProgressIndicator());
                    }
                }
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    _capture(context);
                },
                tooltip: 'Capture',
                child: Icon(Icons.camera),
            ),
        );
    }
}

class DisplayPictureScreen extends StatelessWidget {
    final String imagePath; 

    const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Display the picture')),
            body: Image.file(File(imagePath))
        );
    }
}