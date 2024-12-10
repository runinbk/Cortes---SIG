import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_sig/config/constant/const.dart';

class LetterStyle {
  BuildContext context;

  LetterStyle(this.context);

  Size get size => MediaQuery.of(context).size;

  TextStyle get titulo => GoogleFonts.sourceCodePro(
      color: Colors.white,
      fontSize: size.width * 0.09,
      fontWeight: FontWeight.bold,
      shadows: shadowKPN2);

  TextStyle get tituloHome => GoogleFonts.kaushanScript(
      fontSize: size.width * 0.115,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: shadowKSN2);

  TextStyle get titulo2Home => GoogleFonts.voces(
      fontSize: size.width * 0.05,
      color: Colors.white,
      // fontWeight: FontWeight.bold,
      shadows: shadowKSN1);

  TextStyle get titleAuth => GoogleFonts.voces(
        fontSize: size.width * 0.08,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  TextStyle get letraInput => GoogleFonts.voces(
        fontSize: size.width * 0.05,
        color: kCuartoColor,
      );

  TextStyle get placeholderInput => GoogleFonts.voces(
        fontSize: size.width * 0.05,
        color: kTerciaryColor,
      );

  TextStyle get letraButton => GoogleFonts.voces(
        fontSize: size.width * 0.05,
        color: Colors.white,
        // fontWeight: FontWeight.bold
      );

  // READ : LETRAS DEL SCREEN COMUNICADOS
  TextStyle get tituloComunicados => GoogleFonts.voces(
        fontSize: size.width * 0.08,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  TextStyle get letra1Comunicados => GoogleFonts.voces(
        color: kCuartoColor,
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.bold,
      );

  TextStyle get letra2Comunicados => GoogleFonts.voces(
        color: kTerciaryColor,
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.bold,
      );

  TextStyle get letra3Comunicados => GoogleFonts.voces(
        color: kTerciaryColor,
        fontSize: size.width * 0.04,
      );

  TextStyle get letra1OptionsComunicados => GoogleFonts.voces(
        color: kCuartoColor,
        fontSize: size.width * 0.06,
        fontWeight: FontWeight.bold,
      );

  TextStyle get letra2OptionsComunicados => GoogleFonts.voces(
        color: kCuartoColor,
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.bold,
      );

  TextStyle get letra3OptionsComunicados => GoogleFonts.voces(
        color: kTerciaryColor,
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.bold,
      );

  // READ : LETRAS DEL VIEW COMUNICADO SCREEN
  TextStyle get tituloViewComunicado => GoogleFonts.voces(
        fontSize: size.width * 0.08,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
      );

  TextStyle get letra1ViewComunicado => GoogleFonts.voces(
        color: kPrimaryColor,
        fontSize: size.width * 0.05,
        // fontWeight: FontWeight.bold,
      );

  TextStyle get letra2ViewComunicado => GoogleFonts.voces(
        color: kCuartoColor,
        fontSize: size.width * 0.05,
        // fontWeight: FontWeight.bold,
      );

  TextStyle get letra3ViewComunicado => GoogleFonts.voces(
        color: kCuartoColor,
        fontSize: size.width * 0.08,
        fontWeight: FontWeight.bold,
      );

  // READ :  IA PROFESOR SCREEN

  TextStyle get letra1IAProfesor => GoogleFonts.voces(
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.bold,
        color: kCuartoColor,
      );

  TextStyle get letra2IAProfesor => GoogleFonts.voces(
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.bold,
        color: kCuartoColor,
        height: 1.5,
      );

  TextStyle get letra3IAProfesor => GoogleFonts.voces(
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.w600,
        color: kCuartoColor,
      );

  TextStyle get tituloIAProfesor => GoogleFonts.kaushanScript(
      fontSize: size.width * 0.08,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: shadowKSN2);

  TextStyle get titulo2IAProfesor => GoogleFonts.voces(
      color: Colors.white,
      // fontWeight: FontWeight.bold,
      fontSize: size.width * 0.05,
      shadows: shadowKSN1);

  TextStyle get letra1Mapa => GoogleFonts.aBeeZee(
      color: kPrimaryColor,
      fontSize: size.width * 0.06,
      fontWeight: FontWeight.bold);

  TextStyle get letra2Mapa => GoogleFonts.aBeeZee(
      color: Colors.black,
      fontSize: size.width * 0.045,
      fontWeight: FontWeight.bold);

  TextStyle get letra3Mapa => GoogleFonts.aBeeZee(
        color: Colors.black,
        fontSize: size.width * 0.04,
        // fontWeight: FontWeight.bold
      );

  TextStyle get letra4Mapa => GoogleFonts.aBeeZee(
      color: Colors.white,
      fontSize: size.width * 0.05,
      fontWeight: FontWeight.bold);

  TextStyle get letra5Mapa => GoogleFonts.aBeeZee(
      color: Colors.white,
      fontSize: size.width * 0.035,
      fontWeight: FontWeight.bold);

  // list_style.dart
  TextStyle get cardTitle => GoogleFonts.voces(
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
      );

  TextStyle get cardSubtitle => GoogleFonts.voces(
        fontSize: size.width * 0.035,
        color: kCuartoColor,
      );

  TextStyle get statusText => GoogleFonts.montserrat(
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.w600,
        color: kQuintaColor,
      );

  TextStyle get timeText => GoogleFonts.robotoMono(
        fontSize: size.width * 0.035,
        color: kTerciaryColor,
        fontWeight: FontWeight.w500,
      );

  TextStyle get routeTitle => GoogleFonts.raleway(
        fontSize: size.width * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
