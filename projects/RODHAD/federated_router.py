import hashlib

MANSIONS = [
    "https://github.com/thewinnertakeall/AlgoritmoGenetico",
    "https://github.com/thewinnertakeall/BIG-DATA---MATEO---GRUPO-2",
    "https://github.com/thewinnertakeall/turtle_controller.py",
    "https://github.com/poliLab/Mateo_BiodiversidadColombia",
    "https://github.com/thewinnertakeall/Job-Portal",
    "https://github.com/edocg/job-portal",
    "https://github.com/stuckfrecuency-hub/fonio-records",
    "https://github.com/thewinnertakeall/RMIStudent",
    "https://github.com/thewinnertakeall/microprojectPDYP",
    "https://github.com/thewinnertakeall/my-pokemon-app",
    "https://github.com/thewinnertakeall/car-dealestship",
    "https://github.com/thewinnertakeall/xmluno",
    "https://github.com/thewinnertakeall/xmluno.xml",
    "https://github.com/thewinnertakeall/turtle_controller.pyCOPY"
]

def get_compliance_zone(payload):
    clean_input = payload.strip().lower().encode('utf-8')
    hash_hex = hashlib.sha256(clean_input).hexdigest()
    zone_index = int(hash_hex, 16) % 14
    return {"zone": zone_index, "mansion": MANSIONS[zone_index]}

# Test the engine
result = get_compliance_zone("Heat Flux Audit")
print(f"RODHAD FEDERATED SYSTEM | Targeting Zone: {result['zone']}")
print(f"Physical Location: {result['mansion']}")
