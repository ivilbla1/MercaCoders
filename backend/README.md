# Backend MercaCoders

## Requisitos
- Python 3.11+ (o 3.10)
- `pip`
- `ANTHROPIC_API_KEY` si quieres usar IA en `/products/lista`

## Instalación

Desde la carpeta `backend`:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate
pip install -r requirements.txt
```

## Ejecución

```powershell
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Luego accede a:
- `http://127.0.0.1:8000/`
- `http://127.0.0.1:8000/products/buscar?q=leche`
- `http://127.0.0.1:8000/navigation/pasillos`

## Notas
- Si no tienes clave de Anthropic, llama a `/products/lista` con `usar_ia=false`.
- El backend expone rutas para productos y navegación en tienda.
