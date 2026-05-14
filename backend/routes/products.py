"""
Rutas de productos:
  POST /products/lista        → extrae productos del texto de voz y devuelve lista ordenada
  GET  /products/barcode/{ean} → busca producto por código EAN
  POST /products/validar      → valida que el producto escaneado es el esperado
  GET  /products/buscar       → busca producto por nombre
"""

import json
import os
from fastapi import APIRouter, HTTPException
from anthropic import Anthropic

from data.catalog import (
    buscar_por_ean,
    buscar_por_nombre,
    buscar_lista,
    PASILLOS,
)
from models.schemas import (
    ListaCompraRequest,
    ListaCompraResponse,
    ProductoDetalle,
    ValidarBarcoRequest,
    ValidarBarcoResponse,
    BuscarProductoResponse,
)

router = APIRouter(prefix="/products", tags=["Productos"])

_client = Anthropic()  # usa ANTHROPIC_API_KEY del entorno


# ── HELPERS ───────────────────────────────────────────────────────────────────

def _extraer_productos_con_ia(texto: str) -> list[str]:
    """
    Usa Claude para extraer una lista limpia de productos a partir del texto
    dictado por el usuario. Devuelve los nombres en español tal como los
    entendería alguien que va al súper.
    """
    respuesta = _client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=500,
        system=(
            "Eres un asistente de supermercado. El usuario te dará un texto hablado "
            "con su lista de la compra. Extrae solo los nombres de los productos, "
            "normalizados y en singular, sin cantidades ni marcas. "
            "Responde ÚNICAMENTE con un JSON válido de la forma: "
            '{"productos": ["producto1", "producto2", ...]}'
            "Sin markdown, sin texto adicional."
        ),
        messages=[{"role": "user", "content": texto}],
    )
    try:
        data = json.loads(respuesta.content[0].text)
        return data.get("productos", [])
    except (json.JSONDecodeError, IndexError):
        # Fallback: dividir por comas y comas
        return [p.strip().lower() for p in texto.replace("y ", "").split(",") if p.strip()]


def _texto_posicion(posicion: str) -> str:
    mapa = {
        "suelo": "en el suelo",
        "bajo": "en la estantería baja",
        "centro": "en la estantería a media altura",
        "alto": "en la estantería alta",
    }
    return mapa.get(posicion, "en la estantería")


def _generar_mensaje_voz(productos: list[ProductoDetalle]) -> str:
    if not productos:
        return "No he encontrado ningún producto. Por favor, vuelve a dictar tu lista."
    
    lineas = []
    pasillo_actual = -1
    for prod in productos:
        if prod["pasillo"] != pasillo_actual:
            pasillo_actual = prod["pasillo"]
            info_pasillo = PASILLOS.get(pasillo_actual, {})
            lineas.append(
                f"Dirígete al pasillo {pasillo_actual}, "
                f"{info_pasillo.get('descripcion', '')}. "
                f"Aquí encontrarás:"
            )
        lineas.append(
            f"{prod['nombre']}, {_texto_posicion(prod['posicion'])}."
        )
    return " ".join(lineas)


# ── ENDPOINTS ─────────────────────────────────────────────────────────────────

@router.post("/lista", response_model=ListaCompraResponse)
async def procesar_lista(req: ListaCompraRequest):
    """
    Recibe el texto dictado por el usuario, extrae los productos
    (con Claude si usar_ia=True), los localiza en el catálogo y
    devuelve la lista ordenada por pasillo.
    """
    if not req.texto_voz.strip():
        raise HTTPException(status_code=400, detail="El texto de voz está vacío.")

    # 1. Extraer nombres de productos
    if req.usar_ia:
        nombres = _extraer_productos_con_ia(req.texto_voz)
    else:
        nombres = [p.strip().lower() for p in req.texto_voz.replace(" y ", ",").split(",") if p.strip()]

    if not nombres:
        raise HTTPException(status_code=422, detail="No se han podido extraer productos del texto.")

    # 2. Buscar en catálogo y ordenar
    encontrados_raw, no_encontrados = buscar_lista(nombres)

    # Convertir a Pydantic
    encontrados = [ProductoDetalle(**p) for p in encontrados_raw]

    # 3. Construir mensaje de voz
    msg_voz = _generar_mensaje_voz([p.model_dump() for p in encontrados])
    if no_encontrados:
        msg_voz += (
            f" No he encontrado los siguientes productos: "
            + ", ".join(no_encontrados)
            + "."
        )

    return ListaCompraResponse(
        productos_encontrados=encontrados,
        productos_no_encontrados=no_encontrados,
        orden_recorrido=encontrados,   # ya vienen ordenados por pasillo
        total_productos=len(encontrados),
        mensaje_voz=msg_voz,
    )


@router.get("/barcode/{ean}", response_model=BuscarProductoResponse)
async def buscar_barcode(ean: str):
    """
    Devuelve la información completa de un producto por su código EAN.
    """
    prod_raw = buscar_por_ean(ean)
    if not prod_raw:
        return BuscarProductoResponse(
            producto=None,
            encontrado=False,
            mensaje_voz=f"Código {ean} no encontrado en el catálogo.",
        )
    prod = ProductoDetalle(**prod_raw)
    info = prod_raw.get("pasillo_info", {})
    msg = (
        f"{prod.nombre}. "
        f"Pasillo {prod.pasillo}, {info.get('descripcion', '')}. "
        f"{_texto_posicion(prod.posicion)}."
    )
    return BuscarProductoResponse(producto=prod, encontrado=True, mensaje_voz=msg)


@router.post("/validar", response_model=ValidarBarcoResponse)
async def validar_barcode(req: ValidarBarcoRequest):
    """
    Valida que el producto escaneado (EAN) corresponde al producto esperado.
    Devuelve si es correcto y el mensaje de voz adecuado.
    """
    prod_raw = buscar_por_ean(req.ean)
    if not prod_raw:
        return ValidarBarcoResponse(
            correcto=False,
            producto=None,
            mensaje_voz="Producto no reconocido. Inténtalo de nuevo.",
        )

    prod = ProductoDetalle(**prod_raw)
    nombre_lower = req.nombre_esperado.lower().strip()
    nombre_prod_lower = prod.nombre.lower()

    # Comprobación flexible: el nombre esperado debe ser substring del nombre real
    es_correcto = nombre_lower in nombre_prod_lower or nombre_prod_lower in nombre_lower

    if es_correcto:
        msg = f"Correcto. Has cogido {prod.nombre}. Añadido a tu cesta."
    else:
        msg = (
            f"Este producto es {prod.nombre}, pero buscabas {req.nombre_esperado}. "
            f"Por favor, sigue buscando."
        )

    return ValidarBarcoResponse(correcto=es_correcto, producto=prod, mensaje_voz=msg)


@router.get("/buscar", response_model=BuscarProductoResponse)
async def buscar_nombre(q: str):
    """
    Busca un producto por nombre (alias o texto parcial).
    """
    prod_raw = buscar_por_nombre(q)
    if not prod_raw:
        return BuscarProductoResponse(
            producto=None,
            encontrado=False,
            mensaje_voz=f"No he encontrado '{q}' en el catálogo.",
        )
    prod = ProductoDetalle(**prod_raw)
    info = prod_raw.get("pasillo_info", {})
    msg = (
        f"{prod.nombre}. "
        f"Pasillo {prod.pasillo}: {info.get('nombre', '')}. "
        f"{_texto_posicion(prod.posicion)}."
    )
    return BuscarProductoResponse(producto=prod, encontrado=True, mensaje_voz=msg)
