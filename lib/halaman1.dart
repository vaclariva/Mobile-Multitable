import 'package:flutter/material.dart';
import 'package:flutter_upload/sql_helper.dart';

class Halaman1 extends StatefulWidget {
  const Halaman1({Key? key}) : super(key: key);

  @override
  _Halaman1State createState() => _Halaman1State();
}

class _Halaman1State extends State<Halaman1> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  List<Map<String, dynamic>> catatan = [];
  Map<String, dynamic>? catatanDihapus;

  @override
  void initState() {
    refreshNote();
    super.initState();
  }

  Future<void> refreshNote() async {
    final data = await SQLHelper.getNote();
    setState(() {
      catatan = data;
    });
  }

  Future<void> tambahNote(String judul, String deskripsi) async {
    await SQLHelper.tambahNote(judul, deskripsi);
    refreshNote();
  }

  Future<void> hapusNote(int id) async {
    catatanDihapus = catatan.firstWhere((item) => item['id'] == id);
    await SQLHelper.hapusNote(id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Berhasil Dihapus"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          if (catatanDihapus != null) {
            tambahNote(
              catatanDihapus!['judul'],
              catatanDihapus!['deskripsi'],
            );
            catatanDihapus = null;
          }
        },
      ),
    ));

    refreshNote();
  }

  Future<void> ubahNote(int id, String judul, String deskripsi) async {
    await SQLHelper.ubahNote(id, judul, deskripsi);
    refreshNote();
  }

  void modalForm(int? id) async {
    if (id != null) {
      final dataCatatan = catatan.firstWhere((item) => item['id'] == id);

      judulController.text = dataCatatan['judul'];
      deskripsiController.text = dataCatatan['deskripsi'];
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
                decoration:
                    const InputDecoration(hintText: "Masukkan Deskripsi"),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (judulController.text.isEmpty ||
                      deskripsiController.text.isEmpty) {
                    // Tampilkan alert bahwa form masih kosong
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Form Kosong"),
                        content: Text(
                            "Pastikan semua form diisi sebelum menambahkan catatan."),
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
                      await tambahNote(
                          judulController.text, deskripsiController.text);
                      print("Tambah");
                    } else {
                      print("Update");
                      await ubahNote(
                          id, judulController.text, deskripsiController.text);
                    }
                    judulController.text = '';
                    deskripsiController.text = '';
                    Navigator.pop(context);
                    refreshNote();
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
        title: const Text("List Catatan"),
      ),
      body: ListView.builder(
        itemCount: catatan.length,
        itemBuilder: (context, index) => Card(
          shape: RoundedRectangleBorder(
            //side: BorderSide(color: Color.fromARGB(255, 241, 226, 15), width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                hapusNote(catatan[index]['id']);
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
