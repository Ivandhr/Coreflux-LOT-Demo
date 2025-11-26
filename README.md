# CoreFlux LOT Evaluation Demo

> **An interactive, educational demo showcasing CoreFlux Language of Things (LOT) for real-time IoT data orchestration**

This repository contains a complete, working example of a **system monitoring platform** built with CoreFlux LOT. It's designed for awareness, education, and hands-on evaluation - not production use.

---

## What is This?

This is a **learning-first demo** that shows how CoreFlux LOT transforms raw IoT sensor data into actionable intelligence using event-driven orchestration.

**Think of it like a live, working textbook**: You'll see real MQTT messages flowing through LOT transformations, alerts firing based on thresholds, and time-series data landing in a database - all defined in declarative LOT code that you can read, modify, and learn from.

### What You'll Learn

By working through this demo, you'll gain hands-on experience with:

| Concept | What You'll Do |
|---------|---------------|
| **Data Modeling** | Create type-safe schemas for IoT telemetry |
| **Event Processing** | Transform raw MQTT messages into structured metrics in real-time |
| **Business Logic** | Implement intelligent alerting with multi-level thresholds |
| **Database Integration** | Persist time-series data and run scheduled analytics |
| **Real-World Architecture** | See a complete MQTT to Transform to Database pipeline in action |

---

## Architecture Overview

The data flows through a simple but powerful pipeline:

```
                    +---------------------------+
                    |   Glances System Monitor  |
                    |   (Collects CPU, RAM, etc)|
                    +-------------+-------------+
                                  |
                                  | publishes raw metrics
                                  v
                    +---------------------------+
                    |       MQTT Broker         |
                    |  topic: glances/+/cpu/... |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    |   LOT Actions             |
                    |   (Transform & Enrich)    |
                    +-------------+-------------+
                                  |
                                  | publishes: metrics/+/system/cpu
                                  |
              +-------------------+-------------------+
              |                                       |
              v                                       v
+---------------------------+           +---------------------------+
|   LOT Alert Actions       |           |   TimescaleDB Route       |
|   (Threshold Monitoring)  |           |   (Metric Storage)        |
+-------------+-------------+           +-------------+-------------+
              |                                       |
              | publishes: alerts/cpu/+               | scheduled queries
              v                                       | every 1 minute
+---------------------------+                         v
|   TimescaleDB             |           +---------------------------+
|   (Alert Storage)         |           |   Aggregated Results      |
+---------------------------+           |   metrics/aggregates/...  |
                                        +---------------------------+
```

**In plain English**: Glances monitors your system and publishes raw data to MQTT. LOT Actions transform that data into clean metrics, check thresholds to fire alerts, and store everything in TimescaleDB for analysis.

---

## What's Inside

This project is organized into three main areas:

### `/demo/glances.lotnb` - Start Here

**The star of the show**: A comprehensive LOT Notebook that teaches you LOT while building a real system.

What's inside:
- **5 data models** - Base, numeric, string, time, and alert schemas
- **3 metric transformers** - CPU, memory, and uptime processors
- **2 intelligent alert monitors** - Threshold-based alerting with WARNING and CRITICAL levels
- **1 database route** - Persistence with real-time aggregation
- **Extensive inline tutorials** - Every concept explained as you go

> **Recommended**: Open this notebook first. It's designed to be read top-to-bottom like a tutorial.

### `/config` - Infrastructure Setup

Supporting configuration files for the demo environment:

| File | Purpose |
|------|---------|
| **Glances config** | System monitoring tool that publishes to MQTT |
| **TimescaleDB schema** | PostgreSQL tables for time-series storage |
| **Grafana dashboards** | Pre-configured visualizations (optional) |

### `/stress-test` - Alert Testing Tools

Want to see alerts fire? These scripts create real CPU/memory load to trigger your thresholds:

```bash
./stress-test/test.sh cpu     # Spike CPU to ~60% for 60 seconds
./stress-test/test.sh memory  # Spike RAM to ~60% for 60 seconds
```

Open MQTT Explorer at `http://localhost:4000` and watch alerts appear in real-time.

---

## Quick Start

Get up and running in about 10 minutes.

### Prerequisites

Before you begin, make sure you have:

- **Docker & Docker Compose** - [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) if you haven't already
- **CoreFlux Hub** - The LOT runtime environment ([installation guide](https://docs.coreflux.org))
- **10 minutes** - Enough time to start services and explore the notebook

> **Important - Default Credentials**: CoreFlux Hub ships with default credentials: username `root`, password `coreflux`. **Change these immediately after installation** for any non-demo environment.

### Step 1: Start the Infrastructure

Open a terminal in the project directory and run:

```bash
# Start all services (Glances, TimescaleDB, MQTT Explorer, Grafana, pgAdmin)
docker-compose up -d

# Verify everything is running (you should see 5 services)
docker-compose ps
```

> **Windows users**: Use PowerShell, Command Prompt, or Git Bash. All work fine with Docker.

### Step 2: Open the LOT Notebook

1. Launch the CoreFlux LOT Notebook application
2. Open `demo/glances.lotnb`
3. Read through the tutorial cells - they explain each concept step-by-step
4. Deploy the LOT code to your CoreFlux Hub (instructions are included in the file)

### Step 3: Watch the Magic Happen

With everything running, you can observe data flowing through the system:

**MQTT Explorer** - [http://localhost:4000](http://localhost:4000)
| Topic Pattern | What You'll See |
|--------------|-----------------|
| `glances/#` | Raw metrics from the system monitor |
| `metrics/#` | Transformed, structured data |
| `alerts/#` | Threshold violation alerts |

**Glances Web UI** - [http://localhost:61208](http://localhost:61208)
- View live system metrics directly from the source

**pgAdmin** - [http://localhost:5050](http://localhost:5050)
- Query stored metrics:
  ```sql
  SELECT * FROM metrics.numeric_timeseries ORDER BY event_time DESC LIMIT 100;
  ```
- View alert history:
  ```sql
  SELECT * FROM metrics.alerts ORDER BY event_time DESC;
  ```

**Grafana** - [http://localhost:3000](http://localhost:3000) *(login: admin / password)*
- Pre-configured dashboards for visualizing time-series data

### Step 4: Test Alerting (Optional)

Want to see alerts fire? Create some CPU load:

```bash
# Trigger a CPU alert by spiking CPU usage
./stress-test/test.sh cpu
```

Then open MQTT Explorer and watch for alerts appearing on:
- `alerts/cpu/{hostname}` with severity "CRITICAL"

---

## Service Reference

All services run locally via Docker. Here's how to access each one:

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| MQTT Explorer | http://localhost:4000 | none | Browse MQTT topics in real-time |
| Glances | http://localhost:61208 | none | View source system metrics |
| pgAdmin | http://localhost:5050 | admin@admin.com / admin | Query TimescaleDB |
| Grafana | http://localhost:3000 | admin / password | Visualize metrics dashboards |
| CoreFlux Broker | mqtt://localhost:1883 | none | MQTT broker (connect with any client) |
| TimescaleDB | localhost:5432 | postgres / timescale | Time-series database |

---

## Key LOT Concepts Demonstrated

This demo showcases the core features of the LOT language. Each concept builds on the previous one:

| Concept | LOT Syntax | What It Does |
|---------|-----------|--------------|
| **Models** | `DEFINE MODEL ...` | Type-safe data schemas with inheritance (`base` to `numericValue` to `Alert`) |
| **Actions** | `ON TOPIC ... DO` | Event handlers that react to MQTT messages |
| **Topic Pattern Matching** | `glances/+/cpu/total` | Wildcards (`+`, `#`) for flexible subscriptions |
| **Data Transformation** | `PUBLISH MODEL ... TO` | Parse, enrich, and republish data to new topics |
| **Conditional Logic** | `IF ... ELSE IF` | Multi-level threshold monitoring |
| **Routes** | `DEFINE ROUTE ...` | External system connectors (like PostgreSQL) |
| **Scheduled Queries** | `WITH EVERY 1 MINUTE` | Periodic database operations |

> **Want to dive deeper?** The `demo/glances.lotnb` notebook explains each concept with working examples.

---

## Project Status

> **DEMO / EDUCATIONAL USE ONLY**

This is an evaluation demo, not production-ready code. It's designed to:

- Showcase CoreFlux LOT capabilities
- Provide hands-on learning materials
- Offer a starting point for your own projects

### Known Limitations

This demo intentionally keeps things simple. In a production environment, you would address:

| Limitation | Production Solution |
|------------|---------------------|
| Hardcoded credentials | Use environment variables or secrets management |
| No SSL/TLS for database | Enable encrypted connections |
| Minimal error handling | Add comprehensive try/catch and logging |
| No data retention policies | Implement TimescaleDB retention policies |
| Basic alert deduplication | Add proper alert state management |

### LOT Language Status

CoreFlux LOT is in active development. These examples were last tested on **2025-01-18**. Syntax and features may evolve as the language matures.

---

## Troubleshooting

Having issues? Here are solutions to common problems:

### Services won't start

**Symptoms**: `docker-compose up` fails or containers keep restarting.

**Solution**: Clean up and start fresh:
```bash
docker-compose down -v  # Remove containers and volumes
docker-compose up -d    # Fresh start
```

### No metrics appearing in MQTT Explorer

**Symptoms**: You've subscribed to `glances/#` but see nothing.

**Checklist**:
1. Check Glances is running:
   ```bash
   docker logs coreflux-glances
   ```
2. Verify MQTT connection in CoreFlux Hub settings
3. Make sure the LOT code is deployed (not just open in the notebook)

### Alerts not firing

**Symptoms**: CPU is high but no alerts appear on `alerts/#`.

**Checklist**:
1. Verify the stress test is actually running:
   ```bash
   docker ps | grep stress
   ```
2. Check threshold values in `demo/glances.lotnb`:
   - WARNING: >25%
   - CRITICAL: >50%
3. Ensure the alert Actions are deployed to CoreFlux Hub

### Can't access services on Windows

**Symptoms**: `localhost:4000` won't load, or bash scripts fail.

**Solutions**:
- Ensure Docker Desktop is running with WSL2 backend
- For bash scripts, use Git Bash (not PowerShell or CMD):
  - Right-click in the folder and select "Git Bash Here"
- If ports are blocked, check Windows Firewall settings

### Container already exists error

**Symptoms**: `docker-compose up` complains about existing containers.

**Solution**:
```bash
docker-compose down
docker-compose up -d
```

---

## Next Steps

Once you've explored the demo, here are some paths forward:

### Extend This Demo

Try adding new features to deepen your understanding:

- **Add disk monitoring** - Subscribe to `glances/+/fs/percent` and create disk space alerts
- **Monitor network throughput** - Track bytes sent/received with trend analysis
- **Build custom dashboards** - Create Grafana visualizations for your specific needs
- **Add notifications** - Integrate Slack, email, or SMS alerts for critical events
- **Experiment with ML** - Build predictive alerting that warns before thresholds are breached

### Prepare for Production

When you're ready to move beyond the demo, address these areas:

| Area | Action Items |
|------|-------------|
| **Security** | Move credentials to environment variables; enable SSL/TLS everywhere |
| **Authentication** | Add MQTT broker authentication; secure database access |
| **Reliability** | Implement alert deduplication; add health checks and dead letter queues |
| **Operations** | Set up data retention policies; add monitoring for the monitoring system |

### Learn More

- **CoreFlux Documentation**: [https://docs.coreflux.org](https://docs.coreflux.org)
- **LOT Language Reference**: [https://docs.coreflux.org/LOT/](https://docs.coreflux.org/LOT/)
- **Official LOT Samples & Tutorials**: [https://github.com/CorefluxCommunity/LOT-Samples](https://github.com/CorefluxCommunity/LOT-Samples)
- **TimescaleDB Best Practices**: Time-series optimization techniques
- **MQTT Topic Design**: Patterns for scalable IoT architectures

---

## Contributing

This is an educational demo - we welcome your input:

- **Fork and experiment** - Make it your own
- **Share improvements** - Found a better way? Let us know
- **Report issues** - If examples don't work, please tell us
- **Suggest scenarios** - What other demos would help you learn?

---

## License

This project is licensed under the [MIT License](LICENSE) - use it however you like.

For production use of CoreFlux Hub itself, check [CoreFlux licensing](https://coreflux.org).

---

**Ready to explore?** Open `demo/glances.lotnb` and start learning LOT! 🚀
