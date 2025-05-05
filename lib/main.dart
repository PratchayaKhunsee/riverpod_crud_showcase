import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/crud_model.dart';

part 'widgets/crud_creating_floating_button.dart';
part 'widgets/crud_creating_dialog.dart';
part 'widgets/crud_updating_dialog.dart';
part 'widgets/crud_deleting_dialog.dart';
part 'widgets/crud_model_list_view.dart';

void main() {
  runApp(const ProviderScope(child: MyCrudApp()));
}

/// โมเดลหลักสำหรับจัดการข้อมูล CRUD
final crudModelListProvider = ChangeNotifierProvider<CrudModelList<String>>((ref) => CrudModelList<String>());

/// โครงสร้างบนสุดของแอปพลิเคชัน
class MyCrudApp extends StatelessWidget {
  const MyCrudApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod CRUD Showcase',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const MyCrudMainPage(title: 'Riverpod CRUD Showcase'),
    );
  }
}

/// หน้าหลัก
class MyCrudMainPage extends StatefulWidget {
  const MyCrudMainPage({super.key, required this.title});

  final String title;

  @override
  State<MyCrudMainPage> createState() => MyCrudMainPageState();
}

/// [State] ของ [MyCrudMainPage]
class MyCrudMainPageState extends State<MyCrudMainPage> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const CrudModelListView(),
      floatingActionButton: const CrudCreatingFloatingButton(),
    );
  }
}
