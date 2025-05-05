part of '../main.dart';

/// ไดอะล็อกแก้ไขรายการ CRUD
class CrudDeletingDialog extends StatefulWidget {
  final int index;
  final void Function()? onDelete;
  const CrudDeletingDialog({super.key, required this.index, this.onDelete});

  @override
  State<StatefulWidget> createState() => CrudDeletingDialogState();
}

/// [State] ของ [CrudDeletingDialog]
class CrudDeletingDialogState extends State<CrudDeletingDialog> {
  bool canPop = true;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Consumer(
        builder: (context, ref, child) => AlertDialog(
          title: const Text('Delete?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure to delete this item?'),
              Text(errorMessage, maxLines: 1, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: canPop ? () => Navigator.of(context).popUntil((route) => route.isFirst) : null,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: canPop ? () => _onDeleteConfirmButtonPressed(ref.read(crudModelListProvider)) : null,
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _onDeleteConfirmButtonPressed(CrudModelList list) async {
    if (mounted) {
      setState(() {
        canPop = false;
      });
    }

    try {
      final deleted = await list.delete(widget.index);

      if (deleted.success) {
        widget.onDelete?.call();
      }

      if (deleted.success && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        setState(() {
          errorMessage = 'Error, try again';
          canPop = true;
        });
      }
    } on CrudSubmissionErrorResponseException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message;
          canPop = true;
        });
      }
    }
  }
}
