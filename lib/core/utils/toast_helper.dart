import 'package:flutter/material.dart';

enum ToastType { success, warning, error }

void showTopNotification(
  BuildContext context, {
  required ToastType type,
  required String title,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);

  // chọn màu và icon theo type
  Color iconBg;
  IconData iconData;
  switch (type) {
    case ToastType.success:
      iconData = Icons.check;
      iconBg = const Color(0xFF4CAF50);
      break;
    case ToastType.warning:
      iconData = Icons.priority_high;
      iconBg = const Color(0xFFFFA000);
      break;
    case ToastType.error:
      iconData = Icons.close;
      iconBg = const Color(0xFFF44336);
      break;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(builder: (ctx) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color.fromRGBO(0,0,0,0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0,0,0,0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // colored round icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color.fromRGBO(0,0,0,0.06), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Icon(iconData, color: Colors.white, size: 20),
                  ),

                  const SizedBox(width: 12),

                  // text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(message, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ),

                  // close icon
                  GestureDetector(
                    onTap: () {
                      try {
                        entry.remove();
                      } catch (_) {}
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });

  overlay.insert(entry);
  Future.delayed(duration, () {
    try {
      entry.remove();
    } catch (_) {}
  });
}
