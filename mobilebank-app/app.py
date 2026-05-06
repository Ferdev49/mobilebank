# MobileBank API - DevOps Lab Week 3
# - Configuracion via ConfigMap (env vars)
# - Secrets via Secret de Kubernetes
# - Logs persistentes en PVC montado en /app/data
# - Health checks dedicados (/health/live, /health/ready)

from flask import Flask, jsonify, request
from datetime import datetime
from functools import wraps
from pathlib import Path
import logging
import os
import psutil


# ============= CONFIGURACION (Week 3 - desde ConfigMap/Secret) =============

ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
PORT = int(os.getenv("PORT", "5000"))
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

# Feature flags (ConfigMap)
FEATURE_TRANSFER_ENABLED = os.getenv("FEATURE_TRANSFER_ENABLED", "true").lower() == "true"
FEATURE_METRICS_ENABLED = os.getenv("FEATURE_METRICS_ENABLED", "true").lower() == "true"
MAX_TRANSFER_AMOUNT = float(os.getenv("MAX_TRANSFER_AMOUNT", "10000"))

# Secrets (no se loguean nunca, solo se valida que existan)
API_KEY = os.getenv("API_KEY", "")
JWT_SECRET = os.getenv("JWT_SECRET", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

# Almacenamiento persistente (PVC montado en /app/data)
DATA_DIR = Path(os.getenv("DATA_DIR", "/app/data"))
TRANSFERS_LOG = DATA_DIR / "transfers.log"


# ============= LOGGING =============

handlers = [logging.StreamHandler()]
try:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    handlers.append(logging.FileHandler(DATA_DIR / "app.log"))
except (OSError, PermissionError):
    # Si no hay PVC montado (entorno local sin volumen), seguir solo con stdout
    pass

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=handlers,
)
logger = logging.getLogger(__name__)


# ============= APP =============

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False

APP_VERSION = "1.2.0"
START_TIME = datetime.utcnow()

for name, value in (("API_KEY", API_KEY), ("JWT_SECRET", JWT_SECRET), ("DB_PASSWORD", DB_PASSWORD)):
    if not value:
        logger.warning("Secret %s no esta seteado (revisa el Secret de Kubernetes)", name)

logger.info(
    "MobileBank API v%s arrancando | env=%s | log_level=%s | features: transfer=%s metrics=%s",
    APP_VERSION, ENVIRONMENT, LOG_LEVEL, FEATURE_TRANSFER_ENABLED, FEATURE_METRICS_ENABLED,
)


ACCOUNTS_DB = {
    1: {"id": 1, "name": "Checking", "balance": 1500},
    2: {"id": 2, "name": "Savings", "balance": 5000},
}


# ============= DECORADORES =============

