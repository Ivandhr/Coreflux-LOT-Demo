# Glances System Monitoring with CoreFlux LOT

> Transform raw system metrics into a complete monitoring and alerting platform using the Language of Things (LOT).

---

## What You'll Build

This demo creates a full monitoring pipeline that:

1. **Collects** raw CPU, memory, and uptime data from [Glances](https://github.com/nicolargo/glances)
2. **Transforms** messy JSON into clean, typed metrics
3. **Monitors** thresholds and fires intelligent alerts (WARNING/CRITICAL)
4. **Stores** everything in TimescaleDB for historical analysis
5. **Aggregates** data automatically with scheduled queries

All of this is defined in declarative LOT code - no traditional programming required.

---

## Files in This Directory

| File | Description |
|------|-------------|
| `glances.lotnb` | The main LOT Notebook - **start here** |

The notebook is designed to be read like a tutorial. Each cell builds on the previous one, with explanations of every concept along the way.

---

## Prerequisites

Before opening the notebook, make sure you have:

- **CoreFlux Hub** running and connected
- **Infrastructure services** started (see main README for `docker-compose up`)
- **CoreFlux LOT Notebook** application installed

> **Important - Default Credentials**: CoreFlux Hub ships with default credentials: username `root`, password `coreflux`. **Change these immediately after installation** for any non-demo environment.

---

## Getting Started

1. **Start the infrastructure** (from the project root):
   ```bash
   docker-compose up -d
   ```

2. **Open the LOT Notebook application**

3. **Load `glances.lotnb`** from this directory

4. **Read through the cells** - they explain:
   - How to define data models with inheritance
   - How to create Actions that respond to MQTT topics
   - How to implement threshold-based alerting
   - How to persist data to TimescaleDB
   - How to run scheduled aggregations

5. **Deploy to CoreFlux Hub** following the instructions in the notebook

---

## What's Inside the Notebook

The `glances.lotnb` file contains:

### Data Models (5 total)

| Model | Purpose |
|-------|---------|
| `base` | Common fields shared by all metrics |
| `numericValue` | For numeric measurements (extends base) |
| `stringValue` | For text values (extends base) |
| `timeValue` | For timestamps and durations (extends base) |
| `Alert` | For threshold violation events |

### Actions (5 total)

| Action | Subscribes To | Publishes To |
|--------|--------------|--------------|
| CPU Transformer | `glances/+/cpu/total` | `metrics/+/system/cpu` |
| Memory Transformer | `glances/+/mem/percent` | `metrics/+/system/memory` |
| Uptime Transformer | `glances/+/uptime` | `metrics/+/system/uptime` |
| CPU Alert Monitor | `metrics/+/system/cpu` | `alerts/cpu/+` |
| Memory Alert Monitor | `metrics/+/system/memory` | `alerts/memory/+` |

### Routes (1 total)

| Route | Purpose |
|-------|---------|
| TimescaleDB | Stores metrics and alerts, runs scheduled aggregations |

---

## Expected MQTT Topics

Once deployed, you'll see data flowing through these topics:

```
glances/
  └── {hostname}/
        ├── cpu/total          # Raw CPU percentage
        ├── mem/percent        # Raw memory percentage
        └── uptime             # Raw uptime string

metrics/
  └── {hostname}/
        └── system/
              ├── cpu          # Transformed CPU metric
              ├── memory       # Transformed memory metric
              └── uptime       # Transformed uptime metric

alerts/
  ├── cpu/{hostname}           # CPU threshold violations
  └── memory/{hostname}        # Memory threshold violations

metrics/aggregates/
  └── system                   # Scheduled aggregation results
```

---

## Alert Thresholds

The default thresholds configured in the notebook:

| Metric | WARNING | CRITICAL |
|--------|---------|----------|
| CPU | > 25% | > 50% |
| Memory | > 25% | > 50% |

These are intentionally low for demo purposes - you'll want to adjust them for real-world use.

---

## Troubleshooting

**Notebook won't connect to CoreFlux Hub**
- Verify CoreFlux Hub is running
- Check the connection settings in the notebook application

**No data in transformed topics**
- Verify Glances is publishing: subscribe to `glances/#` in MQTT Explorer
- Ensure the Actions are deployed, not just defined

**Alerts not appearing**
- Check that metrics are flowing to `metrics/+/system/cpu`
- Verify threshold values (default 25%/50% may not trigger on idle systems)
- Use the stress test to force high CPU: `./stress-test/test.sh cpu`

---

## Status

> **Early Stage**: LOT is in active development.

This example was last tested on **2025-01-18**. Syntax, features, and best practices may change as the language evolves.

---

## Next Steps

After completing this tutorial:

1. **Extend the models** - Add disk space or network metrics
2. **Customize alerts** - Adjust thresholds for your environment
3. **Build dashboards** - Create Grafana visualizations for your metrics
4. **Explore the main README** - Learn about production hardening

---

## Learn More

- **CoreFlux Documentation**: [https://docs.coreflux.org](https://docs.coreflux.org)
- **LOT Language Reference**: [https://docs.coreflux.org/LOT/](https://docs.coreflux.org/LOT/)
- **Official LOT Samples & Tutorials**: [https://github.com/CorefluxCommunity/LOT-Samples](https://github.com/CorefluxCommunity/LOT-Samples)
