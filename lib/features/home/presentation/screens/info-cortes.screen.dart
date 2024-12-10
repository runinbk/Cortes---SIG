// cortes_dashboard_screen.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/blocs/map/map_bloc.dart';
import 'package:proyecto_sig/config/constant/const.dart';
import 'package:proyecto_sig/config/constant/dialog.const.dart';
import 'package:proyecto_sig/features/home/presentation/widgets/lista-cortes-general.widget.dart';
import 'package:proyecto_sig/features/home/presentation/widgets/lista-cortes-realizados.widget.dart';
import 'package:proyecto_sig/features/home/presentation/widgets/lista-rutas-creadas.widget.dart';

class CortesDashboardScreen extends StatelessWidget {
  const CortesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.sliders,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(top: size.height * 0.45),
                      child: Material(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(size.width * 0.03)),
                        child: Column(
                          children: [
                            _contruirManejadorArrastre(),
                            _construirEncabezadoAjustes(letterStyle, context),
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  _construirOpcionesMapa(letterStyle, context),
                                  _construirOpcionesRuta(letterStyle),
                                  _buildTransportOptions(letterStyle, context),
                                  _buildStartPoint(letterStyle, context),
                                  _buildWorkStatus(letterStyle, context),
                                  _buildActionButtons(letterStyle, context),
                                  SizedBox(height: size.height * 0.03),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
          title: Text(
            'CONTROL DE CORTES',
            style: letterStyle.letra4Mapa.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(size.height * 0.08),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.9)],
                ),
              ),
              child: TabBar(
                indicatorColor: kQuintaColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kQuintaColor),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.white),
                tabs: [
                  Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.listCheck,
                      size: size.width * 0.05,
                    ),
                    text: 'Cortes',
                  ),
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.checkDouble,
                        size: size.width * 0.05),
                    text: 'Realizados',
                  ),
                  Tab(
                    icon:
                        FaIcon(FontAwesomeIcons.route, size: size.width * 0.05),
                    text: 'Rutas',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                margin: EdgeInsets.all(size.width * 0.04),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.magnifyingGlass,
                        color: kCuartoColor, size: size.width * 0.05),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: TextField(
                        style: letterStyle.letraInput.copyWith(
                          fontSize: size.width * 0.04,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o dirección...',
                          hintStyle: letterStyle.placeholderInput,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CortesListView(listaCorteBeta: listaCorteBeta),
                  CortesRealizadosView(listaCorteBeta: listaCorteBeta),
                  const RutasCreatedView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _contruirManejadorArrastre() => Center(
      child: Container(
        margin: EdgeInsets.only(top: size.height * 0.025),
        width: size.width * 0.1,
        height: size.width * 0.01,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

Widget _construirEncabezadoAjustes(LetterStyle style, BuildContext context) =>
    Container(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          Text('Opciones de navegación',
              style: style.letra1Mapa.copyWith(fontSize: size.width * 0.05)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.close, color: kPrimaryColor),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );

Widget _construirOpcionesMapa(LetterStyle style, BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

  return Column(
    children: [
      _construirTituloSeccion('Tipo de mapa', style),
      _construirCuadriculaTipoMapa([
        _MapOption(
          'Normal',
          Icons.map_outlined,
          () {
            mapBloc.add(const OnChangeDetailMapGoogle(DetailMapGoogle.normal));
          },
          mapBloc.state.detailMapGoogle == DetailMapGoogle.normal,
        ),
        _MapOption(
          'Satélite',
          Icons.satellite_outlined,
          () {
            mapBloc
                .add(const OnChangeDetailMapGoogle(DetailMapGoogle.satellite));
          },
          mapBloc.state.detailMapGoogle == DetailMapGoogle.satellite,
        ),
        _MapOption(
          'Híbrido',
          Icons.layers_outlined,
          () {
            mapBloc.add(const OnChangeDetailMapGoogle(DetailMapGoogle.hybrid));
          },
          mapBloc.state.detailMapGoogle == DetailMapGoogle.hybrid,
        ),
        _MapOption(
          'Terreno',
          Icons.terrain_outlined,
          () {
            mapBloc.add(const OnChangeDetailMapGoogle(DetailMapGoogle.terrain));
          },
          mapBloc.state.detailMapGoogle == DetailMapGoogle.terrain,
        ),
      ]),
      Divider(height: size.height * 0.03),
    ],
  );
}

Widget _construirOpcionesRuta(LetterStyle style) => Column(
      children: [
        _construirTituloSeccion('Opciones de ruta', style),
        const CustomInterruptorAjustes(
          title: 'Evitar peajes',
          icon: Icons.money_off_outlined,
        ),
        const CustomInterruptorAjustes(
          title: 'Evitar autopistas',
          icon: Icons.directions_car_outlined,
        ),
        const CustomInterruptorAjustes(
          title: 'Rutas alternativas',
          icon: Icons.alt_route_outlined,
        ),
        Divider(height: size.height * 0.03),
      ],
    );

class CustomInterruptorAjustes extends StatefulWidget {
  const CustomInterruptorAjustes({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  State<CustomInterruptorAjustes> createState() =>
      _CustomInterruptorAjustesState();
}

class _CustomInterruptorAjustesState extends State<CustomInterruptorAjustes> {
  bool value = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: kPrimaryColor),
      title: Text(widget.title, style: letterStyle.letra3Mapa),
      trailing: Switch.adaptive(
        value: value,
        onChanged: (_) {
          setState(() {
            value = !value;
          });
        },
        activeColor: kQuintaColor,
      ),
    );
  }
}

Widget _buildTransportOptions(LetterStyle style, BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

  return Column(
    children: [
      _construirTituloSeccion('Modo de transporte', style),
      _buildTransportGrid([
        _TransportOption(
          'Auto',
          Icons.directions_car,
          mapBloc.state.typeMovilidad == TypeMovilidad.auto,
          () {
            mapBloc.add(const OnChangedTypeMovilidad(TypeMovilidad.auto));
          },
        ),
        _TransportOption('Moto', Icons.two_wheeler,
            mapBloc.state.typeMovilidad == TypeMovilidad.moto, () {
          mapBloc.add(const OnChangedTypeMovilidad(TypeMovilidad.moto));
        }),
        _TransportOption('Bicicleta', Icons.directions_bike,
            mapBloc.state.typeMovilidad == TypeMovilidad.bicicleta, () {
          mapBloc.add(const OnChangedTypeMovilidad(TypeMovilidad.bicicleta));
        }),
        _TransportOption('Caminar', Icons.directions_walk,
            mapBloc.state.typeMovilidad == TypeMovilidad.caminar, () {
          mapBloc.add(const OnChangedTypeMovilidad(TypeMovilidad.caminar));
        }),
      ]),
      Divider(height: size.height * 0.03),
    ],
  );
}

Widget _construirTituloSeccion(String title, LetterStyle style) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: style.letra2Mapa.copyWith(
            color: kPrimaryColor,
            fontWeight: FontWeight.w500,
          )),
    );

Widget _construirCuadriculaTipoMapa(List<_MapOption> options) => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      children: options.map((opt) => _construirOpcionTipoMapa(opt)).toList(),
    );

