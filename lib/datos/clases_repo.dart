import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/clase.dart';
import '../modelos/rutina.dart';
import 'demo_db.dart';

/// Acceso a clases dirigidas y rutinas.
class ClasesRepo {
  ClasesRepo._();
  static final ClasesRepo instancia = ClasesRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  // --- Clases ---------------------------------------------------------------

  Future<List<Clase>> listarClases() async {
    if (!ConfigSupabase.configurado) {
      final lista = List<Clase>.from(DemoDB.instancia.clases);
      lista.sort((a, b) => a.diaSemana.compareTo(b.diaSemana));
      return lista;
    }
    try {
      final filas = await _db.from('clases').select().order('dia_semana');
      return filas
          .map((f) => Clase.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar las clases.');
    }
  }

  Future<Clase> guardarClase(Clase clase) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.clases.indexWhere((c) => c.id == clase.id);
      if (i == -1) {
        db.clases.add(clase.copyWith());
      } else {
        db.clases[i] = clase;
      }
      return clase;
    }
    try {
      if (clase.id.isEmpty) {
        final fila = await _db
            .from('clases')
            .insert(clase.aMapa()..remove('id'))
            .select()
            .single();
        return Clase.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('clases').upsert(clase.aMapa());
      return clase;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar la clase.');
    }
  }

  Future<void> eliminarClase(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.clases.removeWhere((c) => c.id == id);
      return;
    }
    try {
      await _db.from('clases').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar la clase.');
    }
  }

  // --- Rutinas --------------------------------------------------------------

  Future<List<Rutina>> listarRutinas() async {
    if (!ConfigSupabase.configurado) {
      return List<Rutina>.from(DemoDB.instancia.rutinas);
    }
    try {
      final filas = await _db.from('rutinas').select().order('nombre');
      return filas
          .map((f) => Rutina.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar las rutinas.');
    }
  }

  Future<Rutina> guardarRutina(Rutina rutina) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.rutinas.indexWhere((r) => r.id == rutina.id);
      if (i == -1) {
        db.rutinas.add(rutina);
      } else {
        db.rutinas[i] = rutina;
      }
      return rutina;
    }
    try {
      if (rutina.id.isEmpty) {
        final fila = await _db
            .from('rutinas')
            .insert(rutina.aMapa()..remove('id'))
            .select()
            .single();
        return Rutina.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('rutinas').upsert(rutina.aMapa());
      return rutina;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar la rutina.');
    }
  }

  Future<void> eliminarRutina(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.rutinas.removeWhere((r) => r.id == id);
      return;
    }
    try {
      await _db.from('rutinas').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar la rutina.');
    }
  }
}
