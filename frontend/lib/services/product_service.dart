class ProductService {
  // EL DICCIONARIO DEFINITIVO: PRODUCTOS + MARCAS FAMOSAS
  final Set<String> catalogoMercadona = {
    // --- MARCAS FAMOSAS (EL EXTRA QUE PEDISTE) ---
    'cocacola', 'coke', 'fanta', 'sprite', 'nestea', 'aquarius', 'monster', 'redbull', 'burn',
    'pepsi', 'kas', '7up', 'schweppes', 'tonica', 'bifrutas', 'pascual', 'don simon',
    'donuts', 'bollycao', 'phoskitos', 'kinder', 'bueno', 'nutella', 'nocilla', 'kitkat',
    'oreo', 'chipsahoy', 'principe', 'lu', 'milka', 'toblerone', 'lindt', 'valor',
    'lays', 'lays', 'doritos', 'cheetos', 'pringles', 'ruffles', 'matutano',
    'danone', 'activia', 'danacol', 'danonino', 'actimel', 'vitalinea', 'oikos',
    'hellmanns', 'heinz', 'ketchup', 'orlando', 'gallina', 'blanca', 'avecrem', 'knorr',
    'barilla', 'gallo', 'brillante', 'sos', 'la', 'cigala', 'calvo', 'isabel', 'cuca',
    'casa', 'tarradellas', 'elpozo', 'campofrio', 'navidul', 'revilla', 'oscar', 'mayer',
    'fairy', 'finish', 'ariel', 'skip', 'vick', 'vileda', 'kh7', 'cillit', 'bang',
    'colgate', 'oralb', 'sensodyne', 'listerine', 'gillette', 'pantene', 'h&s', 'fructis',
    'nivea', 'dove', 'rexona', 'axe', 'old', 'spice', 'ausonia', 'evax', 'tampax', 'dodot',

    // --- FRUTERÍA Y VERDURAS (MÁXIMA VARIEDAD) ---
    'manzana', 'platano', 'plátano', 'banana', 'pera', 'naranja', 'limon', 'limón', 'fresa', 'fresón', 'kiwi', 'uva',
    'piña', 'melon', 'melón', 'sandia', 'sandía', 'tomate', 'lechuga', 'cebolla', 'ajo', 'patata', 'patatas', 'zanahoria',
    'pimiento', 'pepino', 'calabacin', 'calabacín', 'berenjena', 'brocoli', 'brócoli', 'espinacas', 'setas', 'champiñon',
    'champiñón', 'aguacate', 'mango', 'papaya', 'coliflor', 'repollo', 'judías', 'judias', 'guisantes', 'calabaza',
    'apio', 'puerro', 'rábano', 'canónigos', 'rucula', 'rúcula', 'cherrys', 'espárragos', 'alcachofas', 'remolacha',
    'maíz', 'mazorca', 'jengibre', 'perejil', 'cilantro', 'hierbabuena', 'lombarda', 'endivias', 'batata', 'boniato',

    // --- CARNICERÍA Y AVES (CORTES INCLUIDOS) ---
    'pollo', 'pechuga', 'muslo', 'alitas', 'pavo', 'cerdo', 'lomo', 'chuleta', 'ternera', 'vaca', 'hamburguesa',
    'salchichas', 'bacon', 'beicon', 'jamon', 'jamón', 'serrano', 'cocido', 'chorizo', 'salchichon', 'salchichón',
    'fuet', 'pate', 'paté', 'sobrasada', 'mortadela', 'panceta', 'conejo', 'cordero', 'picada', 'nuggets', 'entrecot',
    'solomillo', 'costillas', 'magro', 'callos', 'morcilla', 'chistorra', 'codillo', 'pato', 'foie',

    // --- PESCADERÍA Y MARISCO (FRESCO Y CONGELADO) ---
    'pescado', 'merluza', 'salmon', 'salmón', 'atun', 'atún', 'bacalao', 'gambas', 'langostinos', 'sardinas', 'boquerones',
    'pulpo', 'calamar', 'sepia', 'pota', 'mejillones', 'almejas', 'dorada', 'lubina', 'trucha', 'gulas', 'surimi',
    'bacaladilla', 'emperador', 'pez', 'espada', 'rodaballo', 'cigalas', 'bogavante', 'buey', 'mar', 'berberechos',

    // --- BODEGA, BEBIDAS Y CAFÉS ---
    'agua', 'mineral', 'gas', 'refresco', 'cola', 'naranja', 'limon', 'limón', 'cerveza', 'vino', 'tinto', 'blanco',
    'rosado', 'zumo', 'energetica', 'energética', 'monster', 'redbull', 'cafe', 'café', 'capsulas', 'cápsulas',
    'infusion', 'infusión', 'te', 'té', 'manzanilla', 'poleo', 'horchata', 'batido', 'sidra', 'cava', 'champán',
    'whisky','leche' ,'ginebra', 'ron', 'vodka', 'licor', 'vermut', 'tónica', 'aquarius', 'fanta', 'nestea',

    // --- LIMPIEZA, HOGAR Y MASCOTAS (BRUTAL) ---
    'detergente', 'suavizante', 'lavavajillas', 'fairy', 'lejia', 'lejía', 'amoniaco', 'amoníaco', 'desengrasante',
    'limpiacristales', 'multiusos', 'fregona', 'escoba', 'estropajo', 'bayeta', 'papel', 'higienico', 'higiénico',
    'cocina', 'servilletas', 'aluminio', 'film', 'bolsas', 'basura', 'antical', 'pastillas', 'lavadora', 'suelo',
    'baño', 'muebles', 'insecticida', 'ambientador', 'velas', 'bombillas', 'pilas', 'perro', 'gato', 'pienso',
    'comida', 'arena', 'snacks', 'correa', 'pájaro', 'canario', 'tortuga',

    // --- PERFUMERÍA, SALUD Y COSMÉTICA ---
    'champu', 'champú', 'acondicionador', 'gel', 'ducha', 'jabon', 'jabón', 'manos', 'desodorante', 'colonia',
    'perfume', 'dientes', 'dentífrico', 'cepillo', 'hilo', 'maquillaje', 'crema', 'solar', 'compresas', 'tampones',
    'pañales', 'toallitas', 'gomina', 'laca', 'tinte', 'algodon', 'algodón', 'alcohol', 'agua', 'oxigenada',
    'tiritas', 'preservativos', 'lubricante', 'mascarilla', 'enjuague', 'fixonia', 'perfilador', 'labial',

    // --- DESPENSA, SNACKS Y "LISTO PARA COMER" ---
    'arroz', 'pasta', 'macarrones', 'espaguetis', 'tallarines', 'fideos', 'cuscus', 'lentejas', 'garbanzos',
    'alubias', 'aceite', 'oliva', 'girasol', 'vinagre', 'sal', 'pimienta', 'especies', 'caldo', 'ketchup',
    'mayonesa', 'mostaza', 'aceitunas', 'pepinillos', 'maiz', 'mermelada', 'miel', 'hummus', 'guacamole',
    'pizza', 'lasaña', 'canelones', 'ensaladilla', 'tortilla', 'patatas', 'chips', 'nachos', 'almendras',
    'nueces', 'pistachos', 'palomitas', 'chocolate', 'bombones', 'caramelos', 'chicles', 'hielo'
  
    // --- LÁCTEOS COMPLETOS ---
    'leche', 'entera', 'desnatada', 'semi', 'semidesnatada', 'yogur', 'yogures',
    'griego', 'huevo', 'huevos', 'mantequilla', 'margarina', 'queso', 'fresco',
    'curado', 'semicurado', 'mozzarella', 'nata', 'cuajada', 'flan', 'natillas',
    'kefir', 'philadelphia', 'mascarpone', 'quesito', 'quesitos', 'batido',
    'bífidus', 'proteinas', 'burgos', 'roquefort', 'emmental', 'gouda', 'havarti',
    'cheddar', 'parmesano', 'brie', 'camembert',

    // --- PANADERÍA COMPLETA ---
    'pan', 'barra', 'baguette', 'integral', 'molde', 'tostado', 'picos', 'colines',
    'regañás', 'galletas', 'magdalenas', 'bizcocho', 'croissant', 'harina', 'azucar',
    'azúcar', 'levadura', 'hojaldre', 'muesli', 'granola', 'sobaos', 'ensaimada',
    'panecillos', 'brioche', 'focaccia', 'chapata', 'palmera', 'tortas', 'mantecados',
    'polvorón', 'turron', 'turrón', 'mazapán', 'roscon', 'roscón',

    // --- CHARCUTERÍA Y FIAMBRE ---
    'embutido', 'fiambre', 'longaniza', 'cecina', 'lomo', 'embuchado', 'lacón',
    'butifarra', 'morcón', 'salami', 'pepperoni', 'york', 'pavo', 'pechuga',

    // --- CONGELADOS ---
    'helado', 'helados', 'croquetas', 'pizza', 'lasaña', 'canelones', 'varitas',
    'bastones', 'patatas', 'guisantes', 'espinacas', 'judias', 'brócoli', 'menestra',
    'paella', 'arroz', 'pulpo', 'gambas', 'langostinos', 'merluza', 'calamar',

    // --- CONDIMENTOS Y SALSAS ---
    'tomate', 'frito', 'triturado', 'natural', 'concentrado', 'pisto', 'sofrito',
    'bechamel', 'carbonara', 'boloñesa', 'curry', 'soja', 'tabasco', 'sriracha',
    'salsa', 'alioli', 'romesco', 'chimichurri', 'mojo', 'picon',

    // --- APERITIVOS Y SNACKS ---
    'aceitunas', 'pepinillos', 'anchoas', 'banderillas', 'encurtidos', 'boquerones',
    'mejillones', 'berberechos', 'almejas', 'navajuelas', 'pulpo', 'calamar',
    'pipas', 'cacahuetes', 'anacardos', 'pipas', 'gusanitos', 'palomitas',

    // --- ZUMOS Y BEBIDAS NO ALCOHÓLICAS ---
    'zumo', 'naranja', 'piña', 'manzana', 'melocotón', 'tropical', 'multifrutas',
    'gazpacho', 'salmorejo', 'smoothie', 'kombucha',

    // --- HIGIENE BUCAL Y CUERPO ---
    'pasta', 'dentífrica', 'enjuague', 'bucal', 'hilo', 'dental', 'cepillo',
    'maquinilla', 'espuma', 'afeitar', 'colonia', 'perfume',

    // --- FARMACIA BÁSICA ---
    'ibuprofeno', 'paracetamol', 'aspirina', 'antiácido', 'probiótico',
    'vitaminas', 'magnesio', 'melatonina',

    // --- MASCOTAS ---
    'pienso', 'croquetas', 'paté', 'snacks', 'arena', 'comedero', 'bebedero',

    // --- VARIOS QUE SE OLVIDAN ---
    'sal', 'azúcar', 'aceite', 'vinagre', 'harina', 'arroz', 'pasta', 'legumbres',
    'caldo', 'consomé', 'levadura', 'bicarbonato', 'gelatina', 'agar',
    'canela', 'vainilla', 'cardamomo', 'oregano', 'orégano', 'romero', 'tomillo',
    'laurel', 'comino', 'pimentón', 'paprika', 'cúrcuma', 'jengibre', 'nuez', 'moscada',
  };

  Future<List<String>> extraerProductos(String texto) async {
    // 1. Limpieza de símbolos y conversión a minúsculas
    final textoLimpio = texto.toLowerCase()
        .replaceAll(RegExp(r'[.!¡?¿,;:\-_"()\[\]]'), ' ');

    // 2. Fragmentación por espacios
    final palabrasUsuario = textoLimpio.split(RegExp(r'\s+'));

    // 3. Filtrado por el catálogo giga-ampliado
    final productosEncontrados = palabrasUsuario
        .where((palabra) => 
          palabra.length > 2 && catalogoMercadona.contains(palabra)
        )
        .toSet() 
        .toList();

    return productosEncontrados;
  }
}