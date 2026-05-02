# MobileBank API - DevOps Lab Week 3
# Health checks avanzados + Testing automático

from flask import Flask, jsonify, request
from datetime import datetime
import logging
import os
import psutil
from functools import wraps

# CONFIGURACIÓN 
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# Logging configurado
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Metadata de la app
APP_VERSION = "1.1.0"
START_TIME = datetime.utcnow()

# Simulación de BD
ACCOUNTS_DB = {
    1: {"id": 1, "name": "Checking", "balance": 1500},
    2: {"id": 2, "name": "Savings", "balance": 5000}
}

# DECORADORES 
def validate_json(f):
    """Validar que el request tenga JSON válido"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not request.is_json:
            logger.warning(f"Request sin Content-Type: application/json")
            return jsonify({"error": "Content-Type debe ser application/json"}), 400
        return f(*args, **kwargs)
    return decorated_function

def require_fields(*fields):
    """Validar que los campos requeridos estén presentes"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            data = request.get_json()
            missing = [field for field in fields if field not in data]
            if missing:
                logger.warning(f"Campos faltantes: {missing}")
                return jsonify({"error": "Campos requeridos faltantes", "missing": missing}), 400
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# HEALTH CHECKS 
def get_system_health():
    """Obtener estado del sistema"""
    try:
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return {
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "disk_percent": disk.percent,
            "status": "healthy" if cpu_percent < 80 and memory.percent < 85 else "degraded"
        }
    except Exception as e:
        logger.error(f"Error en system health: {e}")
        return {"status": "unknown", "error": str(e)}

def get_database_health():
    """Simular salud de la BD"""
    try:
        if len(ACCOUNTS_DB) > 0:
            return {"status": "connected", "records_count": len(ACCOUNTS_DB)}
        else:
            return {"status": "empty"}
    except Exception as e:
        logger.error(f"Error en DB health: {e}")
        return {"status": "disconnected", "error": str(e)}

# ============= RUTAS =============

@app.route('/health', methods=['GET'])
def health():
    """Health check completo con métricas"""
    uptime_seconds = (datetime.utcnow() - START_TIME).total_seconds()
    uptime_minutes = uptime_seconds / 60
    
    system_health = get_system_health()
    db_health = get_database_health()
    
    is_healthy = (
        system_health.get("status") == "healthy" and
        db_health.get("status") in ["connected", "empty"]
    )
    
    response = {
        "status": "healthy" if is_healthy else "unhealthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": APP_VERSION,
        "uptime_minutes": round(uptime_minutes, 2),
        "system": system_health,
        "database": db_health
    }
    
    status_code = 200 if is_healthy else 503
    logger.info(f"Health check: {response['status']}")
    
    return jsonify(response), status_code


@app.route('/health/live', methods=['GET'])
def liveness():
    """Liveness probe - ¿La app está corriendo?"""
    return jsonify({"status": "alive"}), 200


@app.route('/health/ready', methods=['GET'])
def readiness():
    """Readiness probe - ¿Está lista para recibir tráfico?"""
    db_health = get_database_health()
    is_ready = db_health.get("status") in ["connected", "empty"]
    
    if is_ready:
        return jsonify({"status": "ready"}), 200
    else:
        return jsonify({"status": "not_ready", "reason": "database"}), 503


@app.route('/api/accounts', methods=['GET'])
def get_accounts():
    """Obtener todas las cuentas"""
    try:
        logger.info(f"GET /api/accounts")
        accounts = list(ACCOUNTS_DB.values())
        return jsonify({
            "accounts": accounts,
            "count": len(accounts)
        }), 200
    except Exception as e:
        logger.error(f"Error obteniendo cuentas: {e}")
        return jsonify({"error": "Error interno"}), 500


@app.route('/api/accounts/<int:account_id>', methods=['GET'])
def get_account(account_id):
    """Obtener una cuenta específica"""
    if account_id not in ACCOUNTS_DB:
        return jsonify({"error": "Cuenta no encontrada"}), 404
    
    return jsonify(ACCOUNTS_DB[account_id]), 200


@app.route('/api/transfer', methods=['POST'])
@validate_json
@require_fields('from_account', 'to_account', 'amount')
def transfer():
    """Transferencia entre cuentas"""
    try:
        data = request.get_json()
        from_id = data.get('from_account')
        to_id = data.get('to_account')
        amount = data.get('amount')
        
        # Validaciones
        if not isinstance(amount, (int, float)) or amount <= 0:
            return jsonify({"error": "El monto debe ser positivo"}), 400
        
        if from_id not in ACCOUNTS_DB or to_id not in ACCOUNTS_DB:
            return jsonify({"error": "Una o ambas cuentas no existen"}), 404
        
        if ACCOUNTS_DB[from_id]['balance'] < amount:
            return jsonify({"error": "Saldo insuficiente"}), 400
        
        # Ejecutar transferencia
        ACCOUNTS_DB[from_id]['balance'] -= amount
        ACCOUNTS_DB[to_id]['balance'] += amount
        
        logger.info(f"Transferencia: {amount} de {from_id} a {to_id}")
        
        return jsonify({
            "status": "success",
            "message": "Transferencia completada",
            "from_account": ACCOUNTS_DB[from_id],
            "to_account": ACCOUNTS_DB[to_id]
        }), 200
        
    except Exception as e:
        logger.error(f"Error en transferencia: {e}")
        return jsonify({"error": "Error interno"}), 500


@app.route('/metrics', methods=['GET'])
def metrics():
    """Métricas para monitoring"""
    system = get_system_health()
    return jsonify({
        "cpu_percent": system.get('cpu_percent'),
        "memory_percent": system.get('memory_percent'),
        "disk_percent": system.get('disk_percent'),
        "uptime_seconds": (datetime.utcnow() - START_TIME).total_seconds()
    }), 200


# ============= ERROR HANDLERS =============

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Ruta no encontrada"}), 404

@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({"error": "Método no permitido"}), 405

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Error interno del servidor"}), 500


# ============= MAIN =============

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    
    logger.info(f"🚀 MobileBank API v{APP_VERSION} iniciando en puerto {port}")
    app.run(host='0.0.0.0', port=port, debug=debug)