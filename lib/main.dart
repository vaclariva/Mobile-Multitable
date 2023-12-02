import 'package:flutter/material.dart';
import 'package:flutter_upload/halaman1.dart';
import 'package:flutter_upload/halaman2.dart';
import 'package:flutter_upload/halaman3.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.yellow),
      title: "Flutter Multitable",
      home: const MyStatefulWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Updated length to 3 for three tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan CLARIVA MEYDIETA WIDAGDO'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.menu_book),
            ),
            Tab(
              icon: Icon(Icons.list),
            ),
            Tab(
              icon: Icon(Icons.photo),
            ),
          ],
        ),
      ),
     body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: Halaman1(),
          ),
          Center(
            child: Halaman2(),
          ),
          Center(
            child: Halaman3(),
          ),
        ],
      ),

    );
  }
}
