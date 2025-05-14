part of '../main.dart';

/// ไดอะล็อกแก้ไขรายการ CRUD
class CrudUpdatingDialog extends ConsumerStatefulWidget {
  final int index;
  final void Function()? onUpdate;
  const CrudUpdatingDialog({super.key, required this.index, this.onUpdate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CrudUpdatingDialogState();
}

/// [State] ของ [CrudUpdatingDialog]
class CrudUpdatingDialogState extends ConsumerState<CrudUpdatingDialog> {
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
      if (mounted) {
        final value = ref.read(crudModelListProvider).read(widget.index).data.toString();
        controller.value = TextEditingValue(text: value);
      }
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
          title: const Text('Edit'),
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
              onPressed: canPop ? () => _onUpdateConfirmButtonPressed(ref.read(crudModelListProvider)) : null,
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpdateConfirmButtonPressed(CrudModelList list) async {
    if (mounted) {
      setState(() {
        canPop = false;
      });
    }

    try {
      final updated = await list.update(widget.index, controller.text);
      if (updated.success) {
        widget.onUpdate?.call();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
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