def validate_json(f):
    """Validar que el request tenga JSON valido"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not request.is_json:
            logger.warning("Request sin Content-Type: application/json")
            return jsonify({"error": "Content-Type debe ser application/json"}), 400
        return f(*args, **kwargs)
    return decorated_function


def require_fields(*fields):
    """Validar que los campos requeridos esten presentes"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            data = request.get_json()
            missing = [field for field in fields if field not in data]
            if missing:
                logger.warning("Campos faltantes: %s", missing)
                return jsonify({"error": "Campos requeridos faltantes", "missing": missing}), 400
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def feature_flag(flag_value, feature_name):
    """Bloquea la ruta si la feature flag esta apagada"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not flag_value:
                return jsonify({"error": "feature " + feature_name + " disabled"}), 503
            return f(*args, **kwargs)
        return decorated_function
    return decorator


# ============= HEALTH =============

def get_system_health():
    try:
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage("/")
        return {
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "disk_percent": disk.percent,
            "status": "healthy" if cpu_percent < 80 and memory.percent < 85 else "degraded",
        }
    except Exception as e:
        logger.error("Error en system health: %s", e)
        return {"status": "unknown", "error": str(e)}


def get_database_health():
    try:
        if len(ACCOUNTS_DB) > 0:
            return {"status": "connected", "records_count": len(ACCOUNTS_DB)}
        return {"status": "empty"}
    except Exception as e:
        logger.error("Error en DB health: %s", e)
        return {"status": "disconnected", "error": str(e)}


@app.route("/health", methods=["GET"])
def health():
    """Health check completo (uso humano / monitoring)"""
    uptime_seconds = (datetime.utcnow() - START_TIME).total_seconds()
    system_health = get_system_health()
    db_health = get_database_health()

    is_healthy = (
        system_health.get("status") == "healthy"
        and db_health.get("status") in ("connected", "empty")
    )

    response = {
        "status": "healthy" if is_healthy else "unhealthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "uptime_minutes": round(uptime_seconds / 60, 2),
        "system": system_health,
        "database": db_health,
        "features": {
            "transfer": FEATURE_TRANSFER_ENABLED,
            "metrics": FEATURE_METRICS_ENABLED,
        },
    }
    return jsonify(response), (200 if is_healthy else 503)


@app.route("/health/live", methods=["GET"])
def liveness():
    """Liveness probe - la app esta viva"""
    return jsonify({"status": "alive", "environment": ENVIRONMENT}), 200


@app.route("/health/ready", methods=["GET"])
def readiness():
    """Readiness probe - lista para recibir trafico"""
    db_health = get_database_health()
    is_ready = db_health.get("status") in ("connected", "empty")
    if is_ready:
        return jsonify({"status": "ready"}), 200
    return jsonify({"status": "not_ready", "reason": "database"}), 503


# ============= API =============

@app.route("/api/accounts", methods=["GET"])
def get_accounts():
    logger.info("GET /api/accounts")
    accounts = list(ACCOUNTS_DB.values())
    return jsonify({"accounts": accounts, "count": len(accounts)}), 200


@app.route("/api/accounts/<int:account_id>", methods=["GET"])
def get_account(account_id):
    if account_id not in ACCOUNTS_DB:
        return jsonify({"error": "Cuenta no encontrada"}), 404
    return jsonify(ACCOUNTS_DB[account_id]), 200


@app.route("/api/transfer", methods=["POST"])
@feature_flag(FEATURE_TRANSFER_ENABLED, "transfer")
@validate_json
@require_fields("from_account", "to_account", "amount")
def transfer():
    """Transferencia entre cuentas (loguea a archivo persistente en PVC)"""
    data = request.get_json()
    from_id = data.get("from_account")
    to_id = data.get("to_account")
    amount = data.get("amount")

    if not isinstance(amount, (int, float)) or amount <= 0:
        return jsonify({"error": "El monto debe ser positivo"}), 400

    if amount > MAX_TRANSFER_AMOUNT:
        return jsonify({
            "error": "Monto excede el maximo permitido",
            "max_allowed": MAX_TRANSFER_AMOUNT,
        }), 400

    if from_id not in ACCOUNTS_DB or to_id not in ACCOUNTS_DB:
        return jsonify({"error": "Una o ambas cuentas no existen"}), 404

    if ACCOUNTS_DB[from_id]["balance"] < amount:
        return jsonify({"error": "Saldo insuficiente"}), 400

    ACCOUNTS_DB[from_id]["balance"] -= amount
    ACCOUNTS_DB[to_id]["balance"] += amount

    # Log persistente en el PVC (Day 16)
    try:
        with open(TRANSFERS_LOG, "a", encoding="utf-8") as fh:
            fh.write(datetime.utcnow().isoformat() + " | " + str(from_id) + " -> " + str(to_id) + " | " + str(amount) + "\n")
    except (OSError, PermissionError) as e:
        logger.warning("No se pudo escribir transferencia al PVC: %s", e)

    logger.info("Transferencia: %s de %s a %s", amount, from_id, to_id)

    return jsonify({
        "status": "success",
        "message": "Transferencia completada",
        "from_account": ACCOUNTS_DB[from_id],
        "to_account": ACCOUNTS_DB[to_id],
    }), 200


@app.route("/metrics", methods=["GET"])
@feature_flag(FEATURE_METRICS_ENABLED, "metrics")
def metrics():
    system = get_system_health()
    return jsonify({
        "cpu_percent": system.get("cpu_percent"),
        "memory_percent": system.get("memory_percent"),
        "disk_percent": system.get("disk_percent"),
        "uptime_seconds": (datetime.utcnow() - START_TIME).total_seconds(),
        "environment": ENVIRONMENT,
    }), 200


# ============= ERROR HANDLERS =============

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Ruta no encontrada"}), 404


@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({"error": "Metodo no permitido"}), 405


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Error interno del servidor"}), 500


# ============= MAIN =============

if __name__ == "__main__":
    logger.info("MobileBank API v%s iniciando en puerto %s", APP_VERSION, PORT)
    app.run(host="0.0.0.0", port=PORT, debug=DEBUG)
