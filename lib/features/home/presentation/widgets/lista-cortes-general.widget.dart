import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_sig/config/blocs/auth/auth_bloc.dart';
import 'package:proyecto_sig/config/constant/const.dart';
import 'package:proyecto_sig/config/constant/dialog.const.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoCorte.entitie.dart';

class CortesListView extends StatelessWidget {
  const CortesListView({super.key, required this.listaCorteBeta});

  final List<InfoCorte> listaCorteBeta;

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      itemCount: authBloc.state.infoCortes.length,
      itemBuilder: (context, index) {
        final corte = authBloc.state.infoCortes[index];
        return Container(
          margin: EdgeInsets.only(bottom: size.width * 0.03),
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
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  children: [
                    // Avatar del usuario
                    CircleAvatar(
                      radius: size.width * 0.06,
                      backgroundColor: kPrimaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    // Información del usuario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            corte.dNomb,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF00ACC1),
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.width * 0.01),
                          Text(
                            corte.dLotes,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Checkbox
                    CheckBoxCustom(
                      corte: corte,
                      onBlocEvent: () {
                        authBloc.add(OnChangedInfoCorte(corte));
                        authBloc.add(OnEditRutaTrabajo(corte));
                      },
                    ),
                  ],
                ),
              ),
              // Información de detalles
              Container(
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                padding: EdgeInsets.symmetric(vertical: size.width * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Medidor
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.speed,
                            color: Colors.indigo,
                            size: size.width * 0.05,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Med: ${corte.bsmedNume}',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildVerticalDivider(size),

                    // Monto
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bs',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: size.width * 0.03,
                            ),
                          ),
                          Text(
                            '${corte.bscocImor}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildVerticalDivider(size),

                    // Tiempo
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.orange[700],
                            size: size.width * 0.05,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${corte.bscocNmor} meses',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Observaciones si existen
              if (corte.dCobc.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(
                    top: size.width * 0.03,
                    left: size.width * 0.04,
                    right: size.width * 0.04,
                    bottom: size.width * 0.04,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(size.width * 0.02),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[800],
                        size: size.width * 0.045,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Text(
                          corte.dCobc,
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider(Size size) {
    return Container(
      height: size.width * 0.08,
      width: 1,
      color: Colors.grey[300],
    );
  }
}

class CheckBoxCustom extends StatelessWidget {
  final Function() onBlocEvent;
  final InfoCorte corte; // Añadir el corte como parámetro

  const CheckBoxCustom({
    super.key,
    required this.onBlocEvent,
    required this.corte, // Requerir el corte
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: true);

    // Corregir la comparación usando el corte específico
    final isChecked = authBloc.state.rutaTrabajo
        .any((elemento) => elemento.bscocNcoc == corte.bscocNcoc);

    return Transform.scale(
      scale: 1.1,
      child: SizedBox(
        width: size.width * 0.06,
        height: size.width * 0.06,
        child: Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            if (value == false) {
              onBlocEvent();
              return;
            }

            if (authBloc.state.rutaTrabajo.length >= 9) {
              DialogService.showErrorSnackBar(
                  message: "Solo puede crear una ruta de 9 puntos.",
                  context: context);
              return;
            }

            onBlocEvent();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          activeColor: kQuintaColor,
        ),
      ),
    );
  }
}
