// detalle_corte_screen.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/blocs/map/map_bloc.dart';
import 'package:proyecto_sig/config/constant/const.dart';
import 'package:proyecto_sig/config/constant/dialog.const.dart';
import 'package:proyecto_sig/config/services/media-handler-impl.service.dart';
import 'package:proyecto_sig/config/services/media-handler.service.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoCorte.entitie.dart';

class DetalleCorteScreen extends StatefulWidget {
  const DetalleCorteScreen({
    super.key,
  });

  @override
  State<DetalleCorteScreen> createState() => _DetalleCorteScreenState();
}

class _DetalleCorteScreenState extends State<DetalleCorteScreen> {
  final MediaHandlerService _mediaHandler = MediaHandlerServiceImpl();
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;
  String estadoSeleccionado = 'Pendiente';
  String? audioPath;
  String _imagePath = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mediaHandler.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      await _mediaHandler.initSpeechService();
    } catch (e) {
      debugPrint('Error al inicializar servicios de audio: $e');
    }
  }

  void _handleSpeechToText() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      await _mediaHandler.startListening(
        onResult: (text) {
          setState(() {
            _controller.text = text;
          });
        },
        localeId: 'es_ES',
      );
    } else {
      setState(() => _isListening = false);
      await _mediaHandler.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final corte = listaCorteBeta[0];
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);
    final corte = authBloc.state.infoCorte;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DETALLE DE CORTE',
          style: letterStyle.letra4Mapa.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_imagePath.isNotEmpty)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.image,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Fondo semi-transparente
                          Container(
                            color: Colors.black87,
                          ),
                          // Imagen
                          InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,
                            child: Center(
                              child: Image.network(
                                _imagePath,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.circleExclamation,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Botón cerrar
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.xmark,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: ClienteInfoCard(corte: corte!),
              ),
              SizedBox(height: size.width * 0.04),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: EstadoServicioCard(
                  estadoSeleccionado: estadoSeleccionado,
                  onEstadoChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        estadoSeleccionado = newValue;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: size.width * 0.04),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: MedidorInfoCard(corte: corte),
              ),
              SizedBox(height: size.width * 0.04),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: EvidenciasCard(
                    controller: _controller,
                    onTomarFoto: () async {
                      // Capturamos el BuildContext en una función separada
                      Future<void> handleUpload(BuildContext context) async {
                        String? imagePath = await _mediaHandler.takePhoto();
                        if (imagePath == null) return;

                        if (!context.mounted) return;

                        DialogService.showLoadingDialog(
                            context: context, message: 'Subiendo imagen...');

                        try {
                          final imageUrl =
                              await _mediaHandler.uploadImage(imagePath);

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          if (imageUrl != null) {
                            setState(() {
                              _imagePath = imageUrl;
                            });

                            DialogService.showSuccessSnackBar(
                                "¡Imagen subida exitosamente!", context);
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          Navigator.pop(context);
                          DialogService.showErrorSnackBar(
                              context: context,
                              message: 'Error al subir la imagen: $e');
                        }
                      }

                      // Llamamos a la función con el context actual
                      await handleUpload(context);
                    },
                    onBuscarFotoGaleria: () async {
                      // Capturamos el BuildContext en una función separada
                      Future<void> handleUpload(BuildContext context) async {
                        String? imagePath = await _mediaHandler.selectPhoto();
                        if (imagePath == null) return;

                        if (!context.mounted) return;

                        DialogService.showLoadingDialog(
                            context: context, message: 'Subiendo imagen...');

                        try {
                          final imageUrl =
                              await _mediaHandler.uploadImage(imagePath);

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          if (imageUrl != null) {
                            setState(() {
                              _imagePath = imageUrl;
                            });

                            DialogService.showSuccessSnackBar(
                                "¡Imagen subida exitosamente!", context);
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          Navigator.pop(context);
                          DialogService.showErrorSnackBar(
                              context: context,
                              message: 'Error al subir la imagen: $e');
                        }
                      }

                      // Llamamos a la función con el context actual
                      await handleUpload(context);
                    },
                    onAudio: _handleSpeechToText,
                    onClear: () {
                      setState(() {
                        _controller.clear();
                        _imagePath = "";
                      });
                    },
                    isListening: _isListening),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onSave: () {
          mapBloc.add(OnEditPuntoCorteRutaTrabajo(corte, estadoSeleccionado));
          DialogService.showSuccessSnackBar(
              "¡Cambios guardados exitosamente!", context);
          // Aquí implementarás la lógica de guardado
          print('Estado: $estadoSeleccionado');
        },
      ),
    );
  }
}

