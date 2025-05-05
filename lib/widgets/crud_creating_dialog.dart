part of '../main.dart';

/// ไดอะล็อกสร้างรายการ CRUD
class CrudCreatingDialog extends StatefulWidget {
  const CrudCreatingDialog({super.key});

  @override
  State<StatefulWidget> createState() => CrudCreatingDialogState();
}

/// [State] ของ [CrudCreatingDialog]
class CrudCreatingDialogState extends State<CrudCreatingDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  bool canPop = true;
  String errorMessage = '';

  @override
  void initState() {
    controller = TextEditingController()..addListener(_onTextBoxChanged);
    focusNode = FocusNode();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.context?.mounted == true) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Consumer(
        builder: (context, ref, child) => AlertDialog(
          title: const Text('Create'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, focusNode: focusNode, enabled: canPop),
              Text(errorMessage, maxLines: 1, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: canPop ? () => Navigator.of(context).popUntil((route) => route.isFirst) : null,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: canPop ? () => _onCreateConfirmButtonPressed(ref.read(crudModelListProvider)) : null,
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateConfirmButtonPressed(CrudModelList list) async {
    if (mounted) {
      setState(() {
        canPop = false;
      });
    }

    try {
      final created = await list.create(controller.text);
      if (created.success && mounted) {
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

  void _onTextBoxChanged() {
    if (errorMessage.isNotEmpty && mounted) {
      setState(() {
        errorMessage = '';
      });
    }
  }
}
