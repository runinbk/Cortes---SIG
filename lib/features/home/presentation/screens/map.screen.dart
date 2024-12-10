import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/blocs/location/location_bloc.dart';
import 'package:proyecto_sig/config/blocs/map/map_bloc.dart';
import 'package:proyecto_sig/config/constant/const.dart';
import 'package:proyecto_sig/features/home/presentation/screens/map-loading.screen.dart';
import 'package:proyecto_sig/features/home/presentation/widgets/map-view.dart';
import 'package:readmore/readmore.dart';

class MapGoogleScreen extends StatefulWidget {
  const MapGoogleScreen({super.key});

  @override
  State<MapGoogleScreen> createState() => _MapGoogleScreenState();
}

class _MapGoogleScreenState extends State<MapGoogleScreen> {
  late MapBloc _mapBloc;
  late AuthBloc _authBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapBloc = BlocProvider.of<MapBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapBloc.add(const OnCleanBlocMapGoogle());
    _authBloc.add(const OnCleanBlocAuth());
    super.dispose();
  }

  Future<void> _initLocation() async {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    // final mapBloc = BlocProvider.of<MapBloc>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);
    await locationBloc.getActualPosition();
    if (!mounted) return;
    authBloc.add(OnProcessInfoRutas(context));
    authBloc.add(OnProcessInfoCortes(tipoCorte: 73, context: context));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (locationState.lastKnownLocation == null ||
                authState.infoRutas.isEmpty ||
                authState.infoCortes.isEmpty) {
              return const MapLoading();
            } else {}

            return Stack(
              children: [
                BlocListener<MapBloc, MapState>(
                  listener: (context, state) {
                    if (state.urlAppMarcador != "") {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.push('/view-reporte');
                        BlocProvider.of<MapBloc>(context)
                            .add(const OnResetNavigationMarcador());
                      });
                    }
                  },
                  child: BlocBuilder<MapBloc, MapState>(
                    builder: (context, mapState) {
                      return MapViewGoogleMap(
                        initialLocation: const LatLng(
                            -16.379681784255467, -60.96071984288463),
                        polygons: mapState.polygons.values.toSet(),
                        polylines: mapState.polylines.values.toSet(),
                        markers: mapState.markers.values.toSet(),
                      );
                    },
                  ),
                ),
                // READ : Acciones del mapa
                _construccionAccionesMap(size, context),
                // READ : Custom Map Button
                const IconCustomSearch(),
                // READ : VIEW WINDOW INFO
                mapBloc.state.workMapType == WorkMapType.inspeccionRuta
                    ? const WindowViewInspeccionRuta()
                    : Container()
              ],
            );
          },
        );
      },
    );
  }
}

