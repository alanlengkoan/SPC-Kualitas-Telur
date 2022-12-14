import 'dart:io';

import 'package:egg_detection/pages/konsultasi/result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddKonsultasi extends StatefulWidget {
  const AddKonsultasi({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AddKonsultasi> createState() => _AddKonsultasiState();
}

class _AddKonsultasiState extends State<AddKonsultasi> {
  final _formKey = GlobalKey<FormState>();

  var urlPost = Uri.parse("http://192.168.1.5/skripsi/spc/SPC-Kualitas-Telur/web/api/konsultasi/save");
  var picker = ImagePicker();
  var data = {};
  var _imageUpload;
  final listOutputs = [];
  var _validasiImageUpload = const Text('Belum ada gambar yang diambil!');
  var tfResponse;
  var _label;
  var _confidence;

  bool _klik = true;

  // untuk load model
  Future loadModel() async {
    try {
      tfResponse = await Tflite.loadModel(
        model: 'assets/tflite/model_unquant.tflite',
        labels: 'assets/tflite/labels.txt',
      );
      print('Berhasil load model: $tfResponse');
    } catch (e) {
      print('Gagal load model: $e');
    }
  }

  TextEditingController controllerNama = TextEditingController();

  String? _validasiNama(String? value) {
    if (value!.isEmpty) {
      return 'Nama Pelapor, Wajib diisi!';
    }
    return null;
  }

  // untuk upload atau ambil gambar
  void _uploadOrTakeImage(ImageSource imageSource) async {
    var imageUpload = await picker.pickImage(source: imageSource);

    setState(() {
      _imageUpload = File(imageUpload!.path);
      _validasiImageUpload = const Text('');
    });

    processImage(_imageUpload);
  }

  // untuk memproses gambar
  void processImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      listOutputs.clear();
      listOutputs.addAll(output!);

      _label = listOutputs[0]['label'].toString().replaceAll(RegExp(r'[0-9]'), '').toUpperCase();
      _confidence = listOutputs[0]['confidence'].toStringAsFixed(2);
    });
  }

  void addData() {
    String nameImage = _imageUpload!.path.split("/").last;
    String imageLoc = base64Encode(_imageUpload!.readAsBytesSync());

    data = {
      "nama": controllerNama.text,
      "image": nameImage,
      "loc_image": imageLoc,
    };

    http.post(urlPost, body: data).then((response) {
      var tampilkan = json.decode(response.body);

      if (tampilkan['status']) {
        Alert(
          context: context,
          type: AlertType.success,
          title: tampilkan['title'],
          desc: tampilkan['text'],
          buttons: [
            DialogButton(
              child: Text(
                tampilkan['button'],
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultKonsultasi(
                      title: "Hasil Konsultasi",
                      id: tampilkan['id'],
                    ),
                  ),
                  (route) => false,
                );
              },
              width: 120,
            )
          ],
        ).show();
      } else {
        Alert(
          context: context,
          type: AlertType.error,
          title: tampilkan['title'],
          desc: tampilkan['text'],
          buttons: [
            DialogButton(
              child: Text(
                tampilkan['button'],
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              width: 120,
            )
          ],
        ).show();
      }

      setState(() {
        _klik = true;
      });
    });
  }

  void _validasiInput() {
    if (_formKey.currentState!.validate() && _imageUpload != null) {
      _formKey.currentState!.save();
      addData();
      setState(() {
        _klik = false;
      });
    } else {
      setState(() {
        _validasiImageUpload = const Text('Belum ada gambar yang diambil!', style: TextStyle(color: Colors.red));
      });
    }
  }

  @override
  void initState() {
    loadModel().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _form() {
      return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: _validasiNama,
                      controller: controllerNama,
                      decoration: const InputDecoration(
                        labelText: 'Nama *',
                        hintText: 'Masukkan nama Anda',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                  ),
                                  onPressed: () => _uploadOrTakeImage(ImageSource.gallery),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const <Widget>[Text("Upload Gambar", style: TextStyle(color: Colors.white))],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  onPressed: () => _uploadOrTakeImage(ImageSource.camera),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const <Widget>[Text("Ambil Gambar", style: TextStyle(color: Colors.white))],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          listOutputs.isEmpty
                              ? Text('Silahkan upload atau ambil gambar terlebih dahulu!')
                              : Container(
                                  child: Column(
                                  children: [
                                    Text(_label),
                                    Text(_confidence),
                                  ],
                                )),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            decoration: const BoxDecoration(color: Colors.grey),
                            child: _imageUpload != null
                                ? Image.file(
                                    _imageUpload,
                                    fit: BoxFit.fitHeight,
                                  )
                                : Container(
                                    decoration: const BoxDecoration(color: Colors.grey),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                          ),
                          Container(
                            child: _imageUpload == null ? _validasiImageUpload : _validasiImageUpload,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      );
    }

    _loading() {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1C6758),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _validasiInput,
              child: const Icon(
                Icons.check,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: _klik != false ? _form() : _loading(),
      ),
    );
  }
}
