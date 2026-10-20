import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/plan.dart';
import 'demo_db.dart';

/// Acceso a los tipos de membresía (planes) del gimnasio.
class PlanesRepo {
  PlanesRepo._();
  static final PlanesRepo instancia = PlanesRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<PlanMembresia>> listar() async {
    if (!ConfigSupabase.configurado) {
      return List<PlanMembresia>.from(DemoDB.instancia.planes);
    }
    try {
      final filas = await _db.from('planes').select().order('precio');
      return filas
          .map((f) => PlanMembresia.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar los planes.');
    }
  }

  Future<PlanMembresia> guardar(PlanMembresia plan) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.planes.indexWhere((p) => p.id == plan.id);
      if (i == -1) {
        db.planes.add(plan);
      } else {
        db.planes[i] = plan;
      }
      return plan;
    }
    try {
      if (plan.id.isEmpty) {
        final fila = await _db
            .from('planes')
            .insert(plan.aMapa()..remove('id'))
            .select()
            .single();
        return PlanMembresia.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('planes').upsert(plan.aMapa());
      return plan;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar el plan.');
    }
  }

  Future<void> eliminar(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.planes.removeWhere((p) => p.id == id);
      return;
    }
    try {
      await _db.from('planes').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar el plan.');
    }
  }
}
