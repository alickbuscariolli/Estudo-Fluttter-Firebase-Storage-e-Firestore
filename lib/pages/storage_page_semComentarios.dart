import 'dart:io';

import 'package:exemplo54/pages/firebase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  final Stream<QuerySnapshot> cadastro =
      FirebaseFirestore.instance.collection('cadastro').snapshots();

  List<Reference> refs = [];

  List<String> arquivos = [];

  bool loading = true;

  bool uploading = false;

  double total = 0;

  String link = '';

  TextEditingController nome = TextEditingController();

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();

    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    return image;
  }

  Future<UploadTask> upload(String path) async {
    File file = File(path);

    try {
      String ref = 'images/img-${DateTime.now().toString()}.jpg';

      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  pickAndUploadImage() async {
    XFile? file = await getImage();

    if (file != null) {
      UploadTask task = await upload(file.path);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;

            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        } else if (snapshot.state == TaskState.success) {
          arquivos.add(await snapshot.ref.getDownloadURL());

          refs.add(snapshot.ref);

          link = arquivos.last.toString();

          Fb(link, nome.text).addCadastro(link, nome.text);

          setState(() => uploading = false);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    loadImages();
  }

  loadImages() async {
    refs = (await storage.ref('images').listAll()).items;

    for (var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }

    setState(() => loading = false);
  }

  deleteImage(int index) async {
    await storage.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: uploading
            ? Text('${total.round()}% enviado')
            : const Text('Firebase Storage'),
        actions: [
          uploading
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: pickAndUploadImage,
                )
        ],
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: arquivos.isEmpty
                  ? Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration:
                              InputDecoration(labelText: 'digite o seu nome'),
                          textAlign: TextAlign.center,
                          controller: nome,
                        ),
                        GestureDetector(
                          onTap: () {
                            pickAndUploadImage();

                            Fb(link, nome.text).addCadastro(link, nome.text);
                          },
                          child: Container(
                              height: 200,
                              width: 200,
                              color: Colors.orange,
                              child: Text('cadastrar')),
                        )
                      ],
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: cadastro,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("ops, erro");
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading");
                        }

                        return ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            return Material(
                              child: Column(
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        labelText: 'digite o seu nome'),
                                    textAlign: TextAlign.center,
                                    controller: nome,
                                  ),
                                  Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.blue,
                                      child:
                                          Image.network(data['link_imagem'])),
                                  Container(
                                    height: 200,
                                    width: 200,
                                    color: Colors.green,
                                    child: Text(data['nome_pessoa']),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      pickAndUploadImage();
                                      Fb(link, nome.text)
                                          .addCadastro(link, nome.text);
                                    },
                                    child: Container(
                                        height: 200,
                                        width: 200,
                                        color: Colors.orange,
                                        child: Text('cadastrar')),
                                  )
                                ],
                              ),
                              //),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
    );
  }
}
