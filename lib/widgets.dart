import 'package:flutter/material.dart';
import 'dart:math';

double autoRoundUp(double value) {
  // Get the order of magnitude of the value
  int magnitude = value.abs().toStringAsFixed(0).length - 1;

  // Calculate the base factor (10^magnitude)
  double factor = pow(10, magnitude).toDouble();

  // Auto-detect step as 25% of the factor (this can be adjusted)
  double step = factor / 4; 

  // Round up to the nearest step
  return (value / step).ceil() * step;
}








class MyIconButton extends StatefulWidget {
  final IconData icon;
  final Color pressedColor;
  final Color color;
  final double borderRadius;
  final double width;
  final double height;
  final double iconHeight;
  final double iconWidth;
  final VoidCallback? onTap;

  const MyIconButton({
    super.key,
    required this.icon,
    this.pressedColor = Colors.transparent,
    this.color = Colors.transparent,
    required this.borderRadius,
    required this.width,
    required this.height,
    this.iconWidth = 5,
    this.iconHeight = 5,
    this.onTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  bool buttonDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          buttonDown = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          buttonDown = false;
        });
        widget.onTap?.call();
      },
      
      child: Container(
        margin: const EdgeInsets.all(10),
        width: widget.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonDown ? widget.pressedColor : widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Icon(
          widget.icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class MyTextButton extends StatefulWidget {
  final String text;
  final Color pressedColor;
  final Color color;
  final double borderRadius;
  final double width;
  final double height;
  final String path;
  final VoidCallback? onTap;

  const MyTextButton({
    super.key,
    required this.text,
    required this.pressedColor,
    required this.color,
    required this.borderRadius,
    required this.width,
    required this.height, 
    this.path = "",
    this.onTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyTextButtonState createState() => _MyTextButtonState();
}

class _MyTextButtonState extends State<MyTextButton> with SingleTickerProviderStateMixin {
  bool buttonDown = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      buttonDown = true;
    });
    _controller.forward();
  }


  void _onTapUp(TapUpDetails details) {
    setState(() {
      buttonDown = false;
    });
    widget.onTap!();
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() {
      buttonDown = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              gradient: buttonDown
                  ? RadialGradient(
                      center: Alignment.center,
                      radius: _controller.value,
                      colors: const [
                        Color.fromARGB(112, 157, 206, 255),
                        Color.fromARGB(112, 146, 164, 253),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff9DCEFF),
                        Color(0xff92A3FD),
                      ],
                    ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: buttonDown ? widget.pressedColor : widget.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomPopupMenuButton extends StatelessWidget {
  final Function(String) onSelected;

  const CustomPopupMenuButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset.zero, ancestor: overlay),
            button.localToGlobal(Offset.zero, ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        showMenu<String>(
          context: context,
          position: position,
          items: [
            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
            const PopupMenuItem(value: 'Delete', child: Text('Delete')),
            const PopupMenuItem(value: 'Share', child: Text('Share')),
          ],
          elevation: 8.0,
          useRootNavigator: true,
        ).then((value) {
          if (value != null) {
            onSelected(value);
          }
        });
      },
      child: const Icon(Icons.more_vert),
    );
  }
}

AppBar myAppBar(BuildContext context, String title, {Widget? button}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: [
      if (button != null) button,
    ],
  );
}