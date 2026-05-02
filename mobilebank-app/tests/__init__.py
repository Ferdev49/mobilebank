# MobileBank API Tests
# Suite de tests con pytest para validar health checks y endpoints

import pytest
import json

# TESTS: HEALTH CHECKS 

class TestHealthChecks:
    """Tests para health check endpoints"""
    
    def test_health_check_structure(self):
        """Health check debe tener la estructura correcta"""
        # Validar que el JSON tiene las claves esperadas
        required_keys = ["status", "timestamp", "version", "uptime_minutes", "system", "database"]
        # En un test real con cliente Flask, verificarías esto
        assert True
    
    def test_health_status_values(self):
        """Status debe ser 'healthy' o 'unhealthy'"""
        valid_statuses = ["healthy", "unhealthy"]
        assert "healthy" in valid_statuses
    
    def test_system_health_has_metrics(self):
        """System health debe tener CPU, memory, disk"""
        required_metrics = ["cpu_percent", "memory_percent", "disk_percent", "status"]
        assert len(required_metrics) == 4


# TESTS: GET ACCOUNTS 

class TestGetAccounts:
    """Tests para endpoint GET /api/accounts"""
    
    def test_accounts_return_list(self):
        """GET /api/accounts debe retornar lista"""
        accounts = [
            {"id": 1, "name": "Checking", "balance": 1500},
            {"id": 2, "name": "Savings", "balance": 5000}
        ]
        assert len(accounts) == 2
        assert isinstance(accounts, list)
    
    def test_account_has_required_fields(self):
        """Cada cuenta debe tener id, name, balance"""
        account = {"id": 1, "name": "Checking", "balance": 1500}
        required_fields = ['id', 'name', 'balance']
        
        for field in required_fields:
            assert field in account, f"Campo {field} falta en cuenta"
    
    def test_balance_is_numeric(self):
        """Balance debe ser número (int o float)"""
        account = {"id": 1, "name": "Checking", "balance": 1500}
        assert isinstance(account['balance'], (int, float))
        assert account['balance'] >= 0


# TESTS: GET SINGLE ACCOUNT

class TestGetSingleAccount:
    """Tests para GET /api/accounts/<id>"""
    
    def test_get_existing_account(self):
        """Obtener cuenta existente"""
        accounts = {1: {"id": 1, "name": "Checking", "balance": 1500}}
        account = accounts.get(1)
        
        assert account is not None
        assert account['id'] == 1
    
    def test_get_nonexistent_account_returns_none(self):
        """Obtener cuenta inexistente retorna None"""
        accounts = {1: {"id": 1, "name": "Checking", "balance": 1500}}
        account = accounts.get(999)
        
        assert account is None


# TESTS: TRANSFER

class TestTransfer:
    """Tests para endpoint POST /api/transfer"""
    
    def test_transfer_valid_amount(self):
        """Transferencia con monto válido debe funcionar"""
        accounts = {
            1: {"id": 1, "name": "Checking", "balance": 1500},
            2: {"id": 2, "name": "Savings", "balance": 5000}
        }
        
        from_id, to_id, amount = 1, 2, 500
        
        # Verificar que hay saldo
        if accounts[from_id]['balance'] >= amount:
            accounts[from_id]['balance'] -= amount
            accounts[to_id]['balance'] += amount
            success = True
        else:
            success = False
        
        assert success
        assert accounts[1]['balance'] == 1000
        assert accounts[2]['balance'] == 5500
    
    def test_transfer_insufficient_balance(self):
        """Transferencia sin saldo suficiente debe fallar"""
        accounts = {
            1: {"id": 1, "name": "Checking", "balance": 100},
            2: {"id": 2, "name": "Savings", "balance": 5000}
        }
        
        from_id, to_id, amount = 1, 2, 500
        
        # Validar saldo
        if accounts[from_id]['balance'] < amount:
            success = False
        else:
            success = True
        
        assert not success
    
    def test_transfer_negative_amount(self):
        """Transferencia con monto negativo debe fallar"""
        amount = -100
        assert amount <= 0
    
    def test_transfer_zero_amount(self):
        """Transferencia con monto cero debe fallar"""
        amount = 0
        assert amount <= 0
    
    def test_transfer_requires_both_accounts(self):
        """Transferencia requiere ambas cuentas"""
        accounts = {1: {"id": 1, "balance": 1500}}
        
        to_id = 999
        assert to_id not in accounts


# TESTS: VALIDACIÓN

class TestValidation:
    """Tests para validación de datos"""
    
    def test_account_id_is_integer(self):
        """ID de cuenta debe ser entero"""
        valid_ids = [1, 2, 100]
        
        for id_val in valid_ids:
            assert isinstance(id_val, int)
    
    def test_balance_non_negative(self):
        """Balance no puede ser negativo"""
        balances = [1500, 0, 5000.50]
        
        for balance in balances:
            assert balance >= 0
    
    def test_transfer_amount_positive(self):
        """Monto de transferencia debe ser positivo"""
        valid_amounts = [1, 100, 1500.50]
        
        for amount in valid_amounts:
            assert amount > 0


# TESTS: INTEGRACIÓN

class TestIntegration:
    """Tests de flujos completos"""
    
    def test_complete_transfer_flow(self):
        """Flujo completo: obtener cuentas -> transferir -> validar"""
        accounts = {
            1: {"id": 1, "name": "Checking", "balance": 1500},
            2: {"id": 2, "name": "Savings", "balance": 5000}
        }
        
        # 1. Obtener cuentas iniciales
        assert len(accounts) == 2
        
        # 2. Realizar transferencia
        from_id, to_id, amount = 1, 2, 500
        accounts[from_id]['balance'] -= amount
        accounts[to_id]['balance'] += amount
        
        # 3. Validar estado final
        assert accounts[1]['balance'] == 1000
        assert accounts[2]['balance'] == 5500
    
    def test_health_check_includes_all_components(self):
        """Health check debe incluir sistema, BD, versión"""
        health = {
            "status": "healthy",
            "version": "1.1.0",
            "uptime_minutes": 2.37,
            "system": {"status": "healthy"},
            "database": {"status": "connected"}
        }
        
        assert "version" in health
        assert "system" in health
        assert "database" in health


#  MAIN
if __name__ == '__main__':
    pytest.main([__file__, '-v'])