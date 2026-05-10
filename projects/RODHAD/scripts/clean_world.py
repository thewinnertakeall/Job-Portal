import re

path = "/home/administrador/projects/RODHAD/src/aws-robomaker-hospital-world/worlds/hospital.world"

with open(path, "r") as f:
    lines = f.readlines()

def fix_pose(line):
    m = re.search(r"<pose>(.*?)</pose>", line)
    if not m:
        return line

    parts = m.group(1).split()
    if len(parts) != 6:
        return None

    try:
        x, y, z = float(parts[0]), float(parts[1]), float(parts[2])
    except:
        return None

    # ❌ eliminar objetos fuera del mapa
    if abs(x) > 200 or abs(y) > 200:
        return None

    # ❌ corregir explosiones numéricas
    if abs(z) > 1000:
        z = 0

    return f"<pose>{x:.3f} {y:.3f} {z:.3f} 0 0 0</pose>\n"

new_lines = []

for l in lines:
    if "<pose>" in l:
        fixed = fix_pose(l)
        if fixed:
            new_lines.append(fixed)
    else:
        new_lines.append(l)

with open(path, "w") as f:
    f.writelines(new_lines)

print("✔ WORLD HOSPITAL OPTIMIZADO (PRO)")