Widget _construirOpcionTipoMapa(_MapOption option) {
  return Card(
    elevation: option.selected ? 2 : 0,
    color: option.selected
        ? kPrimaryColor.withOpacity(0.03)
        : Colors.grey.shade100,
    margin: EdgeInsets.all(size.width * 0.02),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(size.width * 0.03),
      side: BorderSide(
        color: option.selected ? kPrimaryColor : Colors.transparent,
        width: 2,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(size.width * 0.03),
      onTap: option.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            option.icon,
            color: option.selected ? kPrimaryColor : Colors.grey,
            size: size.width * 0.06, // Ajustar tamaño del icono
          ),
          SizedBox(height: size.width * 0.02),
          Text(
            option.name,
            style: TextStyle(
              fontSize: size.width * 0.03,
              fontWeight: option.selected
                  ? FontWeight.bold
                  : FontWeight.normal, // Texto en negrita si está seleccionado
              color: option.selected ? kPrimaryColor : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTransportGrid(List<_TransportOption> options) => GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: options.map((opt) => _buildTransportOption(opt)).toList(),
    );

Widget _buildTransportOption(_TransportOption option) => Card(
      elevation: 0,
      color: option.selected
          ? kQuintaColor.withOpacity(0.1)
          : Colors.grey.shade100,
      margin: EdgeInsets.all(size.width * 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: option.selected ? kQuintaColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon,
                color: option.selected ? kQuintaColor : kPrimaryColor),
            SizedBox(height: size.width * 0.02),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 12,
                color: option.selected ? kQuintaColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

Widget _buildStartPoint(LetterStyle style, BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);

  List<InitRutaState> estados = [
    InitRutaState(
      tipo: InitRuta.none,
      isSelected: mapBloc.state.initRuta == InitRuta.none,
      onTap: () {
        mapBloc.add(const OnChangedInitRuta(InitRuta.none));
      },
    ),
    InitRutaState(
      tipo: InitRuta.oficina,
      isSelected: mapBloc.state.initRuta == InitRuta.oficina,
      onTap: () {
        mapBloc.add(const OnChangedInitRuta(InitRuta.oficina));
      },
    ),
    InitRutaState(
      tipo: InitRuta.posicion,
      isSelected: mapBloc.state.initRuta == InitRuta.posicion,
      onTap: () {
        mapBloc.add(const OnChangedInitRuta(InitRuta.posicion));
      },
    ),
  ];

  return Column(
    children: [
      _construirTituloSeccion('Punto de inicio', style),
      Container(
        height: size.height * 0.06,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: estados.length,
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (_, __) => SizedBox(width: size.width * 0.08),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            final estado = estados[i];
            return ActionChip(
              label: Text(estado.tipo.name.toUpperCase()),
              labelStyle: style.letra5Mapa.copyWith(
                color: estado.isSelected ? Colors.white : kPrimaryColor,
              ),
              backgroundColor:
                  estado.isSelected ? kQuintaColor : Colors.grey.shade100,
              onPressed: estado.onTap,
            );
          },
        ),
      ),
      Divider(height: size.height * 0.03),
    ],
  );
}

Widget _buildWorkStatus(LetterStyle style, BuildContext context) {
  final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);

  List<InfoCorteTypeState> estados = [
    InfoCorteTypeState(
      titulo: 'Ver detalles punto de corte',
      isSelected: authBloc.state.infoCorteType == InfoCorteType.view,
      onTap: () {
        authBloc.add(const OnChangeInfoCorteType(InfoCorteType.view));
      },
    ),
    InfoCorteTypeState(
      titulo: 'Actualizar un punto de corte',
      isSelected: authBloc.state.infoCorteType == InfoCorteType.update,
      onTap: () {
        authBloc.add(const OnChangeInfoCorteType(InfoCorteType.update));
      },
    ),
  ];

  return Column(
    children: [
      _construirTituloSeccion('Estado de trabajo', style),
      ...estados.map((estado) => RadioListTile<InfoCorteType>(
            title: Text(estado.titulo, style: style.letra3Mapa),
            value: estado == estados[0]
                ? InfoCorteType.view
                : InfoCorteType.update,
            groupValue: authBloc.state.infoCorteType,
            onChanged: (_) => estado.onTap(),
            activeColor: kQuintaColor,
          )),
    ],
  );
}

