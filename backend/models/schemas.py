from typing import List, Optional

from pydantic import BaseModel


class ProductoDetalle(BaseModel):
    ean: str
    nombre: str
    pasillo: int
    posicion: str
    categoria: str
    unidad: str
    pasillo_info: Optional[dict] = None


class ListaCompraRequest(BaseModel):
    texto_voz: str
    usar_ia: bool = True


class ListaCompraResponse(BaseModel):
    productos_encontrados: List[ProductoDetalle]
    productos_no_encontrados: List[str]
    orden_recorrido: List[ProductoDetalle]
    total_productos: int
    mensaje_voz: str


class ValidarBarcoRequest(BaseModel):
    ean: str
    nombre_esperado: str


class ValidarBarcoResponse(BaseModel):
    correcto: bool
    producto: Optional[ProductoDetalle] = None
    mensaje_voz: str


class BuscarProductoResponse(BaseModel):
    producto: Optional[ProductoDetalle] = None
    encontrado: bool
    mensaje_voz: str
