import 'package:flutter/material.dart';

class AchievementPopup {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final overlayEntry = _createOverlayEntry(context, title, subtitle, icon);
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
  }

  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50.0,
          left: MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                bool isExpanded = false;

                Future.delayed(Duration.zero, () {
                  setState(() => isExpanded = true);
                });

                return AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 60,
                    width: isExpanded ? MediaQuery.of(context).size.width * 0.8 : 60,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.amber, size: 30),
                        AnimatedOpacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}