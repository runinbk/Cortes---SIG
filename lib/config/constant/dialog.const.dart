import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_sig/config/constant/const.dart';

class DialogService {
  // LOGIC :  Mostrar SnackBar Exitoso
  static void showSuccessSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: size.width * 0.06,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.voces(
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: kQuintaColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(size.width * 0.04),
      elevation: 6,
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // LOGIC : Mostrar SnackBar Error
  static void showErrorSnackBar(
      {required String message, required BuildContext context}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: size.width * 0.06,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.voces(
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: kPrimaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(size.width * 0.04),
      elevation: 6,
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // LOGIC : Mostrar Diálogo de Carga
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kPrimaryColor.withOpacity(0.15),
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: size.width * 0.85,
            padding: EdgeInsets.all(size.width * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.width * 0.04),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de carga personalizado
                Container(
                  width: size.width * 0.2,
                  height: size.width * 0.2,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        strokeWidth: size.width * 0.008,
                      ),
                      Icon(
                        Icons.water_drop_rounded,
                        color: kPrimaryColor,
                        size: size.width * 0.08,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                // Mensaje principal
                Text(
                  message ?? 'Procesando...',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.048,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(height: size.width * 0.02),
                // Mensaje secundario
                Text(
                  '¡Gracias por tu paciencia!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
