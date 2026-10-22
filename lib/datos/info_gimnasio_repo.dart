import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/info_gimnasio.dart';
import 'demo_db.dart';

/// Acceso a la informaci??n general del gimnasio.
class InfoGimnasioRepo {
  InfoGimnasioRepo._();
  static final InfoGimnasioRepo instancia = InfoGimnasioRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<InfoGimnasio> obtener() async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.infoGimnasio ??= const InfoGimnasio(id: 'info-1');
      return DemoDB.instancia.infoGimnasio!;
    }
    try {
      final filas = await _db.from('info_gimnasio').select().limit(1);
      if (filas.isEmpty) {
        const def = InfoGimnasio(id: '');
        final fila = await _db
            .from('info_gimnasio')
            .insert(def.aMapa()..remove('id'))
            .select()
            .single();
        return InfoGimnasio.desdeMapa(Map<String, dynamic>.from(fila));
      }
      return InfoGimnasio.desdeMapa(Map<String, dynamic>.from(filas.first));
    } catch (_) {
      throw ErrorFitCore('No se pudo cargar la informaci??n del gimnasio.');
    }
  }

  Future<InfoGimnasio> guardar(InfoGimnasio info) async {
    if (!ConfigSupabase.configurado) {
      DemoDB.instancia.infoGimnasio = info;
      return info;
    }
    try {
      await _db.from('info_gimnasio').upsert(info.aMapa());
      return info;
    } catch (_) {
      throw ErrorFitCore('No se pudo guardar la informaci??n del gimnasio.');
    }
  }
}

