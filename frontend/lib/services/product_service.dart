import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductoDetalle {
  final String ean;
  final String nombre;
  final int pasillo;
  final String posicion;
  final String categoria;
  final String unidad;
  final Map<String, dynamic>? pasilloInfo;

  const ProductoDetalle({
    required this.ean,
    required this.nombre,
    required this.pasillo,
    required this.posicion,
    required this.categoria,
    required this.unidad,
    this.pasilloInfo,
  });

  factory ProductoDetalle.fromJson(Map<String, dynamic> json) {
    return ProductoDetalle(
      ean: json['ean'] ?? '',
      nombre: json['nombre'] ?? '',
      pasillo: json['pasillo'] ?? 0,
      posicion: json['posicion'] ?? '',
      categoria: json['categoria'] ?? '',
      unidad: json['unidad'] ?? '',
      pasilloInfo: json['pasillo_info'] as Map<String, dynamic>?,
    );
  }

  String get descripcionPasillo =>
      pasilloInfo?['descripcion'] ?? 'Pasillo $pasillo';

  String get nombrePasillo =>
      pasilloInfo?['nombre'] ?? 'Pasillo $pasillo';

  String get naviLeensCode =>
      pasilloInfo?['navileens_code'] ?? '';

  String get instruccionVoz =>
      'Busca $nombre en el pasillo $pasillo: $nombrePasillo. '
      '$descripcionPasillo. '
      '${_textoAltura(posicion)}.';

  static String _textoAltura(String pos) {
    switch (pos) {
      case 'suelo':   return 'Está en el suelo';
      case 'bajo':    return 'Está en la estantería baja';
      case 'centro':  return 'Está a media altura';
      case 'alto':    return 'Está en la estantería alta';
      default:        return 'Está en la estantería';
    }
  }
}

class ListaCompraResult {
  final List<ProductoDetalle> productosEncontrados;
  final List<String> productosNoEncontrados;
  final String mensajeVoz;

  const ListaCompraResult({
    required this.productosEncontrados,
    required this.productosNoEncontrados,
    required this.mensajeVoz,
  });
}

class ProductService {
  // ── Cambia esto por la IP de tu máquina en desarrollo ──────────────────────
  // Para emulador Android: 10.0.2.2:8000
  // Para dispositivo físico: IP local del PC, ej. 192.168.1.100:8000
  static const String _baseUrl = 'http://10.0.2.2:8000';

  // ── LISTA DE LA COMPRA COMPLETA ─────────────────────────────────────────────
  Future<ListaCompraResult> procesarListaVoz(String textoVoz) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/products/lista'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'texto_voz': textoVoz, 'usar_ia': true}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final productos = (data['orden_recorrido'] as List)
            .map((e) => ProductoDetalle.fromJson(e))
            .toList();
        return ListaCompraResult(
          productosEncontrados: productos,
          productosNoEncontrados:
              List<String>.from(data['productos_no_encontrados'] ?? []),
          mensajeVoz: data['mensaje_voz'] ?? '',
        );
      }
    } catch (_) {}

    // ── FALLBACK LOCAL si el backend no está disponible ─────────────────────
    return _fallbackLocal(textoVoz);
  }

  // ── VALIDAR CÓDIGO DE BARRAS ────────────────────────────────────────────────
  Future<Map<String, dynamic>> validarBarcode({
    required String ean,
    required String nombreEsperado,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/products/validar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ean': ean,
              'nombre_esperado': nombreEsperado,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    return {
      'correcto': false,
      'mensaje_voz': 'No se pudo verificar el producto. Comprueba la conexión.',
    };
  }

  // ── BUSCAR POR EAN ──────────────────────────────────────────────────────────
  Future<ProductoDetalle?> buscarPorEan(String ean) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/barcode/$ean'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['encontrado'] == true && data['producto'] != null) {
          return ProductoDetalle.fromJson(data['producto']);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── EXTRAER PRODUCTOS (compatibilidad con código anterior) ──────────────────
  Future<List<String>> extraerProductos(String texto) async {
    final result = await procesarListaVoz(texto);
    return result.productosEncontrados.map((p) => p.nombre).toList();
  }

  // ── FALLBACK: catálogo local simplificado ───────────────────────────────────
  ListaCompraResult _fallbackLocal(String texto) {
    final textoLimpio = texto.toLowerCase().replaceAll(RegExp(r'[.!?¿¡,;]'), ' ');
    final palabras = textoLimpio.split(RegExp(r'\s+'));

    final Map<String, ProductoDetalle> catalogoBasico = {
      'leche': const ProductoDetalle(ean: '0', nombre: 'Leche entera Hacendado 1L', pasillo: 3, posicion: 'centro', categoria: 'Lácteos', unidad: 'brik'),
      'pan': const ProductoDetalle(ean: '1', nombre: 'Pan de molde Hacendado', pasillo: 1, posicion: 'centro', categoria: 'Panadería', unidad: 'bolsa'),
      'tomate': const ProductoDetalle(ean: '2', nombre: 'Tomates rama 500g', pasillo: 0, posicion: 'centro', categoria: 'Verduras', unidad: 'bandeja'),
      'pollo': const ProductoDetalle(ean: '3', nombre: 'Pechuga de pollo 500g', pasillo: 4, posicion: 'bajo', categoria: 'Carnicería', unidad: 'bandeja'),
      'huevos': const ProductoDetalle(ean: '4', nombre: 'Huevos camperos L 12u', pasillo: 3, posicion: 'bajo', categoria: 'Lácteos', unidad: 'caja'),
      'yogur': const ProductoDetalle(ean: '5', nombre: 'Yogur natural Hacendado', pasillo: 3, posicion: 'bajo', categoria: 'Lácteos', unidad: 'pack'),
      'arroz': const ProductoDetalle(ean: '6', nombre: 'Arroz largo Hacendado 1kg', pasillo: 6, posicion: 'centro', categoria: 'Despensa', unidad: 'bolsa'),
      'pasta': const ProductoDetalle(ean: '7', nombre: 'Pasta macarrones 500g', pasillo: 6, posicion: 'alto', categoria: 'Despensa', unidad: 'bolsa'),
      'agua': const ProductoDetalle(ean: '8', nombre: 'Agua mineral 6x1.5L', pasillo: 8, posicion: 'suelo', categoria: 'Bebidas', unidad: 'pack'),
    };

    final encontrados = <ProductoDetalle>[];
    final noEncontrados = <String>[];

    for (final palabra in palabras) {
      if (palabra.length <= 2) continue;
      if (catalogoBasico.containsKey(palabra)) {
        final prod = catalogoBasico[palabra]!;
        if (!encontrados.any((p) => p.ean == prod.ean)) {
          encontrados.add(prod);
        }
      }
    }

    encontrados.sort((a, b) => a.pasillo.compareTo(b.pasillo));

    final msg = encontrados.isEmpty
        ? 'No he encontrado productos. Intenta de nuevo.'
        : '${encontrados.length} productos encontrados. '
            'Empieza en el pasillo ${encontrados.first.pasillo}.';

    return ListaCompraResult(
      productosEncontrados: encontrados,
      productosNoEncontrados: noEncontrados,
      mensajeVoz: msg,
    );
  }
}