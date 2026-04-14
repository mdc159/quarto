#!/usr/bin/env bash
# ── Reproducible workspace setup ──────────────────────────────────────
# Usage:  bash setup.sh
#
# Creates (or recreates) the .venv, installs Python 3.12 and all
# dependencies declared in pyproject.toml, registers the Jupyter kernel,
# and verifies the stack.

set -euo pipefail
cd "$(dirname "$0")"

echo "=== Creating venv with uv ==="
uv venv --python 3.12 .venv

echo "=== Installing dependencies from pyproject.toml ==="
uv pip install --python .venv/Scripts/python.exe -e ".[dev]"

echo "=== Registering Jupyter kernel ==="
.venv/Scripts/python.exe -m ipykernel install --user --name quarto-workspace --display-name "Quarto Workspace (Python 3.12)"

echo "=== Verifying core imports ==="
.venv/Scripts/python.exe -c "
import CoolProp, ht, fluids, thermo, chemicals, iapws, pint, pyromat
import numpy, scipy, matplotlib, pandas
print('All imports OK')
print(f'  CoolProp {CoolProp.__version__}')
print(f'  numpy    {numpy.__version__}')
print(f'  scipy    {scipy.__version__}')
"

echo ""
echo "=== Setup complete ==="
echo "Set QUARTO_PYTHON before rendering:"
echo "  export QUARTO_PYTHON=$(pwd)/.venv/Scripts/python.exe"