Widget _buildActionButtons(LetterStyle style, BuildContext context) {
  final mapBloc = BlocProvider.of<MapBloc>(context, listen: true);
  final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text('RESTABLECER',
                style: GoogleFonts.voces(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: kTerciaryColor,
              padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
            ),
            onPressed: () async {
              //LOGIC : Restablecer valores AUTHBLOC Y MAPBLOC
              mapBloc.add(const OnCleanBlocMapGoogle());
              authBloc.add(const OnCleanBlocAuth());
              mapBloc.add(OnMapInitContent(context));
            },
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.navigation, color: Colors.white),
            label: Text('GENERAR RUTA',
                style: GoogleFonts.voces(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
            ),
            onPressed: () async {
              if (authBloc.state.rutaTrabajo.length >= 9) {
                authBloc.add(const OnChangeInfoCorteType(InfoCorteType.update));
                mapBloc.add(OnGenerarRuta(context));
              } else {
                // Navigator.pop(context);
                Navigator.pop(context);
                DialogService.showErrorSnackBar(
                    message:
                        "No se puede generar una ruta con menos de 9 puntos de corte.",
                    context: context);
              }
            },
          ),
        ),
      ],
    ),
  );
}

class _MapOption {
  final String name;
  final IconData icon;
  final GestureTapCallback onTap;
  final bool selected;
  _MapOption(this.name, this.icon, this.onTap, this.selected);
}

class _TransportOption {
  final String name;
  final IconData icon;
  final GestureTapCallback onTap;
  final bool selected;
  _TransportOption(this.name, this.icon, this.selected, this.onTap);
}

class InitRutaState {
  final InitRuta tipo;
  final bool isSelected;
  final GestureTapCallback onTap;

  InitRutaState({
    required this.tipo,
    this.isSelected = false,
    required this.onTap,
  });
}

class InfoCorteTypeState {
  final String titulo;
  final bool isSelected;
  final GestureTapCallback onTap;

  InfoCorteTypeState({
    required this.titulo,
    this.isSelected = false,
    required this.onTap,
  });
}
