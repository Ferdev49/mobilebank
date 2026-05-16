#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> node-exporter (DaemonSet)..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/node-exporter/"
echo "==> kube-state-metrics..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/kube-state-metrics/"
sleep 5
echo ""
kubectl -n observability get pods -l app=node-exporter
kubectl -n observability rollout status deployment/kube-state-metrics --timeout=120s
echo ""
echo "OK. Prometheus los descubrira por las anotaciones prometheus.io/scrape."
