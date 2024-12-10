import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_sig/config/constant/dialog.const.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoCorte.entitie.dart';
import 'package:proyecto_sig/features/home/domain/entities/infoRuta.entitie.dart';
import 'package:proyecto_sig/features/home/infrastructure/repositories/home.repositorie.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final homeRepositorieImpl = HomeRepositorieImpl();
  List<InfoCorte> rutaCortesGeneral = [];
  List<InfoRuta> rutasGeneral = [];
  AuthBloc() : super(const AuthState()) {
    on<OnAuthenticating>((event, emit) async {
      try {
        // Esto está bien porque es antes de cualquier operación async
        DialogService.showLoadingDialog(
            context: event.context, message: 'Autenticando...');

        // await Future.delayed(const Duration(seconds: 10));
        final response = await homeRepositorieImpl.postAuthenticating(
            codigo: event.codigo,
            password: event.password); // otra operación async

        emit(state.copyWith(codigoFuncionario: response));

        // Después de operaciones async, necesitamos verificar si el widget aún está montado
        if (!event.context.mounted) return;

        Navigator.of(event.context).pop();
        event.context.push('/map');
      } catch (e) {
        // Aquí también necesitamos verificar porque estamos después de operaciones async
        if (!event.context.mounted) return;

        Navigator.of(event.context).pop();
        DialogService.showErrorSnackBar(
            context: event.context,
            message: 'Error al autenticar, intente de nuevo');
      }
    });

    on<OnProcessInfoRutas>((event, emit) async {
      try {
        List<InfoRuta> response =
            await homeRepositorieImpl.postObtenerRutasUtilizar();
        rutasGeneral = response;

        // Buscar elemento con bsrutnrut 73
        final rutaBuscada = response.firstWhere(
          (ruta) => ruta.routeId == 73,
          orElse: () => response.first,
        );

        emit(state.copyWith(
          infoRutas: response,
          infoRuta: rutaBuscada,
        ));
      } catch (e) {
        if (!event.context.mounted) return;

        DialogService.showErrorSnackBar(
            context: event.context,
            message: 'Error al obtener rutas, intente de nuevo');
      }
    });

    on<OnProcessInfoCortes>((event, emit) async {
      try {
        List<InfoCorte> response = await homeRepositorieImpl
            .postObtenerListaQuienCortar(tipoRuta: event.tipoCorte);
        rutaCortesGeneral = response;
        emit(state.copyWith(infoCortes: response));
      } catch (e) {
        if (!event.context.mounted) return;

        DialogService.showErrorSnackBar(
            context: event.context,
            message: 'Error al obtener la lista de cortes');
      }
    });

    on<OnEditRutaTrabajo>((event, emit) {
      final List<InfoCorte> currentRutas = List.from(state.rutaTrabajo);

      // Buscar si la ruta ya existe
      final int index = currentRutas
          .indexWhere((ruta) => ruta.bscntCodf == event.infoCorte.bscntCodf);

      if (index >= 0) {
        // Si existe, remover
        currentRutas.removeAt(index);
      } else {
        // Verificar límite antes de agregar
        if (currentRutas.length >= 9) {
          return; // Sale si ya hay 9 o más elementos
        }
        // Si no existe y no excede límite, agregar
        currentRutas.add(event.infoCorte);
      }

      // Emitir nuevo estado
      emit(state.copyWith(
        rutaTrabajo: currentRutas,
      ));
    });

    on<OnChangedInfoCorte>((event, emit) {
      emit(state.copyWith(infoCorte: event.infoCorte));
    });

    on<OnChangedInfoRuta>((event, emit) async {
      emit(state.copyWith(infoRuta: null, rutaTrabajo: []));
      add(OnProcessInfoCortes(
          tipoCorte: event.infoRuta.routeId, context: event.context));
      emit(state.copyWith(infoRuta: event.infoRuta));
    });

    on<OnCleanBlocAuth>((event, emit) {
      emit(state.copyWith(
          infoCorte: null,
          viewWindowInfo: false,
          infoRuta: null,
          rutaTrabajo: [],
          infoCorteType: InfoCorteType.view));
    });

    on<OnChangeInfoCorteType>((event, emit) {
      emit(state.copyWith(infoCorteType: event.data));
    });
  }
}
