"""
Catálogo de productos Mercadona con datos de ubicación en tienda.
Cada producto incluye: nombre, pasillo, posición (altura), código de barras (EAN).
"""

from typing import Optional

# ── CATÁLOGO PRINCIPAL ─────────────────────────────────────────────────────────
# Estructura: codigo_ean -> {nombre, pasillo, posicion, categoria, unidad}
CATALOGO: dict[str, dict] = {
    # ── LÁCTEOS ──
    "8412657000058": {"nombre": "Leche entera Hacendado 1L",       "pasillo": 3, "posicion": "centro",  "categoria": "Lácteos",    "unidad": "brik"},
    "8412657000065": {"nombre": "Leche semidesnatada Hacendado 1L","pasillo": 3, "posicion": "centro",  "categoria": "Lácteos",    "unidad": "brik"},
    "8412657000072": {"nombre": "Yogur natural Hacendado",          "pasillo": 3, "posicion": "bajo",    "categoria": "Lácteos",    "unidad": "pack"},
    "8412657000089": {"nombre": "Queso fresco Hacendado 250g",      "pasillo": 3, "posicion": "bajo",    "categoria": "Lácteos",    "unidad": "pieza"},
    "8412657000096": {"nombre": "Mantequilla Hacendado 250g",       "pasillo": 3, "posicion": "alto",    "categoria": "Lácteos",    "unidad": "tarrina"},
    "8412657000102": {"nombre": "Nata para cocinar Hacendado",      "pasillo": 3, "posicion": "centro",  "categoria": "Lácteos",    "unidad": "brik"},
    "8412657000119": {"nombre": "Huevos camperos tamaño L (12u)",   "pasillo": 3, "posicion": "bajo",    "categoria": "Lácteos",    "unidad": "caja"},

    # ── PAN Y PANADERÍA ──
    "8412657001001": {"nombre": "Pan de molde blanco Hacendado",    "pasillo": 1, "posicion": "centro",  "categoria": "Panadería",  "unidad": "bolsa"},
    "8412657001018": {"nombre": "Pan de molde integral Hacendado",  "pasillo": 1, "posicion": "centro",  "categoria": "Panadería",  "unidad": "bolsa"},
    "8412657001025": {"nombre": "Tostadas integrales Hacendado",    "pasillo": 1, "posicion": "alto",    "categoria": "Panadería",  "unidad": "caja"},
    "8412657001032": {"nombre": "Magdalenas Hacendado 12u",         "pasillo": 1, "posicion": "bajo",    "categoria": "Panadería",  "unidad": "bolsa"},
    "8412657001049": {"nombre": "Galletas María Hacendado 800g",    "pasillo": 1, "posicion": "alto",    "categoria": "Panadería",  "unidad": "caja"},

    # ── FRUTAS Y VERDURAS ──
    "8412657002001": {"nombre": "Plátanos de Canarias 1kg",         "pasillo": 0, "posicion": "bajo",    "categoria": "Frutería",   "unidad": "malla"},
    "8412657002018": {"nombre": "Manzanas Golden 1kg",              "pasillo": 0, "posicion": "bajo",    "categoria": "Frutería",   "unidad": "bolsa"},
    "8412657002025": {"nombre": "Naranjas de mesa 2kg",             "pasillo": 0, "posicion": "bajo",    "categoria": "Frutería",   "unidad": "bolsa"},
    "8412657002032": {"nombre": "Tomates rama 500g",                "pasillo": 0, "posicion": "centro",  "categoria": "Verduras",   "unidad": "bandeja"},
    "8412657002049": {"nombre": "Lechuga iceberg",                  "pasillo": 0, "posicion": "bajo",    "categoria": "Verduras",   "unidad": "pieza"},
    "8412657002056": {"nombre": "Patatas blancas 2kg",              "pasillo": 0, "posicion": "suelo",   "categoria": "Verduras",   "unidad": "bolsa"},
    "8412657002063": {"nombre": "Cebolla blanca 1kg",               "pasillo": 0, "posicion": "suelo",   "categoria": "Verduras",   "unidad": "bolsa"},

    # ── CARNICERÍA ──
    "8412657003001": {"nombre": "Pechuga de pollo Hacendado 500g",  "pasillo": 4, "posicion": "bajo",    "categoria": "Carnicería", "unidad": "bandeja"},
    "8412657003018": {"nombre": "Carne picada mixta 500g",          "pasillo": 4, "posicion": "bajo",    "categoria": "Carnicería", "unidad": "bandeja"},
    "8412657003025": {"nombre": "Lomo de cerdo filetes 400g",       "pasillo": 4, "posicion": "centro",  "categoria": "Carnicería", "unidad": "bandeja"},
    "8412657003032": {"nombre": "Salchichas Frankfurt Hacendado",   "pasillo": 4, "posicion": "centro",  "categoria": "Charcutería","unidad": "pack"},
    "8412657003049": {"nombre": "Jamón cocido calidad extra 100g",  "pasillo": 4, "posicion": "alto",    "categoria": "Charcutería","unidad": "sobre"},

    # ── PESCADERÍA ──
    "8412657004001": {"nombre": "Merluza en rodajas 500g",          "pasillo": 5, "posicion": "bajo",    "categoria": "Pescadería", "unidad": "bandeja"},
    "8412657004018": {"nombre": "Gambas peladas congeladas 400g",   "pasillo": 7, "posicion": "bajo",    "categoria": "Congelados", "unidad": "bolsa"},
    "8412657004025": {"nombre": "Atún en aceite Hacendado 3x80g",   "pasillo": 6, "posicion": "centro",  "categoria": "Conservas",  "unidad": "pack"},

    # ── DESPENSA ──
    "8412657005001": {"nombre": "Arroz largo Hacendado 1kg",        "pasillo": 6, "posicion": "centro",  "categoria": "Despensa",   "unidad": "bolsa"},
    "8412657005018": {"nombre": "Pasta macarrones Hacendado 500g",  "pasillo": 6, "posicion": "alto",    "categoria": "Despensa",   "unidad": "bolsa"},
    "8412657005025": {"nombre": "Aceite de oliva virgen extra 1L",  "pasillo": 6, "posicion": "alto",    "categoria": "Despensa",   "unidad": "botella"},
    "8412657005032": {"nombre": "Tomate frito Hacendado 350g",      "pasillo": 6, "posicion": "bajo",    "categoria": "Conservas",  "unidad": "bote"},
    "8412657005049": {"nombre": "Lentejas cocidas Hacendado 570g",  "pasillo": 6, "posicion": "bajo",    "categoria": "Conservas",  "unidad": "bote"},

    # ── BEBIDAS ──
    "8412657006001": {"nombre": "Agua mineral Hacendado 6x1.5L",    "pasillo": 8, "posicion": "suelo",   "categoria": "Bebidas",    "unidad": "pack"},
    "8412657006018": {"nombre": "Leche Pascual entera 6x1L",        "pasillo": 3, "posicion": "alto",    "categoria": "Lácteos",    "unidad": "pack"},
    "8412657006025": {"nombre": "Zumo naranja refrigerado 1L",      "pasillo": 3, "posicion": "bajo",    "categoria": "Bebidas",    "unidad": "brik"},
    "8412657006032": {"nombre": "Cerveza Estrella Damm lata 33cl",  "pasillo": 9, "posicion": "centro",  "categoria": "Bebidas",    "unidad": "pack"},

    # ── LIMPIEZA ──
    "8412657007001": {"nombre": "Detergente lavadora Hacendado 28d","pasillo": 10,"posicion": "bajo",    "categoria": "Limpieza",   "unidad": "caja"},
    "8412657007018": {"nombre": "Lavavajillas Hacendado 750ml",     "pasillo": 10,"posicion": "centro",  "categoria": "Limpieza",   "unidad": "botella"},
    "8412657007025": {"nombre": "Papel higiénico Bosque Verde 12r", "pasillo": 11,"posicion": "alto",    "categoria": "Hogar",      "unidad": "pack"},
    "8412657007032": {"nombre": "Papel cocina Bosque Verde 2r",     "pasillo": 11,"posicion": "centro",  "categoria": "Hogar",      "unidad": "pack"},

    # ── HIGIENE ──
    "8412657008001": {"nombre": "Champú Deliplus cabello normal",   "pasillo": 12,"posicion": "centro",  "categoria": "Higiene",    "unidad": "bote"},
    "8412657008018": {"nombre": "Gel de ducha Deliplus 750ml",      "pasillo": 12,"posicion": "bajo",    "categoria": "Higiene",    "unidad": "bote"},
    "8412657008025": {"nombre": "Pasta de dientes Deliplus 75ml",   "pasillo": 12,"posicion": "alto",    "categoria": "Higiene",    "unidad": "tubo"},
    "8412657008032": {"nombre": "Desodorante Deliplus spray",       "pasillo": 12,"posicion": "alto",    "categoria": "Higiene",    "unidad": "spray"},
}

