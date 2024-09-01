import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyIconButton extends StatefulWidget {
  final String filepath;
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
    required this.filepath,
    required this.pressedColor,
    required this.color,
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
        widget.onTap!();
      },
      
      child: Container(
        margin: const EdgeInsets.all(10),
        width: widget.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonDown ? widget.pressedColor : widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: SvgPicture.asset(
          widget.filepath,
          height: widget.iconHeight,
          width: widget.iconWidth,
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
