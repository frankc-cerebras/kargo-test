#!/usr/bin/env bash

set -euo pipefail

STAGE=$1

if [[ -z "$STAGE" ]]; then
    echo "Usage: $0 <stage>"
    echo "Example: $0 dev"
    exit 1
fi

if [[ "$STAGE" != "dev" && "$STAGE" != "test" && "$STAGE" != "prod_dc1" && "$STAGE" != "prod_dc2" ]]; then
    echo "Error: Stage must be one of: dev, test, prod_dc1, prod_dc2"
    exit 1
fi

# Ensure the destination directory exists
DEST_DIR="k8s/rendered/$STAGE"
mkdir -p "$DEST_DIR"

echo "Rendering k8s/overlays/$STAGE into $DEST_DIR/manifest.yaml..."

# Run kustomize build and save the output
kustomize build "k8s/overlays/$STAGE" > "$DEST_DIR/manifest.yaml"

echo "Done!"
