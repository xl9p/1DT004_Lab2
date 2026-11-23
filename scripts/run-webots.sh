#!/usr/bin/env bash
set -e

WORLD="${1:-/workspace/e-puck/worlds/e-puck_line.wbt}"

exec webots "$WORLD"