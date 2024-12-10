import 'package:flutter/material.dart';
import 'package:proyecto_sig/config/constant/const.dart';

class CustomMarker extends StatelessWidget {
  final String numero;
  final Color color;
  final double size;

  const CustomMarker({
    Key? key,
    required this.numero,
    this.color = const Color(0xFF2B2E83),
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MarkerNumerado(
        numero: numero,
        color: color,
        size: size,
      ),
      size: Size(size, size * 1.3),
    );
  }
}

class MarkerNumerado extends CustomPainter {
  final String numero;
  final Color color;
  final double size;

  MarkerNumerado({
    required this.numero,
    this.color = const Color(0xFF2B2E83),
    this.size = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = this.size;
    final double height = this.size * 1.3;
    final center = Offset(width / 2, width / 2);

    // Sombra principal del marcador
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: width * 0.4))
      ..moveTo(width * 0.5, height * 0.95)
      ..lineTo(width * 0.35, width * 0.85)
      ..quadraticBezierTo(
        width * 0.5,
        width * 0.82,
        width * 0.65,
        width * 0.85,
      )
      ..close();

    // Sombra exterior más suave
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Círculo blanco de fondo con gradiente
    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.9)],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: width * 0.32));
    canvas.drawCircle(center, width * 0.32, backgroundPaint);

    // Dibujar el pin base con efecto de brillo
    final Path pinPath = Path()
      ..moveTo(width * 0.5, height * 0.95)
      ..lineTo(width * 0.35, width * 0.85)
      ..quadraticBezierTo(
        width * 0.5,
        width * 0.82,
        width * 0.65,
        width * 0.85,
      )
      ..close();

    // Sombra interior del pin
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 3),
    );

    // Pintar el pin con gradiente
    final Paint pinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(pinPath, pinPaint);

    // Círculo exterior con efecto de brillo
    final Paint circlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, width))
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, width * 0.35, circlePaint);

    // Brillo superior del círculo
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.02;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: width * 0.35),
      -0.8,
      1.2,
      false,
      highlightPaint,
    );

    // Líneas de mira con efecto de brillo
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = width * 0.035
      ..strokeCap = StrokeCap.round;

    // Función para dibujar línea con brillo
    void drawLineWithGlow(Offset start, Offset end) {
      // Glow effect
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = width * 0.05
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Main line
      canvas.drawLine(start, end, linePaint);
    }

    final lineLength = width * 0.15;

    // Dibujar líneas con brillo
    drawLineWithGlow(
      Offset(width * 0.5, width * 0.15),
      Offset(width * 0.5, width * 0.15 + lineLength),
    );
    drawLineWithGlow(
      Offset(width * 0.5, width * 0.7),
      Offset(width * 0.5, width * 0.85),
    );
    drawLineWithGlow(
      Offset(width * 0.15, width * 0.5),
      Offset(width * 0.15 + lineLength, width * 0.5),
    );
    drawLineWithGlow(
      Offset(width * 0.85 - lineLength, width * 0.5),
      Offset(width * 0.85, width * 0.5),
    );

    // Líneas punteadas con brillo
    double startY = width * 0.99;
    double endY = height * 0.9;
    double spacing = (endY - startY) / 6;

    for (int i = 0; i < 3; i++) {
      final start = Offset(width * 0.5, startY + (spacing * (i * 2)));
      final end = Offset(width * 0.5, startY + (spacing * ((i * 2) + 1)));

      // Glow effect
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = width * 0.04
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Main dot
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color
          ..strokeWidth = width * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }

    // Número con efectos mejorados
    if (numero.isNotEmpty) {
      final textX = width / 2;
      final textY = width / 2;

      // Texto principal con gradiente
      final gradientShader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          kCuartoColor,
          kCuartoColor.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(textX, textY),
        width: width * 0.5,
        height: width * 0.5,
      ));

      final mainTextSpan = TextSpan(
        text: numero,
        style: TextStyle(
          fontSize: width * 0.32,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          foreground: Paint()..shader = gradientShader,
        ),
      );

      final mainTextPainter = TextPainter(
        text: mainTextSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      mainTextPainter.layout();
      mainTextPainter.paint(
        canvas,
        Offset(
          textX - (mainTextPainter.width / 2),
          textY - (mainTextPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
