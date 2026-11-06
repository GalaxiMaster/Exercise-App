import 'package:exercise_app/Functions/Cloud/socail_services.dart';
import 'package:flutter/material.dart';

/// Shows the username dialog.
/// - [required]: true on first launch, so it can't be dismissed without choosing a name
Future<String?> showUsernameDialog(
  BuildContext context, {
  String? currentUsername,
  bool required = false,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: !required,
    builder: (_) => _UsernameDialog(
      currentUsername: currentUsername,
      required: required,
    ),
  );
}

class _UsernameDialog extends StatefulWidget {
  final String? currentUsername;
  final bool required;
  const _UsernameDialog({this.currentUsername, required this.required});

  @override
  State<_UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<_UsernameDialog> {
  final _social = SocialService();
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  static final _valid = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();

    if (!_valid.hasMatch(name)) {
      setState(() => _error = '3-20 characters: letters, numbers, underscores');
      return;
    }
    if (name == widget.currentUsername) {
      Navigator.pop(context); // unchanged
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _social.setUsernameAndProfile(name);
      if (mounted) Navigator.pop(context, name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChange = widget.currentUsername != null;

    return PopScope(
      canPop: !widget.required,
      child: AlertDialog(
        title: Text(isChange ? 'Change username' : 'Choose a username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChange
                  ? 'Friends find you by this name. Your old name becomes available to others.'
                  : 'Friends will use this to find and add you.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_saving,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                prefixText: '@',
                hintText: 'username',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.required)
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}