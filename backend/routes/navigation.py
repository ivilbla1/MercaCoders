"""
Rutas de navegación en tienda:
  GET /navigation/pasillos          → lista de pasillos con NaviLens codes
  GET /navigation/pasillo/{num}     → info detallada de un pasillo
  GET /navigation/navileens/{code}  → decodifica un código NaviLens y da instrucciones
  POST /navigation/ruta             → genera ruta óptima entre pasillos
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from data.catalog import PASILLOS

router = APIRouter(prefix="/navigation", tags=["Navegación"])


# ── SCHEMAS LOCALES ───────────────────────────────────────────────────────────

class RutaRequest(BaseModel):
    pasillos_destino: list[int]

class PasoRuta(BaseModel):
    pasillo: int
    nombre: str
    descripcion: str
    navileens_code: str
    instruccion_voz: str

class RutaResponse(BaseModel):
    pasos: list[PasoRuta]
    instruccion_completa: str


# ── HELPERS ───────────────────────────────────────────────────────────────────

INSTRUCCIONES_DESPLAZAMIENTO = {
    (0, 1):  "Avanza recto por la entrada principal hasta el primer pasillo.",
    (0, 3):  "Desde frutería, gira a la izquierda y avanza hasta la zona refrigerada.",
    (1, 3):  "Desde panadería, avanza hacia el fondo y gira a la izquierda.",
    (3, 4):  "Desde lácteos, continúa por la zona refrigerada hasta carnicería.",
    (4, 5):  "Desde carnicería, avanza un paso más hasta pescadería.",
    (5, 6):  "Desde pescadería, gira a la derecha hacia los pasillos centrales.",
    (6, 7):  "Desde despensa, al fondo encontrarás los arcones de congelados.",
    (7, 8):  "Desde congelados, gira a la derecha hacia las bebidas.",
    (8, 9):  "Desde bebidas, continúa recto hasta vinos y cervezas.",
    (9, 10): "Desde vinos, al fondo a la izquierda está el pasillo de limpieza.",
    (10,11): "Desde limpieza, avanza un paso para papel y desechables.",
    (11,12): "Desde papel, gira a la derecha hacia higiene personal.",
}

def _instruccion_entre_pasillos(origen: int, destino: int) -> str:
    instr = INSTRUCCIONES_DESPLAZAMIENTO.get((origen, destino))
    if instr:
        return instr
    if destino > origen:
        return f"Avanza hacia el pasillo {destino}."
    return f"Retrocede hasta el pasillo {destino}."


# ── ENDPOINTS ─────────────────────────────────────────────────────────────────

@router.get("/pasillos")
async def listar_pasillos():
    """Devuelve todos los pasillos con sus códigos NaviLens."""
    return {
        "pasillos": [
            {"numero": num, **info}
            for num, info in sorted(PASILLOS.items())
        ]
    }


@router.get("/pasillo/{numero}")
async def detalle_pasillo(numero: int):
    """Info detallada de un pasillo concreto."""
    info = PASILLOS.get(numero)
    if not info:
        raise HTTPException(status_code=404, detail=f"Pasillo {numero} no encontrado.")
    return {"numero": numero, **info}


@router.get("/navileens/{code}")
async def decodificar_navileens(code: str):
    """
    Decodifica un código NaviLens escaneado y devuelve la ubicación en tienda
    con instrucciones de voz.

    En producción este endpoint recibiría los datos del SDK de NaviLens.
    Ahora busca el pasillo por su navileens_code.
    """
    for num, info in PASILLOS.items():
        if info.get("navileens_code") == code:
            return {
                "pasillo": num,
                "nombre": info["nombre"],
                "descripcion": info["descripcion"],
                "navileens_code": code,
                "mensaje_voz": (
                    f"Has llegado al pasillo {num}: {info['nombre']}. "
                    f"{info['descripcion']}."
                ),
            }
    raise HTTPException(status_code=404, detail=f"Código NaviLens '{code}' no reconocido.")


@router.post("/ruta", response_model=RutaResponse)
async def calcular_ruta(req: RutaRequest):
    """
    Recibe una lista de números de pasillo y calcula la ruta óptima,
    generando instrucciones de voz paso a paso.
    """
    if not req.pasillos_destino:
        raise HTTPException(status_code=400, detail="La lista de pasillos está vacía.")

    # Validar que existan
    for p in req.pasillos_destino:
        if p not in PASILLOS:
            raise HTTPException(status_code=404, detail=f"Pasillo {p} no existe.")

    # Ordenar por número de pasillo (recorrido lineal de la tienda)
    pasillos_ordenados = sorted(set(req.pasillos_destino))

    pasos: list[PasoRuta] = []
    origen = -1

    for idx, pasillo_num in enumerate(pasillos_ordenados):
        info = PASILLOS[pasillo_num]
        instruccion = (
            _instruccion_entre_pasillos(origen, pasillo_num)
            if origen >= 0
            else f"Empieza en el pasillo {pasillo_num}: {info['nombre']}. {info['descripcion']}."
        )
        pasos.append(PasoRuta(
            pasillo=pasillo_num,
            nombre=info["nombre"],
            descripcion=info["descripcion"],
            navileens_code=info["navileens_code"],
            instruccion_voz=instruccion,
        ))
        origen = pasillo_num

    instruccion_completa = " ".join(p.instruccion_voz for p in pasos)
    instruccion_completa += " Has terminado el recorrido. Dirígete a la caja."

    return RutaResponse(pasos=pasos, instruccion_completa=instruccion_completa)
