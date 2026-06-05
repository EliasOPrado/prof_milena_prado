#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "== Projeto: $SCRIPT_DIR =="

if [ ! -f "requirements.txt" ]; then
  echo "ERROR: requirements.txt não encontrado no diretório do projeto."
  exit 1
fi

PYTHON_CMD=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD=python
else
  echo "ERROR: python3 não encontrado. Instale Python 3 antes de continuar."
  exit 1
fi

if [ ! -d "venv" ]; then
  echo "Criando virtualenv em ./venv..."
  "$PYTHON_CMD" -m venv venv
else
  echo "Virtualenv já existe em ./venv"
fi

# shellcheck source=/dev/null
source venv/bin/activate

python -m pip install --upgrade pip setuptools wheel
python -m pip install -r requirements.txt

env_file="$SCRIPT_DIR/.env"
if [ ! -f "$env_file" ]; then
  echo "Criando .env com variáveis placeholder..."
  cat > "$env_file" <<'EOF'
POSTGRES_DB=your_database_name
POSTGRES_USER=your_database_user
POSTGRES_PASSWORD=your_database_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
EOF
  echo ".env criado. Edite o arquivo e informe os valores reais antes de rodar o projeto."
else
  echo ".env já existe; não será sobrescrito."
fi

echo "\nSetup concluído."
echo "Use: source venv/bin/activate"
echo "Depois, edite .env com os valores corretos e execute seus comandos Django."