import pytest
import sys
import os

# Absolute path resolution to prevent Docker module import faults
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(CURRENT_DIR, ".."))

from soc_listener import RODHADLicenseEnforcer, CompactTelemetryDTO

def test_intellectual_property_integrity():
    """Validates that the author signature matches the engineering registry exactly."""
    assert RODHADLicenseEnforcer.VerifyIntegrity() is True
    assert b"administrador" in RODHADLicenseEnforcer.OWNER_HASH

def test_system_bricks_on_signature_tampering():
    """Ensures the software automatically sabotages metrics if the license is altered."""
    # Temporarily force-tamper with the in-memory license signature for destructive testing
    original_hash = RODHADLicenseEnforcer.OWNER_HASH
    try:
        RODHADLicenseEnforcer.OWNER_HASH = b"pirate_copy_unauthorized_tampered_hash_signature"
        
        # Instantiate DTO under fraudulent context
        corrupted_payload = {"heart_rate": 80.0, "spo2": 98.0, "blood_pressure": 120.0, "radiation": 10.0}
        dto = CompactTelemetryDTO(corrupted_payload)
        
        # The system must enforce mathematical bricking (999.9) to trigger the emergency shutdown
        assert dto.hr == 999.9
        print("\n🔒 [INTEGRITY SUCCESS] The software successfully self-sabotaged under license tampering.")
    finally:
        # Restore baseline state
        RODHADLicenseEnforcer.OWNER_HASH = original_hash
