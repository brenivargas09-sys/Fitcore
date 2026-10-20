import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/membresia.dart';
import '../modelos/pago.dart';
import 'demo_db.dart';

/// Acceso a membresias y pagos de los socios.
class PagosRepo {
  PagosRepo._();
  static final PagosRepo instancia = PagosRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  // --- Membresias -----------------------------------------------------------

  Future<List<Membresia>> listarMembresias() async {
    if (!ConfigSupabase.configurado) {
      return List<Membresia>.from(DemoDB.instancia.membresias);
    }
    try {
      final filas = await _db.from('membresias').select().order('fecha_fin');
      return filas
          .map((f) => Membresia.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar las membresías.');
    }
  }

  Future<Membresia> guardarMembresia(Membresia membresia) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.membresias.indexWhere((m) => m.id == membresia.id);
      if (i == -1) {
        db.membresias.add(membresia);
      } else {
        db.membresias[i] = membresia;
      }
      return membresia;
    }
    try {
      if (membresia.id.isEmpty) {
        final fila = await _db
            .from('membresias')
            .insert(membresia.aMapa()..remove('id'))
            .select()
            .single();
        return Membresia.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('membresias').upsert(membresia.aMapa());
      return membresia;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar la membresía.');
    }
  }

  // --- Pagos ----------------------------------------------------------------

  Future<List<Pago>> listarPagos() async {
    if (!ConfigSupabase.configurado) {
      final lista = List<Pago>.from(DemoDB.instancia.pagos);
      lista.sort((a, b) => (b.fecha ?? DateTime(0)).compareTo(a.fecha ?? DateTime(0)));
      return lista;
    }
    try {
      final filas = await _db.from('pagos').select().order('fecha', ascending: false);
      return filas
          .map((f) => Pago.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar los pagos.');
    }
  }

  Future<Pago> registrarPago(Pago pago) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.pagos.indexWhere((p) => p.id == pago.id);
      if (i == -1) {
        db.pagos.add(pago);
      } else {
        db.pagos[i] = pago;
      }
      return pago;
    }
    try {
      if (pago.id.isEmpty) {
        final fila = await _db
            .from('pagos')
            .insert(pago.aMapa()..remove('id'))
            .select()
            .single();
        return Pago.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('pagos').upsert(pago.aMapa());
      return pago;
    } catch (_) {
      throw ErrorFitCore('No se pudo registrar el pago.');
    }
  }

  Future<void> eliminarMembresia(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.membresias.removeWhere((m) => m.id == id);
      return;
    }
    try {
      await _db.from('membresias').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar la membresía.');
    }
  }
  Future<void> eliminarPago(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.pagos.removeWhere((p) => p.id == id);
      return;
    }
    try {
      await _db.from('pagos').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar el pago.');
    }
  }
}

