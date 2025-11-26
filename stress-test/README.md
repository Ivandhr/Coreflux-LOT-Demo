# Alert Testing with Stress Test

> Trigger real CPU and memory alerts by creating actual system load - perfect for testing your CoreFlux LOT alerting pipeline.

---

## Why This Exists

You've built a monitoring system with thresholds, but your idle system sits at 5% CPU. How do you know your alerts actually work?

This script creates **controlled, temporary load** on your system to push metrics above your alert thresholds. Watch your entire pipeline respond in real-time.

---

## Quick Start

```bash
# Test CPU alerts (spikes to ~60% for 15 seconds)
./stress-test/test.sh cpu

# Test Memory alerts (allocates ~60% RAM for 15 seconds)
./stress-test/test.sh memory

# Test both simultaneously
./stress-test/test.sh both

# Stop the test early if needed
./stress-test/test.sh stop
```

---

## What Happens When You Run It

| Phase | Duration | What's Happening |
|-------|----------|-----------------|
| Ramp Up | ~2 seconds | Load increases to ~60% |
| Hold | 15 seconds | Sustained load to trigger alerts |
| Auto-Stop | After 15 seconds | Container terminates, load returns to normal |

The script runs inside a Docker container, so it's isolated and easy to clean up.

---

## Expected Alert Behavior

Based on the default thresholds in `demo/glances.lotnb`:

| Load Level | Threshold | Alert Severity | MQTT Topic |
|------------|-----------|----------------|------------|
| CPU > 25% | WARNING | Low priority | `alerts/cpu/{hostname}` |
| CPU > 50% | CRITICAL | High priority | `alerts/cpu/{hostname}` |
| Memory > 25% | WARNING | Low priority | `alerts/memory/{hostname}` |
| Memory > 50% | CRITICAL | High priority | `alerts/memory/{hostname}` |

Since the stress test pushes to ~60%, you should see **CRITICAL** alerts fire.

---

## Watching Alerts in Real-Time

### Option 1: MQTT Explorer (Recommended)

1. Open [http://localhost:4000](http://localhost:4000)
2. Subscribe to `alerts/#`
3. Run the stress test
4. Watch alerts appear within seconds

### Option 2: Glances Web UI

1. Open [http://localhost:61208](http://localhost:61208)
2. Watch the CPU/memory graphs spike
3. Correlate with alerts in MQTT Explorer

### Option 3: Database Queries

```sql
-- In pgAdmin (http://localhost:5050)
SELECT * FROM metrics.alerts
ORDER BY event_time DESC
LIMIT 10;
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Linux | Fully supported | Native bash |
| Windows | Fully supported | Use Git Bash (included with Git for Windows) |
| macOS | Fully supported | Native bash |

---

## Requirements

Before running the stress test:

- **Docker** must be running
- **`coreflux-network`** must exist (created automatically by `docker-compose up`)
- **`polinux/stress`** image will be downloaded on first run (~10MB)

---

## Troubleshooting

### Script won't run on Windows

**Symptoms**: Double-clicking the script opens Notepad, or PowerShell shows errors.

**Solution**: Use Git Bash, not PowerShell or CMD.

```bash
# Option 1: Right-click in the stress-test folder
# Select "Git Bash Here"
# Then run: ./test.sh cpu

# Option 2: Open Git Bash and navigate
cd /c/path/to/Coreflux/stress-test
./test.sh cpu
```

### "Container already exists" error

**Symptoms**: Script fails with a message about existing containers.

**Solution**:
```bash
./test.sh stop
# Then try again
./test.sh cpu
```

### Alerts not firing despite high CPU

**Symptoms**: Glances shows high CPU, but no alerts appear.

**Checklist**:
1. Is the LOT code deployed to CoreFlux Hub? (not just open in notebook)
2. Are metrics flowing? Check `metrics/+/system/cpu` in MQTT Explorer
3. Are thresholds correct? Default is 50% for CRITICAL

### Load doesn't reach 60%

**Symptoms**: CPU only reaches 30-40% during the test.

**Explanation**: The stress test targets ~60% based on typical systems. Results vary based on:
- Number of CPU cores
- Other running processes
- Container resource limits

**Solution**: Edit `test.sh` and adjust the `--cpu` parameter.

### Network not found error

**Symptoms**: Docker complains that `coreflux-network` doesn't exist.

**Solution**: Start the main infrastructure first:
```bash
cd ..
docker-compose up -d
```

---

## Customizing the Load

Want different load levels? Edit `test.sh` and adjust these parameters:

```bash
# CPU load (number of CPU workers)
--cpu 2          # Increase for more CPU load

# Memory load (amount to allocate)
--vm-bytes 2G    # Adjust based on your system RAM

# Duration
--timeout 60s    # How long to maintain the load
```

---

## Safety Notes

- The stress test is **temporary** - it stops automatically after 15 seconds
- It runs in a **Docker container** - your host system isn't directly affected
- Resource usage returns to **normal immediately** when the container stops
- If something goes wrong, `./test.sh stop` kills the container instantly
