part of '../main.dart';

/// ปุ่มสร้างรายการ CRUD
class CrudCreatingFloatingButton extends StatelessWidget {
  const CrudCreatingFloatingButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(context: context, barrierDismissible: false, builder: (context) => const CrudCreatingDialog());
      },
      child: const Icon(Icons.add),
    );
  }
}
