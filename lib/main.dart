import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  List _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void classifyImage() async {
    var output = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = output;
    });
  }

  void chooseImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classifyImage();
  }

  void cameraRoll() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classifyImage();
  }

  void reset() {
    setState(() {
      _image = null;
      _output = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[850],
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Kucing ⚔︎ Anjing',
                  style: TextStyle(
                    color: Color(0xFFFFC324),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Image Classification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w100,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _image != null
                        ? Image.file(
                            _image,
                            width: 250,
                          )
                        : Image.asset(
                            'assets/logo.png',
                            width: 250,
                          ),
                  ),
                ),
                if (_output != null)
                  Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${_output[0]["label"]} (${_output[0]["confidence"]})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Color(0xFFFFC324),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: chooseImage,
                        child: Text(
                          'Pilih dari Galeri',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.grey[350],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: cameraRoll,
                        child: Text(
                          'Ambil Foto',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.grey[800],
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: reset,
                        child: Text(
                          'RESET',
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
