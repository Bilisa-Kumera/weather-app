import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/usecases/get_saved_city.dart';
import '../../../domain/usecases/save_city.dart';

part 'city_event.dart';
part 'city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  CityBloc({required GetSavedCity getSavedCity, required SaveCity saveCity})
      : _getSavedCity = getSavedCity,
        _saveCity = saveCity,
        super(const CityState()) {
    on<LoadSavedCity>(_onLoadSavedCity);
    on<SelectCity>(_onSelectCity);
  }

  final GetSavedCity _getSavedCity;
  final SaveCity _saveCity;

  Future<void> _onLoadSavedCity(
    LoadSavedCity event,
    Emitter<CityState> emit,
  ) async {
    emit(state.copyWith(status: CityStatus.loading));
    try {
      final city = await _getSavedCity();
      if (city == null) {
        emit(state.copyWith(status: CityStatus.empty));
      } else {
        emit(state.copyWith(status: CityStatus.success, selectedCity: city));
      }
    } on Failure catch (e) {
      emit(state.copyWith(status: CityStatus.failure, message: e.message));
    } catch (_) {
      emit(state.copyWith(status: CityStatus.failure, message: 'Failed to load city'));
    }
  }

  Future<void> _onSelectCity(
    SelectCity event,
    Emitter<CityState> emit,
  ) async {
    try {
      await _saveCity(event.city);
      emit(state.copyWith(status: CityStatus.success, selectedCity: event.city));
    } on Failure catch (e) {
      emit(state.copyWith(status: CityStatus.failure, message: e.message));
    } catch (_) {
      emit(state.copyWith(status: CityStatus.failure, message: 'Failed to save city'));
    }
  }
}
