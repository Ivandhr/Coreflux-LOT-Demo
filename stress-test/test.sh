#!/bin/bash
# Cross-platform stress testing script for triggering CoreFlux alerts
# Works on Linux and Windows (via Git Bash)

set -e

# Colors for output (works in Git Bash too)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Container name
CONTAINER_NAME="coreflux-stress-test"

# Detect network name (handles both "coreflux-network" and "coreflux_coreflux-network")
NETWORK_NAME=$(docker network ls --format '{{.Name}}' | grep -E '(^coreflux-network$|coreflux_coreflux-network)' | head -1)

if [ -z "$NETWORK_NAME" ]; then
    echo -e "${RED}Error: CoreFlux network not found. Is docker-compose running?${NC}"
    exit 1
fi

# Help function
show_help() {
    echo "Usage: ./stress-test.sh [OPTION]"
    echo ""
    echo "Stress test CPU/RAM to trigger CoreFlux alerts"
    echo ""
    echo "Options:"
    echo "  cpu              Stress CPU to ~80% (triggers CRITICAL alert at >50%)"
    echo "  memory           Stress RAM to ~60% (triggers CRITICAL alert at >50%)"
    echo "  both             Stress both CPU and RAM"
    echo "  stop             Stop any running stress test"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./stress-test.sh cpu"
    echo "  ./stress-test.sh memory"
    echo "  ./stress-test.sh both"
    echo "  ./stress-test.sh stop"
}

# Stop function
stop_stress() {
    echo -e "${YELLOW}Stopping stress test...${NC}"
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || echo "No stress test running"
    echo -e "${GREEN}Stress test stopped${NC}"
}

# CPU stress function
stress_cpu() {
    # Detect number of CPUs and calculate workers needed for ~60% load
    NUM_CPUS=$(docker run --rm alpine nproc 2>/dev/null || echo "4")
    CPU_WORKERS=$((NUM_CPUS * 60 / 100))

    echo -e "${GREEN}Starting CPU stress test...${NC}"
    echo -e "${YELLOW}Detected ${NUM_CPUS} CPUs, using ${CPU_WORKERS} workers for ~60% load${NC}"
    echo -e "${YELLOW}Expected: CPU CRITICAL alert (threshold: >50%)${NC}"
    echo ""

    docker run -d --rm \
        --name ${CONTAINER_NAME} \
        --network ${NETWORK_NAME} \
        polinux/stress \
        stress --cpu ${CPU_WORKERS} --timeout 15s

    echo -e "${GREEN}✓ CPU stress test running with ${CPU_WORKERS} workers${NC}"
    echo "Monitor alerts: Check MQTT Explorer at http://localhost:4000"
    echo "Or subscribe to: alerts/#"
    echo ""
    echo "Test will auto-stop in 15 seconds"
    echo "To stop manually: ./stress-test.sh stop"
}

# Memory stress function
stress_memory() {
    echo -e "${GREEN}Starting Memory stress test...${NC}"
    echo -e "${YELLOW}This will allocate 30GB RAM (~60% of Docker limit), hold for 15 seconds${NC}"
    echo -e "${YELLOW}Expected: Memory CRITICAL alert (threshold: >50%)${NC}"
    echo ""

    # Allocate 30GB of memory with 2 workers for better stability
    docker run -d --rm \
        --name ${CONTAINER_NAME} \
        --network ${NETWORK_NAME} \
        polinux/stress \
        stress --vm 2 --vm-bytes 32G --vm-keep --timeout 15s

    echo -e "${GREEN}✓ Memory stress test running (2 workers × 15GB = 30GB)${NC}"
    echo "Monitor alerts: Check MQTT Explorer at http://localhost:4000"
    echo "Or subscribe to: alerts/#"
    echo ""
    echo "Test will auto-stop in 15 seconds"
    echo "To stop manually: ./stress-test.sh stop"
}

# Both stress function
stress_both() {
    # Detect number of CPUs and calculate workers needed for ~60% load
    NUM_CPUS=$(docker run --rm alpine nproc 2>/dev/null || echo "4")
    CPU_WORKERS=$((NUM_CPUS * 60 / 100))

    echo -e "${GREEN}Starting CPU + Memory stress test...${NC}"
    echo -e "${YELLOW}Detected ${NUM_CPUS} CPUs, using ${CPU_WORKERS} workers for ~60% CPU load${NC}"
    echo -e "${YELLOW}This will ramp both CPU and RAM to ~60%, hold for 15 seconds${NC}"
    echo -e "${YELLOW}Expected: Both CPU and Memory CRITICAL alerts${NC}"
    echo ""

    docker run -d --rm \
        --name ${CONTAINER_NAME} \
        --network ${NETWORK_NAME} \
        polinux/stress \
        stress --cpu ${CPU_WORKERS} --vm 2 --vm-bytes 32G --vm-keep --timeout 15s

    echo -e "${GREEN}✓ CPU + Memory stress test running${NC}"
    echo "Monitor alerts: Check MQTT Explorer at http://localhost:4000"
    echo "Or subscribe to: alerts/#"
    echo ""
    echo "Test will auto-stop in 15 seconds"
    echo "To stop manually: ./stress-test.sh stop"
}

# Main script logic
case "${1:-help}" in
    cpu)
        stress_cpu
        ;;
    memory)
        stress_memory
        ;;
    both)
        stress_both
        ;;
    stop)
        stop_stress
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown option '${1}'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