# ── MAPA DE PASILLOS ──────────────────────────────────────────────────────────
PASILLOS: dict[int, dict] = {
    0:  {"nombre": "Frutería y Verduras",     "descripcion": "Al entrar a la derecha", "navileens_code": "NVL-001"},
    1:  {"nombre": "Panadería y Desayuno",    "descripcion": "Pasillo 1, frente a la entrada", "navileens_code": "NVL-002"},
    3:  {"nombre": "Lácteos y Huevos",        "descripcion": "Pasillo 3, zona refrigerada", "navileens_code": "NVL-003"},
    4:  {"nombre": "Carnicería y Charcutería","descripcion": "Pasillo 4, mostrador refrigerado", "navileens_code": "NVL-004"},
    5:  {"nombre": "Pescadería",              "descripcion": "Pasillo 5, mostrador refrigerado", "navileens_code": "NVL-005"},
    6:  {"nombre": "Despensa y Conservas",    "descripcion": "Pasillo 6, zona central", "navileens_code": "NVL-006"},
    7:  {"nombre": "Congelados",              "descripcion": "Pasillo 7, arcones congelados", "navileens_code": "NVL-007"},
    8:  {"nombre": "Bebidas y Agua",          "descripcion": "Pasillo 8, botellas grandes", "navileens_code": "NVL-008"},
    9:  {"nombre": "Vinos y Cervezas",        "descripcion": "Pasillo 9, estantería alta", "navileens_code": "NVL-009"},
    10: {"nombre": "Limpieza del Hogar",      "descripcion": "Pasillo 10, al fondo", "navileens_code": "NVL-010"},
    11: {"nombre": "Papel y Desechables",     "descripcion": "Pasillo 11, junto a limpieza", "navileens_code": "NVL-011"},
    12: {"nombre": "Higiene Personal",        "descripcion": "Pasillo 12, al fondo derecha", "navileens_code": "NVL-012"},
}

