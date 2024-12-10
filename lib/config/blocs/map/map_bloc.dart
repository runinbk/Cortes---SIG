import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/constant/colors.const.dart';
import 'package:proyecto_sig/config/constant/dialog.const.dart';
import 'package:proyecto_sig/config/helpers/map.helpers.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoCorte.entitie.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoRuta.entitie.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final AuthBloc authBloc;
  GoogleMapController? mapController;
  StreamSubscription? gpsServiceSubscription;
  List<InfoCorte> infoCortesGeneral = [];
  List<InfoRuta> infoRutasGeneral = [];
  MapBloc({required this.authBloc}) : super(MapState()) {
    on<OnMapInitContent>((event, emit) async {
      Map<String, Marker> markers = {};

      // LOGIC : MARCADOR DE LA EMPRESA
      final marker = Marker(
        markerId: const MarkerId('ME'),
        position: const LatLng(-16.379681784255467, -60.96071984288463),
        icon: await HelperMap.getAssetImageMarker("assets/marcador-logo.png"),
        onTap: () {},
      );

      markers['ME'] = marker;

      List<InfoCorte> infoCortes = authBloc.state.infoCortes;
      infoCortesGeneral = infoCortes;
      infoRutasGeneral = authBloc.state.infoRutas;

      // LOGIC : MARCADOR TEMPORAL DE PUNTOS DE CORTE
      for (var i = 0; i < infoCortes.length; i++) {
        final infoCorte = infoCortes[i];
        final markerId = "MTPC$i";

        final marker = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(infoCorte.bscntlati, infoCorte.bscntlogi),
          icon: await HelperMap.getAssetImageMarker("assets/puntos-cortes.png"),
          onTap: () {
            authBloc.add(OnChangedInfoCorte(infoCorte));
            // emit(state.copyWith(urlAppMarcador: "/view-reporte"));
            add(OnGoNavigationMarcador());
            // event.context.push("/view-reporte");
          },
        );

        markers[markerId] = marker;
      }

      emit(state.copyWith(
        isMapInitialized: true,
        markers: markers,
      ));
    });

    on<OnGoogleMapController>((event, emit) {
      mapController = event.controller;
    });

    on<GpsAndPermissionEvent>((event, emit) {
      emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isPermissionGranted,
      ));
    });

    on<OnGenerarRuta>((event, emit) async {
      // 1. Limpieza inicial del estado
      emit(state.copyWith(
        markers: {},
        polylines: {},
      ));

      try {
        if (!event.context.mounted) return;

        // 2. Mostrar indicador de carga
        DialogService.showLoadingDialog(
            context: event.context,
            message: "Generando Ruta, espere por favor");

        // 3. Validación inicial de datos
        if (authBloc.state.rutaTrabajo.isEmpty) {
          throw Exception('No hay puntos de trabajo disponibles');
        }

// 4. Preparación y validación de puntos de trabajo
        List<LatLng> puntosTrabajoConvertidos = authBloc.state.rutaTrabajo
            .where((e) =>
                // Solo filtrar puntos que sean 0,0
                !(e.bscntlati == 0 && e.bscntlogi == 0))
            .map((e) => LatLng(e.bscntlati, e.bscntlogi))
            .toList();

        // 5. Optimización de ruta
        // Calcula la ruta más eficiente desde el punto inicial hasta todos los puntos de trabajo
        List<LatLng> puntosTrabajo = HelperMap.findOptimalRoute(
          const LatLng(
              -16.379681784255467, -60.96071984288463), // Punto inicial
          puntosTrabajoConvertidos,
        );

        // 6. Generación de polyline
        // Obtiene el código de ruta y lo decodifica para crear la línea de ruta
        String codigoRuta = await HelperMap.getRoutePuntosCorte(puntosTrabajo);
        List<PointLatLng> decodificacionCodigo =
            PolylinePoints().decodePolyline(codigoRuta);
        List<LatLng> puntosRuta = decodificacionCodigo
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList();

        // 7. Creación de polylines
        // Crea dos polylines: uno para el borde (más grueso) y otro para el centro (más delgado)
        final Map<String, Polyline> rutaPolylines = {
          'ruta_trabajo_borde': Polyline(
            polylineId: const PolylineId('ruta_trabajo_borde'),
            points: puntosRuta,
            color: Colors.black87,
            width: 8,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
          'ruta_trabajo_centro': Polyline(
            polylineId: const PolylineId('ruta_trabajo_centro'),
            points: puntosRuta,
            color: const Color(0xFF2196F3),
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        };

        // 8. Creación de marcadores
        final Map<String, Marker> marcadores = {};

        // 8.1 Marcador inicial (punto de partida)
        marcadores['MRTCFI'] = Marker(
          markerId: const MarkerId('MRTCFI'),
          position: puntosTrabajo[0],
          icon: await HelperMap.getAssetImageMarker("assets/marcador-logo.png"),
          onTap: () {},
        );

        // 8.2 Removemos el punto inicial para procesar solo los puntos de trabajo
        puntosTrabajo = puntosTrabajo.sublist(1);

        // 8.3 Creación de marcadores numerados para cada punto de trabajo
        for (int i = 0; i < puntosTrabajo.length; i++) {
          final puntoActual = puntosTrabajo[i];

          // Busca la información completa del punto de trabajo
          final elementoRutaTrabajo = authBloc.state.rutaTrabajo.firstWhere(
            (elemento) =>
                elemento.bscntlati == puntoActual.latitude &&
                elemento.bscntlogi == puntoActual.longitude,
            orElse: () => authBloc.state.rutaTrabajo[0],
          );

          // Genera el ícono numerado para el marcador
          final markerIcon = await HelperMap.getMarkerIcon(
            (i + 1).toString(),
            color: kPrimaryColor,
          );

          // Crea el marcador con información y comportamiento
          marcadores['${i + 1}MRTCF${elementoRutaTrabajo.bscocNcoc}'] = Marker(
            markerId: MarkerId('${i + 1}MRTCF${elementoRutaTrabajo.bscocNcoc}'),
            position: puntoActual,
            icon: markerIcon,
            onTap: () {
              authBloc.add(OnChangedInfoCorte(elementoRutaTrabajo));
              // emit(state.copyWith(urlAppMarcador: "/view-reporte"));
              add(OnGoNavigationMarcador());
            },
          );
        }

        // 9. Verificación final y emisión del estado
        if (!event.context.mounted) return;

        emit(state.copyWith(
          polylines: rutaPolylines,
          markers: marcadores,
        ));

        // 10. Limpieza de UI y navegación
        Navigator.of(event.context)
          ..pop() // Cierra el diálogo de carga
          ..pop(); // Vuelve a la pantalla del mapa
      } catch (e) {
        print('Error en OnGenerarRuta: $e');
        if (!event.context.mounted) return;

        // Manejo de errores y limpieza
        if (ModalRoute.of(event.context)?.isCurrent != true) {
          Navigator.of(event.context).pop();
        }

        DialogService.showErrorSnackBar(
            context: event.context,
            message: 'Error al generar la ruta, intente de nuevo');

        emit(state.copyWith(
          markers: {},
          polylines: {},
        ));
      }
    });

    on<OnChangedWorkMapType>((event, emit) {
      // emit(state.copyWith(workMapType: event.data));
      if (state.workMapType == WorkMapType.none) {
        emit(state.copyWith(workMapType: WorkMapType.inspeccionRuta));
      } else {
        emit(state.copyWith(workMapType: WorkMapType.none));
      }
    });

    on<OnChangeDetailMapGoogle>((event, emit) {
      emit(state.copyWith(detailMapGoogle: event.detail));
    });

    on<OnChangedTypeMovilidad>((event, emit) {
      emit(state.copyWith(typeMovilidad: event.data));
    });

    on<OnChangedInitRuta>((event, emit) {
      emit(state.copyWith(initRuta: event.data));
    });

    on<OnCleanBlocMapGoogle>((event, emit) {
      emit(state.copyWith(
          markers: {},
          polygons: {},
          polylines: {},
          detailMapGoogle: DetailMapGoogle.normal,
          typeMovilidad: TypeMovilidad.moto,
          initRuta: InitRuta.oficina,
          workMapType: WorkMapType.none));
    });

    on<OnGoNavigationMarcador>((event, emit) {
      emit(state.copyWith(urlAppMarcador: '/view-reporte'));
    });

    on<OnResetNavigationMarcador>((event, emit) {
      emit(state.copyWith(urlAppMarcador: ''));
    });

    on<OnEditPuntoCorteRutaTrabajo>((event, emit) async {
      try {
        // 1. Buscar el marcador que contiene el patrón MRTCF + bscocNcoc
        final targetMarkerId = 'MRTCF${event.infoCorte.bscocNcoc}';

        // Encontrar la key que contiene el patrón
        String? markerKey;
        state.markers.forEach((key, value) {
          if (key.contains(targetMarkerId)) {
            markerKey = key;
          }
        });

        if (markerKey != null) {
          final currentMarker = state.markers[markerKey]!;

          // 2. Extraer el número que va delante de MRTCF
          final orderNumber =
              RegExp(r'^(\d+)MRTCF').firstMatch(markerKey!)?.group(1);

          if (orderNumber == null) return;

          // 3. Determinar el color basado en el estado
          final Color markerColor = event.estado == "En Proceso"
              ? const Color(0xFFFF9800) // Naranja para estado "a"
              : const Color(0xFF43A047); // Verde para estado "b"

          // 4. Crear el nuevo icono con el número extraído
          final markerIcon = await HelperMap.getMarkerIcon(
            orderNumber, // Usamos el número de orden extraído
            color: markerColor,
          );

          // 5. Crear el nuevo marcador manteniendo la posición original
          final newMarker = Marker(
            markerId:
                MarkerId(markerKey!), // Mantenemos el ID original completo
            position: currentMarker.position,
            icon: markerIcon,
            onTap: () {},
          );

          // 6. Actualizar el mapa de marcadores
          final updatedMarkers = Map<String, Marker>.from(state.markers);
          updatedMarkers[markerKey!] = newMarker;

          // 7. Emitir el nuevo estado
          emit(state.copyWith(
            markers: updatedMarkers,
          ));
        }
      } catch (e) {
        print('Error en OnEditPuntoCorteRutaTrabajo: $e');
      }
    });

    // LOGIC : VERIFICAR GPS ESTADO Y PERMISO USO DE GPS
    _init();
  }

  // READ : METODOS DE USO A TODO LO REFENTE AL GPS
  Future<void> _init() async {
    final gpsInitStatus = await Future.wait([
      _chechGpsStatus(),
      _isPermissionGranted(),
    ]);

    add(GpsAndPermissionEvent(
      isGpsEnabled: gpsInitStatus[0],
      isPermissionGranted: gpsInitStatus[1],
    ));
  }

  Future<bool> _chechGpsStatus() async {
    final isGpsEnabled = await Permission.location.serviceStatus.isEnabled;
    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isGpsEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
        isGpsEnabled: isGpsEnabled,
        isPermissionGranted: state.isGpsPermissionGranted,
      ));
    });

    return isGpsEnabled;
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled,
          isPermissionGranted: true,
        ));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.provisional:
        add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled,
          isPermissionGranted: false,
        ));
        openAppSettings();
        break;
    }
  }

  Future<Position> getActualLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  @override
  Future<void> close() {
    gpsServiceSubscription!.cancel();
    return super.close();
  }
}
