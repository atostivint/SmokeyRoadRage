import re, random, math
from pathlib import Path

random.seed(42)

path = Path(__file__).parent / "level_highway.tscn"
with open(path) as f:
    text = f.read()

rps = {}
for m in re.finditer(r'\[node name="(RP_\d+)"[^\]]*\]\n((?:(?!\[node).)*)', text, re.DOTALL):
    name = m.group(1)
    body = m.group(2)
    tm = re.search(r'transform = Transform3D\(([^)]+)\)', body)
    nums = [float(x) for x in tm.group(1).split(',')]
    basis_z = nums[6:9]   # RoadPoint's own forward tangent axis
    origin = nums[9:12]
    pm = re.search(r'prior_mag = ([\-0-9.e]+)', body)
    nm = re.search(r'next_mag = ([\-0-9.e]+)', body)
    rps[name] = {
        "basis_z": basis_z,
        "origin": origin,
        "prior_mag": float(pm.group(1)) if pm else None,
        "next_mag": float(nm.group(1)) if nm else None,
    }

names = sorted(rps.keys(), key=lambda n: int(n.split('_')[1]))

def add(a, b, s=1.0):
    return [a[i] + b[i] * s for i in range(3)]

def sub(a, b):
    return [a[i] - b[i] for i in range(3)]

def bezier_point(p0, p1, p2, p3, t):
    mt = 1 - t
    return [
        mt**3 * p0[i] + 3 * mt**2 * t * p1[i] + 3 * mt * t**2 * p2[i] + t**3 * p3[i]
        for i in range(3)
    ]

# Build the exact same cubic Bezier per segment that the road-generator addon
# uses (RoadSegment._set_curve_point): handle = point.origin +/- basis.z * mag.
SEGMENT_SAMPLES = 200  # dense subdivision used to approximate true arc length

master = []  # (x, y, z, cum_dist, tangent_x, tangent_z)
cum = 0.0
prev_pt = None

for i in range(len(names) - 1):
    start = rps[names[i]]
    end = rps[names[i + 1]]
    p0 = start["origin"]
    p1 = add(p0, start["basis_z"], start["next_mag"])
    p3 = end["origin"]
    p2 = sub(p3, [end["basis_z"][k] * end["prior_mag"] for k in range(3)])

    for s in range(SEGMENT_SAMPLES + (1 if i == len(names) - 2 else 0)):
        t = s / SEGMENT_SAMPLES
        pt = bezier_point(p0, p1, p2, p3, t)
        if prev_pt is not None:
            d = math.sqrt(sum((pt[k] - prev_pt[k]) ** 2 for k in range(3)))
            cum += d
            tx, tz = pt[0] - prev_pt[0], pt[2] - prev_pt[2]
            tl = math.sqrt(tx * tx + tz * tz) or 1.0
            tx, tz = tx / tl, tz / tl
        else:
            tx, tz = 0.0, 1.0
        master.append((pt[0], pt[1], pt[2], cum, tx, tz))
        prev_pt = pt

print(f"Total path length: {cum:.1f} m, samples: {len(master)}")

LANE_CENTERS = [-6.0, -2.0, 2.0, 6.0]  # 4 fwd lanes, lane_width=4.0 (scene defaults)

MIN_SPACING = 16.0
MAX_SPACING = 32.0
START_SKIP = 60.0  # keep a clear runway right after the car spawns

def sample_at(dist):
    # binary search would be nicer, but the path is short enough for a linear scan
    for i in range(1, len(master)):
        if master[i][3] >= dist:
            a, b = master[i - 1], master[i]
            span = b[3] - a[3]
            f = 0.0 if span <= 0 else (dist - a[3]) / span
            x = a[0] + (b[0] - a[0]) * f
            y = a[1] + (b[1] - a[1]) * f
            z = a[2] + (b[2] - a[2]) * f
            tx = a[4] + (b[4] - a[4]) * f
            tz = a[5] + (b[5] - a[5]) * f
            tl = math.sqrt(tx * tx + tz * tz) or 1.0
            return x, y, z, tx / tl, tz / tl
    a = master[-1]
    return a[0], a[1], a[2], a[4], a[5]

samples = []
d = START_SKIP
while d < cum:
    x, y, z, tx, tz = sample_at(d)
    # right vector = tangent rotated +90 deg in the XZ plane (matches RoadPoint.basis.x)
    lat = (tz, 0.0, -tx)
    samples.append((x, y, z, lat))
    d += random.uniform(MIN_SPACING, MAX_SPACING)

print(f"Total slots: {len(samples)}")

total = len(samples)
n_obstacles = round(total * 0.5)
n_biches = round(total * 0.3)
n_bystanders = total - n_obstacles - n_biches

categories = (["obstacle"] * n_obstacles) + (["biche"] * n_biches) + (["bystander"] * n_bystanders)
random.shuffle(categories)

print(f"obstacles={n_obstacles} biches={n_biches} bystanders={n_bystanders}")

# Balanced lane assignment: cycle through a shuffled copy of all 4 lanes so no
# side of the road gets starved/overloaded over a run of samples.
lane_cycle = []
def next_lane():
    global lane_cycle
    if not lane_cycle:
        lane_cycle = LANE_CENTERS.copy()
        random.shuffle(lane_cycle)
    return lane_cycle.pop()

ext_ids = {
    "biche": "1_r8dhe",
    "campeur": "8_j5pv8",
    "rock": "9_1b3a5",
    "stump": "10_y8hke",
}

used_ids = set()
def new_uid():
    while True:
        v = random.randint(100000000, 2147483000)
        if v not in used_ids:
            used_ids.add(v)
            return v

nodes = []
counters = {"biche": 0, "campeur": 0, "rock": 0, "stump": 0}

for (x, y, z, lat), cat in zip(samples, categories):
    if cat == "biche":
        res = "biche"
    elif cat == "bystander":
        res = "campeur"
    else:
        res = random.choice(["rock", "stump"])
    counters[res] += 1
    node_name = f"Obstacle{res.capitalize()}Gen{counters[res]}"

    lane_offset = next_lane() + random.uniform(-0.6, 0.6)  # small jitter within the lane
    ox = x + lat[0] * lane_offset
    oy = y + lat[1] * lane_offset
    oz = z + lat[2] * lane_offset

    angle = random.uniform(0, 2 * math.pi)
    c, s = math.cos(angle), math.sin(angle)

    nodes.append(
        f'[node name="{node_name}" parent="ObstacleGroup" unique_id={new_uid()} instance=ExtResource("{ext_ids[res]}")]\n'
        f'transform = Transform3D({c}, 0, {s}, 0, 1, 0, {-s}, 0, {c}, {ox}, {oy}, {oz})\n'
    )

# Remove previously generated obstacle nodes, any leftover manually-placed
# ones, and any prior ObstacleGroup parent, so re-running this script is
# idempotent and everything ends up under the single ObstacleGroup node.
text = re.sub(
    r'\[node name="Obstacle(?:Biche|Campeur|Rock|Stump)\d*(?:Gen\d+)?"[^\]]*\]\n(?:transform[^\n]*\n)?',
    '',
    text,
)
text = re.sub(r'\[node name="ObstacleGroup"[^\]]*\]\n(?:transform[^\n]*\n)?', '', text)
text = re.sub(r'\n{3,}$', '\n\n', text)

group_node = '[node name="ObstacleGroup" type="Node3D" parent="."]\n'
text = text.rstrip('\n') + '\n\n' + group_node + '\n' + '\n'.join(nodes) + '\n'

with open(path, 'w') as f:
    f.write(text)

print("Done. Wrote", len(nodes), "obstacle nodes.")