class LogoCustomServicios extends StatelessWidget {
  const LogoCustomServicios({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final size = MediaQuery.of(context).size;

    final decoration2 = BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: kPrimaryColor,
        width: 4,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(0, 6),
        ),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onDoubleTap: () {
          // authBloc.add(const OnChangedViewInfo());
        },
        child: Container(
          width: size.width * 0.2,
          height: size.width * 0.2,
          decoration: decoration2,
          padding: EdgeInsets.all(size.width * 0.01),
          child: Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class LogoCustomMicros extends StatelessWidget {
  const LogoCustomMicros({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onDoubleTap: () {
          // authBloc.add(const OnChangedViewInfo());
        },
        child: Container(
          padding: EdgeInsets.only(
            left: size.width * 0.04,
          ),
          color: Colors.transparent,
          width: size.width * 0.45,
          height: size.width * 0.25,
          child: Image.asset(
            "assets/logo-moto.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class WindowViewDetalleRuta extends StatelessWidget {
  const WindowViewDetalleRuta({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 1,
        builder: (context, scrollController) {
          return Material(
            color: Colors.transparent,
            child: Container(
              height: size.height * 0.8,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * 0.02),
                      topRight: Radius.circular(size.width * 0.02))),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: size.width * 0.1),
                      child: Container(
                        padding: EdgeInsets.only(top: size.width * 0.09),
                        width: size.width,
                        decoration: BoxDecoration(
                          border: const Border(
                            top: BorderSide(
                              color: kPrimaryColor,
                              width: 8,
                            ),
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: -2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size.width * 0.05),
                            topRight: Radius.circular(size.width * 0.05),
                          ),
                        ),
                        child: Column(
                          children: [],
                        ),
                      ),
                    ),
                    // Logo container at top
                    const LogoCustomServicios(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class TarjetaPersonalizada extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const TarjetaPersonalizada({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class TarjetaDetalle extends StatelessWidget {
  final Size size;
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool esDescripcion;

  const TarjetaDetalle({
    Key? key,
    required this.size,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    this.esDescripcion = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = size.width * 0.03;

    return TarjetaPersonalizada(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: FaIcon(icono, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 15),
              Text(
                titulo,
                style: letterStyle.letra2Mapa,
              ),
            ],
          ),
          const SizedBox(height: 15),
          esDescripcion
              ? ReadMoreText(
                  subtitulo,
                  style: letterStyle.letra3Mapa,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Ver más',
                  trimExpandedText: 'Ver menos',
                  moreStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  lessStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  subtitulo,
                  style: letterStyle.letra3Mapa,
                ),
        ],
      ),
    );
  }
}

class WindowViewInspeccionRuta extends StatefulWidget {
  const WindowViewInspeccionRuta({super.key});

  @override
  State<WindowViewInspeccionRuta> createState() =>
      _WindowViewInspeccionRutaState();
}

class _WindowViewInspeccionRutaState extends State<WindowViewInspeccionRuta>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  bool isRunning = false;
  int cortesRealizados = 0;
  List<CorteInfo> registroCortes = [];
  DateTime? horaInicio;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..addListener(() {
        if (_timerController.value == 1.0) {
          _timerController.reset();
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      if (isRunning) {
        _timerController.stop();
      } else {
        horaInicio ??= DateTime.now();
        _timerController.forward();
      }
      isRunning = !isRunning;
    });
  }

  void _registrarCorte() {
    if (cortesRealizados < 9) {
      setState(() {
        cortesRealizados++;
        registroCortes.add(CorteInfo(
          numero: cortesRealizados,
          horaInicio: horaInicio!,
          horaCorte: DateTime.now(),
        ));
      });
    }
  }

  void _cancelarTodo() {
    setState(() {
      _timerController.reset();
      isRunning = false;
      cortesRealizados = 0;
      registroCortes.clear();
      horaInicio = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTimer(size),
                      const SizedBox(height: 24),
                      _buildControls(context),
                      if (registroCortes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildRegistroCortes(),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildHeader() => Column(
        children: [
          Text(
            'Control de Cortes de Agua',
            style: GoogleFonts.voces(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          if (horaInicio != null) ...[
            const SizedBox(height: 8),
            Text(
              'Inicio: ${DateFormat('HH:mm').format(horaInicio!)}',
              style: GoogleFonts.voces(
                fontSize: 16,
                color: kTerciaryColor,
              ),
            ),
          ],
        ],
      );

  Widget _buildTimer(Size size) => Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size.width * 0.45,
                height: size.width * 0.45,
                child: CircularProgressIndicator(
                  value: _timerController.value,
                  strokeWidth: 15,
                  backgroundColor: Colors.grey.shade200,
                  color: isRunning ? kQuintaColor : kTerciaryColor,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${((1 - _timerController.value) * 60).toInt()}:${((1 - _timerController.value) * 3600 % 60).toInt().toString().padLeft(2, '0')}',
                    style: GoogleFonts.voces(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  '$cortesRealizados de 9 cortes realizados',
                  style: GoogleFonts.voces(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildControls(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            onPressed: _toggleTimer,
            icon: isRunning
                ? Icons.pause_circle_outlined
                : Icons.play_circle_outlined,
            label: isRunning ? 'Pausar' : 'Iniciar',
            color: isRunning ? kTerciaryColor : kQuintaColor,
          ),
          _buildButton(
            onPressed:
                isRunning && cortesRealizados < 9 ? _registrarCorte : null,
            icon: Icons.water_drop_outlined,
            label: 'Registrar Corte',
            color: kPrimaryColor,
          ),
          _buildButton(
            onPressed: () {
              final mapBloc = BlocProvider.of<MapBloc>(context);
              // Aquí puedes agregar tu lógica para ocultar
              mapBloc.add(const OnChangedWorkMapType());
            },
            icon: Icons.visibility_off_outlined,
            label: 'Ocultar',
            color: kTerciaryColor,
          ),
          _buildButton(
            onPressed: _cancelarTodo,
            icon: Icons.cancel_outlined,
            label: 'Cancelar',
            color: Colors.red.shade400,
          ),
        ],
      );

  Widget _buildButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Column(
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed == null ? Colors.grey.shade300 : color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
              elevation: onPressed == null ? 0 : 4,
            ),
            child: Icon(icon, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.voces(
              fontSize: 14,
              color: onPressed == null ? Colors.grey : color,
            ),
          ),
        ],
      );

  Widget _buildRegistroCortes() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro de Cortes',
            style: GoogleFonts.voces(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...registroCortes.map((corte) => _buildCorteItem(corte)).toList(),
        ],
      );

  Widget _buildCorteItem(CorteInfo corte) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kQuintaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${corte.numero}',
                  style: GoogleFonts.voces(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kQuintaColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('HH:mm:ss').format(corte.horaCorte),
                    style: GoogleFonts.voces(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  Text(
                    'Duración: ${corte.getDuracion()}',
                    style: GoogleFonts.voces(
                      fontSize: 14,
                      color: kTerciaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class CorteInfo {
  final int numero;
  final DateTime horaInicio;
  final DateTime horaCorte;

  CorteInfo({
    required this.numero,
    required this.horaInicio,
    required this.horaCorte,
  });

  String getDuracion() {
    final duracion = horaCorte.difference(horaInicio);
    final minutos = duracion.inMinutes;
    final segundos = duracion.inSeconds % 60;
    return '${minutos}m ${segundos}s';
  }
}

Widget _buildMapActionButton({
  required IconData icon,
  required VoidCallback onPressed,
  required Size size,
}) {
  return Padding(
    padding: EdgeInsets.only(
      left: size.width * 0.01,
      top: size.height * 0.01,
      right: size.width * 0.01,
    ),
    child: FloatingActionButton(
      heroTag: icon.codePoint.toString(),
      mini: true,
      backgroundColor: Colors.white.withOpacity(0.90),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: kPrimaryColor,
        size: size.width * 0.06,
      ),
    ),
  );
}

Widget _construccionAccionesMap(Size size, BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

  final List<MapAction> actionsInformativo = [
    MapAction(
      icon: FontAwesomeIcons.locationCrosshairs,
      onPressed: () {},
    ),
    MapAction(
      // icon: FontAwesomeIcons.personWalking,
      icon: FontAwesomeIcons.person,
      onPressed: () {
        // if (MapBloc.state.typeServicio == TypeServicio.serviciosPublicos) {
        //   MapBloc.add(const OnChangedTypeServicio(TypeServicio.micros));
        // } else {
        //   MapBloc.add(
        //       const OnChangedTypeServicio(TypeServicio.serviciosPublicos));
        // }
      },
    ),
    MapAction(
      icon: FontAwesomeIcons.compass,
      onPressed: () {},
    ),
    MapAction(
      icon: FontAwesomeIcons.diamondTurnRight, // Múltiples caminos
      onPressed: () {
        context.push("/multiples-rutas");
      },
    ),
    MapAction(
      icon: FontAwesomeIcons.upRightAndDownLeftFromCenter,
      onPressed: () {
        mapBloc.add(const OnChangedWorkMapType());
      },
    ),
  ];

  return Padding(
    padding: EdgeInsets.only(right: size.width * 0.01),
    child: Align(
      alignment: Alignment.bottomRight,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actionsInformativo
              .map((action) => _buildMapActionButton(
                    icon: action.icon,
                    onPressed: action.onPressed,
                    size: size,
                  ))
              .toList()),
    ),
  );
}

class MapAction {
  final IconData icon;
  final VoidCallback onPressed;

  const MapAction({
    required this.icon,
    required this.onPressed,
  });
}

class IconCustomSearch extends StatelessWidget {
  const IconCustomSearch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.04,
        left: size.width * 0.01,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            context.push("/list-reportes");
          },
          child: Container(
            width: size.width * 0.14, // Aumentado tamaño
            height: size.width * 0.14, // Mantener proporción cuadrada
            decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]),
            child: Container(
              margin: EdgeInsets.all(size.width * 0.02), // Margen uniforme
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.searchengin,
                color: kPrimaryColor,
                size: size.width * 0.075, // Ajustado tamaño del icono
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showMapLayersDialog(BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(),
        ),
      );
    },
  );
}
