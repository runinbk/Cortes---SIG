import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/blocs/map/map_bloc.dart';
import 'package:proyecto_sig/config/constant/const.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    await mapBloc.askGpsAccess();
    await _requestBasicPermissions();
    await _initSpeechToText();
    await _requestCameraPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.75,
                  width: size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/fondoP.png"),
                        fit: BoxFit.cover),
                  ),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  )),
                ),
                const ContainerCustom(),
                Positioned(
                    top: size.height * 0.07,
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width,
                      height: size.height * 0.1,
                      child: Text("COOSIV R.L.", style: letterStyle.tituloHome),
                    )),
                Positioned(
                  top: size.height * 0.175,
                  child: Container(
                    alignment: Alignment.center,
                    width: size.width,
                    height: size.height * 0.1,
                    child: Text(
                      "Fluidez y Calidad en Cada Gota\nCompromiso con tu Bienestar",
                      style: letterStyle.titulo2Home,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                    top: size.height * 0.31,
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    child: const FormularioAuth()),
                const InfoSection()
              ],
            ),
          ),
        ));
  }

  Future<void> _requestBasicPermissions() async {
    try {
      // Solicitar permisos de almacenamiento
      await Permission.storage.request();
      // Solicitar permisos de galería
      if (Platform.isIOS) {
        await Permission.photos.request();
      }
    } catch (e) {
      debugPrint('Error solicitando permisos básicos: $e');
    }
  }

  Future<void> _initSpeechToText() async {
    try {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        await _speechToText.initialize(
          onStatus: (status) => debugPrint('Speech status: $status'),
          onError: (error) => debugPrint('Speech error: $error'),
        );
      }
    } catch (e) {
      debugPrint('Error inicializando speech to text: $e');
    }
  }

  Future<void> _requestCameraPermissions() async {
    try {
      await Permission.camera.request();
    } catch (e) {
      debugPrint('Error solicitando permisos de cámara: $e');
    }
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height * 0.89,
      left: size.width * 0.1,
      right: size.width * 0.1,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
            Text(
              "¿No tiene una cuenta?",
              style: GoogleFonts.voces(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(height: size.height * 0.003),
            Text(
              "Registro presencial en nuestras instalaciones.",
              textAlign: TextAlign.center,
              style: GoogleFonts.voces(
                fontSize: size.width * 0.04,
                color: kCuartoColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  const ContainerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(
          painter: _CurvoContainer(),
        ));
  }
}

class _CurvoContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lapiz = Paint();

    // Configuración base
    lapiz.color = Colors.white;
    lapiz.style = PaintingStyle.fill;
    lapiz.strokeWidth = 20;

    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.5, // Punto de control X en el centro
        size.height *
            0.82, // Punto de control Y más abajo para mayor profundidad
        size.width, // Punto final X
        size.height * 0.65 // Punto final Y
        );
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, lapiz);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FormularioAuth extends StatefulWidget {
  const FormularioAuth({
    super.key,
  });

  @override
  State<FormularioAuth> createState() => _FormularioAuthState();
}