class EstadoServicioCard extends StatelessWidget {
  final String estadoSeleccionado;
  final Function(String?) onEstadoChanged;

  const EstadoServicioCard({
    super.key,
    required this.estadoSeleccionado,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final estados = ['Pendiente', 'En Proceso', 'Completado'];

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del Servicio de Corte',
            style: letterStyle.letra1Comunicados.copyWith(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.width * 0.03),
          Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.width * 0.02),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: estadoSeleccionado,
                isExpanded: true,
                icon: const FaIcon(FontAwesomeIcons.angleDown),
                items: estados.map((String estado) {
                  Color color;
                  IconData icon;

                  switch (estado) {
                    case 'Pendiente':
                      color = Colors.orange;
                      icon = FontAwesomeIcons.clock;
                      break;
                    case 'En Proceso':
                      color = Colors.blue;
                      icon = FontAwesomeIcons.personDigging;
                      break;
                    default: // Completado
                      color = kQuintaColor;
                      icon = FontAwesomeIcons.check;
                  }

                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Row(
                      children: [
                        FaIcon(icon, color: color, size: size.width * 0.05),
                        SizedBox(width: size.width * 0.03),
                        Text(
                          estado,
                          style: GoogleFonts.voces(
                            color: color,
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onEstadoChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EvidenciasCard extends StatelessWidget {
  const EvidenciasCard(
      {super.key,
      required this.onTomarFoto,
      required this.onBuscarFotoGaleria,
      required this.onAudio,
      required this.onClear,
      required this.isListening,
      required this.controller});

  final TextEditingController controller;
  final Function() onTomarFoto;
  final Function() onBuscarFotoGaleria;
  final Function() onAudio;
  final Function() onClear;
  final bool isListening;

  Widget _buildEvidenciaButton(
    String text,
    IconData icon,
    Color color,
    Function() onPressed, {
    bool isActive = false,
  }) {
    return Column(
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final bool isViewOnly = state.infoCorteType == InfoCorteType.view;

            return IconButton(
              onPressed: isViewOnly ? null : onPressed,
              icon: FaIcon(
                icon,
                color: isViewOnly ? Colors.grey : Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: isViewOnly
                    ? Colors.grey.shade300
                    : (isActive ? Colors.red : color),
                padding: EdgeInsets.all(size.width * 0.03),
              ),
            );
          },
        ),
        SizedBox(height: size.width * 0.01),
        Text(
          text,
          style: letterStyle.letra1Comunicados.copyWith(
            fontSize: size.width * 0.03,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isViewOnly = state.infoCorteType == InfoCorteType.view;

        return Container(
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evidencias y Comentarios',
                style: letterStyle.letra1Comunicados.copyWith(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.width * 0.03),
              TextField(
                maxLines: 3,
                enabled: !isViewOnly,
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Agregar comentario...',
                  hintStyle: letterStyle.placeholderInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEvidenciaButton(
                    'Tomar Foto',
                    FontAwesomeIcons.camera,
                    kPrimaryColor,
                    onTomarFoto,
                  ),
                  _buildEvidenciaButton(
                    'Galería',
                    FontAwesomeIcons.image,
                    kCuartoColor,
                    onBuscarFotoGaleria,
                  ),
                  _buildEvidenciaButton(
                    'Audio',
                    FontAwesomeIcons.microphone,
                    Colors.orange,
                    onAudio,
                    isActive: isListening,
                  ),
                  _buildEvidenciaButton(
                    'Limpiar',
                    FontAwesomeIcons.trash,
                    Colors.red,
                    onClear,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClienteInfoCard extends StatelessWidget {
  final InfoCorte corte;

  const ClienteInfoCard({
    super.key,
    required this.corte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.08,
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                child: FaIcon(
                  FontAwesomeIcons.user,
                  size: size.width * 0.08,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corte.dNomb,
                      style: letterStyle.letra1Comunicados.copyWith(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.width * 0.01),
                    Text(
                      'Cuenta: ${corte.bscocNcnt}',
                      style: letterStyle.letra3Comunicados.copyWith(
                        color: kCuartoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.04),
          _buildInfoRow(
            'Dirección',
            corte.dLotes,
            FontAwesomeIcons.locationDot,
            kPrimaryColor,
          ),
          SizedBox(height: size.width * 0.02),
          _buildInfoRow(
            'Categoría',
            corte.dNcat,
            FontAwesomeIcons.tag,
            kCuartoColor,
          ),
          SizedBox(height: size.width * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildHighlightBox(
                  'Meses Mora',
                  '${corte.bscocNmor}',
                  FontAwesomeIcons.clockRotateLeft,
                  Colors.orange,
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Expanded(
                child: _buildHighlightBox(
                  'Deuda',
                  'Bs. ${corte.bscocImor.toStringAsFixed(2)}',
                  FontAwesomeIcons.moneyBill,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MedidorInfoCard extends StatelessWidget {
  final InfoCorte corte;

  const MedidorInfoCard({
    super.key,
    required this.corte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Medidor',
            style: letterStyle.letra1Comunicados.copyWith(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.width * 0.03),
          _buildInfoRow(
            'Número',
            corte.bsmedNume,
            FontAwesomeIcons.hashtag,
            kPrimaryColor,
          ),
          SizedBox(height: size.width * 0.02),
          _buildInfoRow(
            'Serie',
            corte.bsmednser,
            FontAwesomeIcons.barcode,
            kCuartoColor,
          ),
          SizedBox(height: size.width * 0.02),
          _buildInfoRow(
            'Ubicación',
            '${corte.bscntlati}, ${corte.bscntlogi}',
            FontAwesomeIcons.locationCrosshairs,
            Colors.green,
          ),
        ],
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final VoidCallback onSave;

  const BottomActionBar({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);
    final bool isViewMode = authBloc.state.infoCorteType == InfoCorteType.view;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isViewMode ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: isViewMode
                    ? Colors.grey
                    : kQuintaColor, // Cambia el color si está deshabilitado
                disabledBackgroundColor:
                    Colors.grey.shade300, // Color cuando está deshabilitado
                padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.floppyDisk,
                    color: isViewMode
                        ? Colors.grey.shade500
                        : Colors.white, // Cambia el color del icono
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Guardar Cambios',
                    style: GoogleFonts.voces(
                      color: isViewMode
                          ? Colors.grey.shade500
                          : Colors.white, // Cambia el color del texto
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(size.width * 0.02),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size.width * 0.02),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: size.width * 0.05,
        ),
      ),
      SizedBox(width: size.width * 0.03),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.voces(
                color: Colors.grey[600],
                fontSize: size.width * 0.035,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.voces(
                color: Colors.black87,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildHighlightBox(
    String label, String value, IconData icon, Color color) {
  return Container(
    padding: EdgeInsets.all(size.width * 0.03),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(size.width * 0.02),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        FaIcon(
          icon,
          color: color,
          size: size.width * 0.06,
        ),
        SizedBox(height: size.width * 0.02),
        Text(
          label,
          style: GoogleFonts.voces(
            color: Colors.grey[600],
            fontSize: size.width * 0.035,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.voces(
            color: color,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEvidenciaButton(
    String label, IconData icon, Color color, VoidCallback onTap) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      final bool isViewMode = state.infoCorteType == InfoCorteType.view;
      final Color disabledColor = Colors.grey;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isViewMode ? null : onTap,
          borderRadius: BorderRadius.circular(size.width * 0.02),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.width * 0.02,
            ),
            decoration: BoxDecoration(
              color: isViewMode
                  ? disabledColor.withOpacity(0.1)
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.02),
              border: Border.all(
                color: isViewMode
                    ? disabledColor.withOpacity(0.3)
                    : color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  icon,
                  color: isViewMode ? disabledColor : color,
                  size: size.width * 0.06,
                ),
                SizedBox(height: size.width * 0.01),
                Text(
                  label,
                  style: GoogleFonts.voces(
                    color: isViewMode ? disabledColor : color,
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
