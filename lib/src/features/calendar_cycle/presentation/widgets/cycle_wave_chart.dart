import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleWaveChart extends StatelessWidget {
  final List<Map<String, dynamic>> historyData;
  final bool isDark;

  const CycleWaveChart({
    super.key,
    this.historyData = const [],
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Biểu đồ độ đều chu kỳ",
            style: GoogleFonts.inter(
              color: isDark ? Colors.white70 : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: historyData.isEmpty
                ? Center(
                    child: Text(
                      "Chưa đủ dữ liệu",
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: _HistoryLineChartPainter(
                      data: historyData,
                      isDark: isDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool isDark;

  _HistoryLineChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height - 20; // Reserve bottom for X-axis labels
    final paddingX = 20.0;

    // Determine min/max Y for scaling
    // Default nice range: 20 to 45
    const double minY = 20;
    const double maxY = 45;
    const double rangeY = maxY - minY;

    List<Offset> points = [];

    // Calculate Points
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final length = (item['length'] as int).toDouble();

      final x = paddingX + (i * (width - 2 * paddingX) / (data.length - 1));

      // Normalize Y (Higher value = Lower Y coordinate)
      final normalizedY = (length - minY) / rangeY;
      final y = height - (normalizedY * height); // Invert

      points.add(Offset(x, y.clamp(0, height)));
    }

    // 1. Draw Curve Path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Control points for smooth bezier (Catmull-rom style simple smoothing)
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Fill Path (Clone path and close it)
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, height);
    fillPath.lineTo(points.first.dx, height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height)),
    );

    // Stroke Path
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 2. Draw Points & Labels
    final textStyle = GoogleFonts.inter(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final subTextStyle = GoogleFonts.inter(color: Colors.white70, fontSize: 10);

    // Draw Average Line?
    // Let's draw it simply.
    final avg =
        data.map((e) => e['length'] as int).reduce((a, b) => a + b) /
        data.length;
    final avgY = height - ((avg - minY) / rangeY * height);
    final avgPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Dashed line manually
    double dashX = 0;
    while (dashX < width) {
      canvas.drawLine(Offset(dashX, avgY), Offset(dashX + 5, avgY), avgPaint);
      dashX += 10;
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final item = data[i];

      // Draw Dot
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = const Color(0xFF4B89EA));

      // Draw Value (Top)
      final valSpan = TextSpan(text: "${item['length']}", style: textStyle);
      final valPainter = TextPainter(
        text: valSpan,
        textDirection: TextDirection.ltr,
      );
      valPainter.layout();
      valPainter.paint(
        canvas,
        Offset(point.dx - valPainter.width / 2, point.dy - 20),
      );

      // Draw Month (Bottom)
      final monthSpan = TextSpan(
        text: "Th ${item['labelMonth']}",
        style: subTextStyle,
      );
      final monthPainter = TextPainter(
        text: monthSpan,
        textDirection: TextDirection.ltr,
      );
      monthPainter.layout();
      monthPainter.paint(
        canvas,
        Offset(point.dx - monthPainter.width / 2, height + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
