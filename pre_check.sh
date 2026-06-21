#!/bin/bash
# Pre-deployment check script for Prof. Milena Prado
# Run with: bash pre_check.sh

echo "========================================="
echo "Pre-Deployment Check"
echo "========================================="
echo ""

ERRORS=0
WARNINGS=0

check_pass() {
    echo "✓ $1"
}

check_fail() {
    echo "✗ $1"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo "⚠ $1"
    WARNINGS=$((WARNINGS + 1))
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   check_warn "Não está rodando como root (alguns checks podem falhar)"
fi

echo "📦 Verificando dependências do sistema..."
echo ""

# Check Python3
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    check_pass "Python3 instalado: $PYTHON_VERSION"
else
    check_fail "Python3 não está instalado"
fi

# Check pip
if command -v pip3 &> /dev/null; then
    check_pass "pip3 instalado"
else
    check_fail "pip3 não está instalado"
fi

# Check PostgreSQL
if command -v psql &> /dev/null; then
    PG_VERSION=$(psql --version)
    check_pass "PostgreSQL instalado: $PG_VERSION"
else
    check_fail "PostgreSQL client não está instalado"
fi

# Check if PostgreSQL service is running
if systemctl is-active --quiet postgresql; then
    check_pass "PostgreSQL rodando"
else
    check_warn "PostgreSQL não está rodando (será necessário iniciar)"
fi

# Check Nginx
if command -v nginx &> /dev/null; then
    check_pass "Nginx instalado"
else
    check_fail "Nginx não está instalado"
fi

# Check git
if command -v git &> /dev/null; then
    check_pass "Git instalado"
else
    check_fail "Git não está instalado"
fi

# Check certbot
if command -v certbot &> /dev/null; then
    check_pass "Certbot instalado (Let's Encrypt)"
else
    check_fail "Certbot não está instalado"
fi

echo ""
echo "📁 Verificando arquivos do projeto..."
echo ""

PROJECT_DIR="/root/software_projects/prof_milena_prado"

# Check if project directory exists
if [ -d "$PROJECT_DIR" ]; then
    check_pass "Diretório do projeto existe"
else
    check_fail "Diretório do projeto não encontrado em $PROJECT_DIR"
fi

# Check required files
FILES=(".env" "requirements.txt" "manage.py" "pro_milena/settings.py")
for file in "${FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        check_pass "Arquivo encontrado: $file"
    else
        check_fail "Arquivo não encontrado: $file"
    fi
done

# Check .env variables
if [ -f "$PROJECT_DIR/.env" ]; then
    echo ""
    echo "Variáveis do .env encontradas:"
    grep -v "^#" "$PROJECT_DIR/.env" | grep -v "^$" | sed 's/=.*/=***HIDDEN***/g' | sed 's/^/  /'
fi

echo ""
echo "🔧 Verificando configurações..."
echo ""

# Check virtual environment
if [ -d "$PROJECT_DIR/venv" ]; then
    check_pass "Virtual environment já existe"
else
    check_warn "Virtual environment não encontrado (será criado durante deploy)"
fi

# Check Django
if [ -d "$PROJECT_DIR/venv" ]; then
    if $PROJECT_DIR/venv/bin/python -c "import django" 2>/dev/null; then
        DJANGO_VERSION=$($PROJECT_DIR/venv/bin/python -c "import django; print(django.__version__)")
        check_pass "Django instalado no venv: $DJANGO_VERSION"
    else
        check_warn "Django não encontrado no venv (será instalado durante deploy)"
    fi
fi

echo ""
echo "🌐 Verificando conectividade..."
echo ""

# Try to connect to PostgreSQL
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
    if psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "postgres" -c "SELECT 1" >/dev/null 2>&1; then
        check_pass "Conexão com PostgreSQL OK"
    else
        check_warn "Não foi possível conectar ao PostgreSQL com as credenciais do .env"
    fi
fi

# Check ports
echo ""
echo "🔌 Verificando disponibilidade de portas..."
echo ""

if lsof -Pi :80 -sTCP:LISTEN >/dev/null 2>&1; then
    check_warn "Porta 80 já está em uso (Nginx/Apache rodando?)"
else
    check_pass "Porta 80 disponível"
fi

if lsof -Pi :443 -sTCP:LISTEN >/dev/null 2>&1; then
    check_warn "Porta 443 já está em uso"
else
    check_pass "Porta 443 disponível"
fi

if lsof -Pi :8000 -sTCP:LISTEN >/dev/null 2>&1; then
    check_warn "Porta 8000 já está em uso"
else
    check_pass "Porta 8000 disponível"
fi

echo ""
echo "========================================="
echo "Resumo da verificação:"
echo "========================================="
echo "Erros encontrados: $ERRORS"
echo "Avisos: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✓ Tudo pronto para deploy!"
else
    echo "⚠ Corrija os erros acima antes de fazer deploy"
fi
