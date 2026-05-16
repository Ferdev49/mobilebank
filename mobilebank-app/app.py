# MobileBank API - DevOps Lab Week 4 - Day 19
# - Configuracion via ConfigMap (env vars)
# - Secrets via Secret de Kubernetes
# - Logs persistentes en PVC montado en /app/data
# - Health checks dedicados (/health/live, /health/ready)
# - Metricas en formato OpenMetrics nativo (Day 19) via prometheus-client

from flask import Flask, jsonify, request, Response
from datetime import datetime
from functools import wraps
from pathlib import Path
import logging
import os
import time
import psutil

from prometheus_client import (
    Counter, Histogram, Gauge,
    CONTENT_TYPE_LATEST, generate_latest,
)


# ============= CONFIGURACION =============

ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
PORT = int(os.getenv("PORT", "5000"))
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

FEATURE_TRANSFER_ENABLED = os.getenv("FEATURE_TRANSFER_ENABLED", "true").lower() == "true"
FEATURE_METRICS_ENABLED = os.getenv("FEATURE_METRICS_ENABLED", "true").lower() == "true"
MAX_TRANSFER_AMOUNT = float(os.getenv("MAX_TRANSFER_AMOUNT", "10000"))

API_KEY = os.getenv("API_KEY", "")
JWT_SECRET = os.getenv("JWT_SECRET", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

DATA_DIR = Path(os.getenv("DATA_DIR", "/app/data"))
TRANSFERS_LOG = DATA_DIR / "transfers.log"


# ============= LOGGING =============

handlers = [logging.StreamHandler()]
try:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    handlers.append(logging.FileHandler(DATA_DIR / "app.log"))
except (OSError, PermissionError):
    pass

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=handlers,
)
logger = logging.getLogger(__name__)


# ============= PROMETHEUS METRICS (Day 19) =============

# Contador de requests HTTP por metodo, endpoint, codigo
HTTP_REQUESTS = Counter(
    "mobilebank_http_requests_total",
    "Total HTTP requests servidos por la API",
    ["method", "endpoint", "status"],
)

# Histograma de latencias en segundos
HTTP_DURATION = Histogram(
    "mobilebank_http_request_duration_seconds",
    "Duracion de requests HTTP en segundos",
    ["method", "endpoint"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10),
)

# Contador especifico de transferencias
TRANSFERS = Counter(
    "mobilebank_transfers_total",
    "Total transferencias procesadas",
    ["status"],  # success, insufficient_funds, invalid, blocked
)

# Gauge con saldo total simulado
TOTAL_BALANCE = Gauge(
    "mobilebank_total_balance",
    "Suma de saldos en todas las cuentas",
)

# Gauge con info de version/environment (label cardinality fija)
APP_INFO = Gauge(
    "mobilebank_app_info",
    "Metadata de la app (label-only)",
    ["version", "environment"],
)


# ============= APP =============

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False

APP_VERSION = "1.3.0"
START_TIME = datetime.utcnow()

APP_INFO.labels(version=APP_VERSION, environment=ENVIRONMENT).set(1)

for name, value in (("API_KEY", API_KEY), ("JWT_SECRET", JWT_SECRET), ("DB_PASSWORD", DB_PASSWORD)):
    if not value:
        logger.warning("Secret %s no esta seteado", name)

logger.info(
    "MobileBank API v%s arrancando | env=%s | log_level=%s",
    APP_VERSION, ENVIRONMENT, LOG_LEVEL,
)


ACCOUNTS_DB = {
    1: {"id": 1, "name": "Checking", "balance": 1500},
    2: {"id": 2, "name": "Savings", "balance": 5000},
}


def _update_total_balance():
    TOTAL_BALANCE.set(sum(a["balance"] for a in ACCOUNTS_DB.values()))


_update_total_balance()


# ============= MIDDLEWARE DE METRICAS =============

@app.before_request
def _start_timer():
    request._start_time = time.time()


@app.after_request
def _record_metrics(response):
    # Excluir /metrics para no contarse a si mismo
    endpoint = request.endpoint or request.path
    if endpoint == "metrics":
        return response

    duration = time.time() - getattr(request, "_start_time", time.time())
    HTTP_REQUESTS.labels(
        method=request.method,
        endpoint=endpoint,
        status=str(response.status_code),
    ).inc()
    HTTP_DURATION.labels(
        method=request.method,
        endpoint=endpoint,
    ).observe(duration)
    return response


# ============= DECORADORES =============

def validate_json(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not request.is_json:
            return jsonify({"error": "Content-Type debe ser application/json"}), 400
        return f(*args, **kwargs)
    return decorated_function


def require_fields(*fields):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            data = request.get_json()
            missing = [field for field in fields if field not in data]
            if missing:
                return jsonify({"error": "Campos requeridos faltantes", "missing": missing}), 400
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def feature_flag(flag_value, feature_name):
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
        return {"status": "unknown", "error": str(e)}


def get_database_health():
    if len(ACCOUNTS_DB) > 0:
        return {"status": "connected", "records_count": len(ACCOUNTS_DB)}
    return {"status": "empty"}


@app.route("/health", methods=["GET"])
def health():
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
    return jsonify({"status": "alive", "environment": ENVIRONMENT}), 200


@app.route("/health/ready", methods=["GET"])
def readiness():
    db_health = get_database_health()
    is_ready = db_health.get("status") in ("connected", "empty")
    if is_ready:
        return jsonify({"status": "ready"}), 200
    return jsonify({"status": "not_ready", "reason": "database"}), 503


# ============= API =============

@app.route("/api/accounts", methods=["GET"])
def get_accounts():
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
    data = request.get_json()
    from_id = data.get("from_account")
    to_id = data.get("to_account")
    amount = data.get("amount")

    if not isinstance(amount, (int, float)) or amount <= 0:
        TRANSFERS.labels(status="invalid").inc()
        return jsonify({"error": "El monto debe ser positivo"}), 400

    if amount > MAX_TRANSFER_AMOUNT:
        TRANSFERS.labels(status="blocked").inc()
        return jsonify({
            "error": "Monto excede el maximo permitido",
            "max_allowed": MAX_TRANSFER_AMOUNT,
        }), 400

    if from_id not in ACCOUNTS_DB or to_id not in ACCOUNTS_DB:
        TRANSFERS.labels(status="invalid").inc()
        return jsonify({"error": "Una o ambas cuentas no existen"}), 404

    if ACCOUNTS_DB[from_id]["balance"] < amount:
        TRANSFERS.labels(status="insufficient_funds").inc()
        return jsonify({"error": "Saldo insuficiente"}), 400

    ACCOUNTS_DB[from_id]["balance"] -= amount
    ACCOUNTS_DB[to_id]["balance"] += amount
    _update_total_balance()
    TRANSFERS.labels(status="success").inc()

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
    """Endpoint OpenMetrics nativo (Day 19) - lo consume Prometheus."""
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


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
