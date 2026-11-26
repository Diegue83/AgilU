import 'dart:convert';

import 'package:agilu/data/models/actualizacion.dart';
import 'package:agilu/data/repositories/actualizacion_repository.dart';
import 'package:agilu/ui/comun/actualizacion.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _repo = 'Diegue83/AgilU';
const _base = 'https://github.com/$_repo/releases/download/v1.2.0';

Map<String, dynamic> _release({
  String tag = 'v1.2.0',
  bool draft = false,
  bool prerelease = false,
  bool conSha = true,
  String base = _base,
}) =>
    {
      'tag_name': tag,
      'draft': draft,
      'prerelease': prerelease,
      'body': 'Roles y permisos.',
      'assets': [
        {
          'name': 'AgilU-1.2.0.apk',
          'size': 1000,
          'browser_download_url': '$base/AgilU-1.2.0.apk',
        },
        if (conSha)
          {
            'name': 'AgilU-1.2.0.apk.sha256',
            'size': 80,
            'browser_download_url': '$base/AgilU-1.2.0.apk.sha256',
          },
      ],
    };

Actualizacion _nueva(String v) => Actualizacion(
      version: VersionApp.leer(v)!,
      notas: 'Novedades',
      urlApk: Uri.parse('$_base/AgilU.apk'),
      urlSha256: Uri.parse('$_base/AgilU.apk.sha256'),
    );

void main() {
  group('versiones', () {
    test('se leen con o sin v y sin el número de compilación', () {
      expect(VersionApp.leer('v1.2.0'), const VersionApp(1, 2, 0));
      expect(VersionApp.leer('1.10.3+7'), const VersionApp(1, 10, 3));
      expect(VersionApp.leer('APK'), isNull);
      expect(VersionApp.leer(null), isNull);
    });

    test('se comparan por número, no como texto', () {
      expect(VersionApp.leer('1.10.0')!.esMayorQue(VersionApp.leer('1.9.9')!),
          isTrue);
      expect(VersionApp.leer('2.0.0')!.esMayorQue(VersionApp.leer('1.99.99')!),
          isTrue);
      expect(VersionApp.leer('1.1.0')!.esMayorQue(VersionApp.leer('1.1.0')!),
          isFalse);
    });
  });

  group('release de GitHub', () {
    test('toma el APK y su suma del mismo repositorio', () {
      final a = Actualizacion.desdeRelease(_release(), repositorio: _repo)!;
      expect(a.version, const VersionApp(1, 2, 0));
      expect(a.urlApk.toString(), '$_base/AgilU-1.2.0.apk');
      expect(a.urlSha256.toString(), '$_base/AgilU-1.2.0.apk.sha256');
      expect(a.notas, 'Roles y permisos.');
    });

    test(
        'ignora borradores, versiones previas, etiquetas raras, ligas ajenas '
        'y releases sin suma', () {
      Actualizacion? leer(Map<String, dynamic> j) =>
          Actualizacion.desdeRelease(j, repositorio: _repo);
      expect(leer(_release(draft: true)), isNull);
      expect(leer(_release(prerelease: true)), isNull);
      expect(leer(_release(tag: 'APK')), isNull);
      expect(leer(_release(conSha: false)), isNull);
      expect(leer(_release(base: 'https://otro.example.com/v1.2.0')), isNull);
    });

    test('lee la suma del archivo .sha256', () {
      final suma = sha256.convert(utf8.encode('apk')).toString();
      expect(Actualizacion.leerSha256('$suma  AgilU-1.2.0.apk\n'), suma);
      expect(Actualizacion.leerSha256('no es una suma'), isNull);
    });
  });

  group('controlador', () {
    test('ofrece la versión nueva y la instala', () async {
      final repo = MockActualizacionRepository(publicada: _nueva('1.2.0'));
      final c = ActualizacionController(repo);
      await c.buscar();
      expect(c.estado, EstadoActualizacion.disponible);
      expect(c.instalada, const VersionApp(1, 1, 0));
      await c.actualizar();
      expect(repo.instaladas, ['/cache/agilu-1.2.0.apk']);
      expect(c.progreso, 1);
    });

    test('con la misma versión o una anterior está al día', () async {
      for (final v in ['1.1.0', '1.0.9']) {
        final c = ActualizacionController(
            MockActualizacionRepository(publicada: _nueva(v)));
        await c.buscar();
        expect(c.estado, EstadoActualizacion.alDia, reason: v);
        expect(c.nueva, isNull);
      }
      final sinRelease = ActualizacionController(MockActualizacionRepository());
      await sinRelease.buscar();
      expect(sinRelease.estado, EstadoActualizacion.alDia);
    });

    test('si la suma no coincide no instala', () async {
      final repo = MockActualizacionRepository(
          publicada: _nueva('1.2.0'), sumaCorrecta: false);
      final c = ActualizacionController(repo);
      await c.buscar();
      await c.actualizar();
      expect(c.estado, EstadoActualizacion.error);
      expect(c.error, contains('no coincide'));
      expect(repo.instaladas, isEmpty);
    });

    test('sin permiso pide permitirlo y después instala lo descargado',
        () async {
      final repo = MockActualizacionRepository(
          publicada: _nueva('1.2.0'), permiso: false);
      final c = ActualizacionController(repo);
      await c.buscar();
      await c.actualizar();
      expect(c.estado, EstadoActualizacion.faltaPermiso);
      await c.actualizar();
      expect(repo.instaladas, hasLength(1));
    });

    test('fuera de Android no busca nada', () async {
      final c = ActualizacionController(
          MockActualizacionRepository(publicada: _nueva('9.0.0')),
          soportada: false);
      await c.buscar();
      expect(c.estado, EstadoActualizacion.noSoportada);
      expect(c.nueva, isNull);
    });
  });
}