class _FormularioAuthState extends State<FormularioAuth> {
  String _usuario = "";
  String _password = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    List<String> roles = ['Profesor', 'Alumno', 'Apoderado'];
    final decoration1 = BoxDecoration(
      borderRadius: BorderRadius.circular(
        size.width * 0.03,
      ),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: kSecondaryColor, // Color de la sombra
          offset: Offset(0, 1), // Desplazamiento (x,y)
          blurRadius: 5, // Radio de desenfoque
          spreadRadius: 0, // Radio de extensión
        ),
      ],
    );
    const decoration2 = BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/logo.png"), fit: BoxFit.contain),
    );

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.025),
      width: size.width * 0.8,
      height: size.height * 0.55,
      decoration: decoration1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: size.width * 0.25,
            height: size.height * 0.1,
            decoration: decoration2,
          ),
          TextFormFieldCustom(
            onChanged: (value) {
              setState(() {
                _usuario = value;
              });
            },
            textPlaceholder: 'Codigo Funcionario',
            icon: Icons.credit_card,
          ),
          TextFormFieldCustom(
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            textPlaceholder: 'Ingrese su clave',
            icon: Icons.app_registration,
          ),
          SelectorOptions(
            icon: Icons.list_alt,
            onChanged: (value) {
              setState(() {
                // _rol = value!;
              });
            },
            options: roles,
            textPlaceholder: "Seleccione un Rol",
          ),
          SizedBox(
            width: size.width * 0.06,
          ),
          GestureDetector(
            onTap: () {
              authBloc.add(OnAuthenticating(
                context: context,
                codigo: _usuario,
                password: _password,
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: kCuartoColor,
                borderRadius: BorderRadius.circular(
                  size.width * 0.025,
                ),
              ),
              // Agregar padding dinámico
              padding: EdgeInsets.symmetric(
                horizontal:
                    size.width * 0.028, // Padding horizontal 8% del ancho
                vertical: size.height * 0.013, // Padding vertical 1.5% del alto
              ),
              child: Text(
                "Inicio de sesión",
                style: letterStyle.letraButton,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SelectorOptions extends StatelessWidget {
  const SelectorOptions({
    super.key,
    required this.options,
    required this.icon,
    required this.onChanged,
    required this.textPlaceholder,
  });

  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String textPlaceholder;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DropdownButtonFormField<String>(
      style: letterStyle.letraInput,
      isDense: true,
      alignment: AlignmentDirectional.centerStart,
      menuMaxHeight: size.height * 0.2,
      isExpanded: true, // Asegura que use todo el ancho disponible
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: size.width * 0.02,
        ),
        hintText: textPlaceholder,
        hintStyle: letterStyle.placeholderInput,
        prefixIcon: Icon(icon),
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? kCuartoColor
                : kTerciaryColor),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: kCuartoColor, width: 2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: kTerciaryColor, width: 1),
        ),
      ),
      items: options.map((String rol) {
        return DropdownMenuItem<String>(
          value: rol,
          child: Text(rol),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(
        Icons.arrow_drop_down,
        color: kTerciaryColor,
        size: size.width * 0.06,
      ),
      dropdownColor: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

class TextFormFieldCustom extends StatelessWidget {
  const TextFormFieldCustom({
    super.key,
    required this.onChanged,
    required this.textPlaceholder,
    required this.icon,
  });

  final ValueChanged<String> onChanged;
  final String textPlaceholder;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final decoration = InputDecoration(
      // Placeholder y su estilo
      hintText: textPlaceholder,
      hintStyle: letterStyle.placeholderInput,
      // Icono y su color según estado
      prefixIcon: Icon(icon),
      prefixIconColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.focused) ? kCuartoColor : kTerciaryColor),

      // Borde inferior cuando está enfocado
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: kCuartoColor,
          width: 2,
        ),
      ),

      // Borde inferior cuando no está enfocado
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: kTerciaryColor,
          width: 1,
        ),
      ),

      // Color del label flotante
      floatingLabelStyle:
          WidgetStateTextStyle.resolveWith((states) => GoogleFonts.rajdhani(
                color: states.contains(WidgetState.focused)
                    ? kCuartoColor
                    : kTerciaryColor,
                fontSize: size.width * 0.04,
              )),
    );

    return TextFormField(
      onChanged: onChanged,
      style: letterStyle.letraInput,
      cursorColor: kCuartoColor,
      decoration: decoration,
    );
  }
}

class DateTimeFormFieldCustom extends StatelessWidget {
  const DateTimeFormFieldCustom({
    super.key,
    required this.onDateTimeSelected,
    required this.textPlaceholder,
    required this.selectedDateTime,
  });

  final Function(DateTime) onDateTimeSelected;
  final String textPlaceholder;
  final DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      hintText: textPlaceholder,
      hintStyle: letterStyle.placeholderInput,
      // prefixIcon: const Icon(Icons.calendar_today),
      prefixIconColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.focused) ? kCuartoColor : kTerciaryColor),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: kCuartoColor,
          width: 2,
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: kTerciaryColor,
          width: 1,
        ),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.event),
        onPressed: () async {
          final fecha = await showDatePicker(
            context: context,
            initialDate: selectedDateTime ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2025),
          );

          if (fecha != null) {
            final hora = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
            );

            if (hora != null) {
              onDateTimeSelected(DateTime(
                fecha.year,
                fecha.month,
                fecha.day,
                hora.hour,
                hora.minute,
              ));
            }
          }
        },
      ),
      floatingLabelStyle:
          WidgetStateTextStyle.resolveWith((states) => GoogleFonts.rajdhani(
                color: states.contains(WidgetState.focused)
                    ? kCuartoColor
                    : kTerciaryColor,
                fontSize: size.width * 0.04,
              )),
    );

    return TextFormField(
      readOnly: true,
      style: letterStyle.letraInput,
      cursorColor: kCuartoColor,
      decoration: decoration,
      controller: TextEditingController(
        text: selectedDateTime != null
            ? '${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} ${selectedDateTime!.hour}:${selectedDateTime!.minute}'
            : '',
      ),
    );
  }
}
