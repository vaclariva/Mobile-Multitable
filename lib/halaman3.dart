import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upload/sql_helper.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class Halaman3 extends StatefulWidget {
  const Halaman3({Key? key}) : super(key: key);

  @override
  _Halaman3State createState() => _Halaman3State();
}

class _Halaman3State extends State<Halaman3> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController gambarController = TextEditingController();

  List<Map<String, dynamic>> catatan = [];
  Map<String, dynamic>? catatanDihapus;

  void refreshCatatan3() async {
    final data = await SQLHelper.getCatatan3();
    setState(() {
      catatan = data;
    });
  }

  @override
  void initState() {
    refreshCatatan3();
    super.initState();
  }

  Future<void> _ambilGambar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        gambarController.text = pickedFile.path;
      });
    }
  }

  Future<void> tambahCatatan3(
      String judul, String deskripsi, String gambar) async {
    await SQLHelper.tambahCatatan3(judul, deskripsi, gambar);
    refreshCatatan3();
  }

  Future<void> hapusCatatan3(int id) async {
    catatanDihapus = catatan.firstWhere((item) => item['id'] == id);
    await SQLHelper.hapusCatatan3(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Berhasil Dihapus"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          if (catatanDihapus != null) {
            tambahCatatan3(catatanDihapus!['judul'],
                catatanDihapus!['deskripsi'], catatanDihapus!['gambar']);
            catatanDihapus = null;
          }
        },
      ),
    ));

    refreshCatatan3();
  }

  Future<void> ubahCatatan3(
      int id, String judul, String deskripsi, String gambar) async {
    await SQLHelper.ubahCatatan3(id, judul, deskripsi, gambar);
    refreshCatatan3();
  }

  void modalForm(int? id) async {
    if (id != null) {
      final dataCatatan = catatan.firstWhere((item) => item['id'] == id);

      judulController.text = dataCatatan['judul'];
      deskripsiController.text = dataCatatan['deskripsi'];
      gambarController.text = dataCatatan['gambar'];
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: 800,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(hintText: "Masukkan Judul"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(hintText: "Masukkan Deskripsi"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: gambarController,
                decoration: const InputDecoration(hintText: "Path Gambar"),
              ),
              ElevatedButton(
                onPressed: _ambilGambar,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16), // Atur padding horizontal
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text("Pilih Gambar"),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
               ElevatedButton(
                onPressed: () async {
                  if (judulController.text.isEmpty ||
                      deskripsiController.text.isEmpty ||
                      gambarController.text.isEmpty) {
                    // Tampilkan alert bahwa form masih kosong
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Form Kosong"),
                        content: Text("Pastikan semua form diisi sebelum menambahkan catatan."),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (id == null) {
                      await tambahCatatan3(
                        judulController.text,
                        deskripsiController.text,
                        gambarController.text,
                      );
                      print("Tambah");
                    } else {
                      print("Update");
                      await ubahCatatan3(
                        id,
                        judulController.text,
                        deskripsiController.text,
                        gambarController.text,
                      );
                    }
                    judulController.text = '';
                    deskripsiController.text = '';
                    gambarController.text = '';
                    Navigator.pop(context);
                    refreshCatatan3();
                  }
                },
                child: Text(id == null ? 'Tambah Catatan' : 'Ubah'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deskripsi Foto"),
      ),
      body: ListView.builder(
        itemCount: catatan.length,
        itemBuilder: (context, index) => Card(
          shape: RoundedRectangleBorder(
            //side: BorderSide(color: Colors.brown, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(
                  File(catatan[index]['gambar']),
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catatan[index]['judul'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(catatan[index]['deskripsi']),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: IconButton(
                              onPressed: () => modalForm(catatan[index]['id']),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 255, 59, 59),
                            child: IconButton(
                              onPressed: () {
                                hapusCatatan3(catatan[index]['id']);
                              },
                              icon: Icon(Icons.delete,
                                  color: Color.fromARGB(255, 27, 27, 27)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalForm(null);
        },
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
