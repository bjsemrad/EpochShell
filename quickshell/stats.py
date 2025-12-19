#!/usr/bin/env python3
import time, json, os, sys

INTERVAL = 1.0          # seconds

def read_cpu_stat():
    with open("/proc/stat") as f:
        for line in f:
            if line.startswith("cpu "):
                parts = line.split()
                vals = list(map(int, parts[1:]))
                idle = vals[3] + vals[4]   # idle + iowait
                total = sum(vals)
                return idle, total
    return 0, 0

def read_mem_usage():
    mem_total = mem_avail = None
    with open("/proc/meminfo") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                mem_total = int(line.split()[1])
            elif line.startswith("MemAvailable:"):
                mem_avail = int(line.split()[1])
    if not mem_total or mem_avail is None:
        return 0.0
    used = mem_total - mem_avail
    return used / mem_total

def read_disk_usage(path="/"):
    st = os.statvfs(path)
    total = st.f_blocks * st.f_frsize
    used = (st.f_blocks - st.f_bfree) * st.f_frsize
    return used / total if total > 0 else 0.0

def pick_iface():
    base = "/sys/class/net"
    try:
        names = [n for n in os.listdir(base)
                 if n != "lo" and os.path.isdir(os.path.join(base, n))]
    except FileNotFoundError:
        return None
    # Prefer something that's "up"
    for name in names:
        operstate = os.path.join(base, name, "operstate")
        try:
            with open(operstate) as f:
                if f.read().strip() == "up":
                    return name
        except FileNotFoundError:
            continue
    return names[0] if names else None

def read_net_bytes(iface):
    base = f"/sys/class/net/{iface}/statistics"
    try:
        with open(os.path.join(base, "rx_bytes")) as f:
            rx = int(f.read())
        with open(os.path.join(base, "tx_bytes")) as f:
            tx = int(f.read())
        return rx + tx
    except FileNotFoundError:
        return 0

def main():
    if len(sys.argv) > 1:
        iface = sys.argv[1]
    else:
        iface = pick_iface()

    if not iface:
        # If we really have nothing, just output zeros
        while True:
            print(json.dumps({
                "cpu": 0.0, "mem": 0.0, "disk": 0.0,
                "net_mbps": 0.0, "iface": "none"
            }), flush=True)
            time.sleep(INTERVAL)
            continue

    idle0, total0 = read_cpu_stat()
    net0 = read_net_bytes(iface)
    t0 = time.time()

    # small delay so we can compute deltas
    time.sleep(INTERVAL)

    # while True:
    idle1, total1 = read_cpu_stat()
    net1 = read_net_bytes(iface)
    t1 = time.time()

    dt = max(t1 - t0, 1e-6)
    didle = idle1 - idle0
    dtotal = total1 - total0

    cpu = 0.0
    if dtotal > 0:
        cpu = 1.0 - (didle / dtotal)

    mem = read_mem_usage()
    disk = read_disk_usage("/")

    dbytes = max(0, net1 - net0)
    net_bps = dbytes / dt
    net_mbps = net_bps * 8.0 / 1e6   # Mb/s

    data = {
        "cpu": max(0.0, min(1.0, cpu)),
        "mem": max(0.0, min(1.0, mem)),
        "disk": max(0.0, min(1.0, disk)),
        "net_mbps": net_mbps,
        "iface": iface,
    }

    print(json.dumps(data), flush=True)

    idle0, total0 = idle1, total1
    t0 = t1
        # net0, t0 = net1, t1
        # time.sleep(INTERVAL)

if __name__ == "__main__":
    main()
