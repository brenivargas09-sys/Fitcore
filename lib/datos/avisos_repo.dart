import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/aviso.dart';
import 'demo_db.dart';

/// Acceso a avisos y novedades.
class AvisosRepo {
  AvisosRepo._();
  static final AvisosRepo instancia = AvisosRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Aviso>> listar() async {
    if (!ConfigSupabase.configurado) {
      final lista = List<Aviso>.from(DemoDB.instancia.avisos);
      lista.sort((a, b) => (b.fechaPublicacion ?? DateTime(0))
          .compareTo(a.fechaPublicacion ?? DateTime(0)));
      return lista;
    }
    try {
      final filas = await _db.from('avisos').select().order('fecha_publicacion', ascending: false);
      return filas
          .map((f) => Aviso.desdeMapa(Map<String, dynamic>.from(f)))
          .toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar los avisos.');
    }
  }

  Future<Aviso> guardar(Aviso aviso) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.avisos.indexWhere((a) => a.id == aviso.id);
      if (i == -1) {
        db.avisos.add(aviso.copyWith(
          fechaPublicacion: aviso.fechaPublicacion ?? DateTime.now(),
        ));
      } else {
        db.avisos[i] = aviso;
      }
      return aviso;
    }
    try {
      final mapa = aviso.aMapa();
      if (aviso.id.isEmpty) {
        mapa['fecha_publicacion'] = DateTime.now().toIso8601String();
        final fila = await _db
            .from('avisos')
            .insert(mapa..remove('id'))
            .select()
            .single();
        return Aviso.desdeMapa(Map<String, dynamic>.from(fila));
      }
      await _db.from('avisos').upsert(mapa);
      return aviso;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar el aviso.');
    }
  }

  Future<void> eliminar(String id) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.avisos.removeWhere((a) => a.id == id);
      return;
    }
    try {
      await _db.from('avisos').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar el aviso.');
    }
  }

  Future<void> activar(String id, bool activo) async {
    if (!ConfigSupabase.configurado) {
      final i = DemoDB.instancia.avisos.indexWhere((a) => a.id == id);
      if (i != -1) {
        DemoDB.instancia.avisos[i] = DemoDB.instancia.avisos[i].copyWith(activo: activo);
      }
      return;
    }
    try {
      await _db.from('avisos').update({'activo': activo}).eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo actualizar el aviso.');
    }
  }
}