# ── ALIAS: nombre genérico → EAN ──────────────────────────────────────────────
# Permite buscar por nombre parcial cuando no hay código de barras
ALIAS: dict[str, str] = {
    "leche":        "8412657000058",
    "leche entera": "8412657000058",
    "leche semi":   "8412657000065",
    "yogur":        "8412657000072",
    "queso":        "8412657000089",
    "mantequilla":  "8412657000096",
    "nata":         "8412657000102",
    "huevos":       "8412657000119",
    "pan":          "8412657001001",
    "pan integral": "8412657001018",
    "tostadas":     "8412657001025",
    "magdalenas":   "8412657001032",
    "galletas":     "8412657001049",
    "plátano":      "8412657002001",
    "platano":      "8412657002001",
    "manzana":      "8412657002018",
    "naranja":      "8412657002025",
    "tomate":       "8412657002032",
    "lechuga":      "8412657002049",
    "patata":       "8412657002056",
    "patatas":      "8412657002056",
    "cebolla":      "8412657002063",
    "pollo":        "8412657003001",
    "pechuga":      "8412657003001",
    "carne picada": "8412657003018",
    "lomo":         "8412657003025",
    "salchichas":   "8412657003032",
    "jamón":        "8412657003049",
    "jamon":        "8412657003049",
    "merluza":      "8412657004001",
    "gambas":       "8412657004018",
    "atún":         "8412657004025",
    "atun":         "8412657004025",
    "arroz":        "8412657005001",
    "pasta":        "8412657005018",
    "macarrones":   "8412657005018",
    "aceite":       "8412657005025",
    "tomate frito": "8412657005032",
    "lentejas":     "8412657005049",
    "agua":         "8412657006001",
    "zumo":         "8412657006025",
    "cerveza":      "8412657006032",
    "detergente":   "8412657007001",
    "lavavajillas": "8412657007018",
    "papel higiénico": "8412657007025",
    "papel higienico": "8412657007025",
    "papel cocina": "8412657007032",
    "champú":       "8412657008001",
    "champu":       "8412657008001",
    "gel ducha":    "8412657008018",
    "pasta dientes":"8412657008025",
    "desodorante":  "8412657008032",
}


def buscar_por_ean(ean: str) -> Optional[dict]:
    """Devuelve el producto por EAN exacto o None si no existe."""
    prod = CATALOGO.get(ean)
    if prod:
        return {"ean": ean, **prod, "pasillo_info": PASILLOS.get(prod["pasillo"], {})}
    return None


def buscar_por_nombre(nombre: str) -> Optional[dict]:
    """Busca por alias (nombre genérico) y devuelve el producto completo."""
    nombre_lower = nombre.lower().strip()
    ean = ALIAS.get(nombre_lower)
    if ean:
        return buscar_por_ean(ean)
    # Búsqueda parcial en el catálogo
    for ean_key, prod in CATALOGO.items():
        if nombre_lower in prod["nombre"].lower():
            return {"ean": ean_key, **prod, "pasillo_info": PASILLOS.get(prod["pasillo"], {})}
    return None


def buscar_lista(nombres: list[str]) -> list[dict]:
    """
    Dado un listado de nombres de productos (extraídos del habla),
    devuelve los productos ordenados por pasillo para optimizar el recorrido.
    """
    resultados = []
    no_encontrados = []

    for nombre in nombres:
        prod = buscar_por_nombre(nombre)
        if prod:
            resultados.append(prod)
        else:
            no_encontrados.append(nombre)

    # Ordenar por pasillo para recorrido óptimo
    resultados.sort(key=lambda p: p["pasillo"])

    return resultados, no_encontrados
