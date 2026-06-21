#!/bin/bash
# Deploy script for Prof. Milena Prado project
# Run with: bash deploy.sh

set -e  # Exit on any error

echo "========================================="
echo "Prof. Milena Prado - Deploy Script"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="/root/software_projects/prof_milena_prado"
VENV_DIR="$PROJECT_DIR/venv"

# Function to print colored messages
print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root ou com sudo"
   exit 1
fi

# Step 1: Pull latest code from repository
print_step "Atualizando código do repositório..."
cd $PROJECT_DIR
git pull origin main || print_warning "Git pull falhou - prosseguindo com código local"

# Step 2: Create/activate virtual environment
print_step "Preparando environment virtual..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
fi
source $VENV_DIR/bin/activate

# Step 3: Install/upgrade dependencies
print_step "Instalando dependências..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install gunicorn

# Step 4: Create necessary directories
print_step "Criando diretórios necessários..."
mkdir -p $PROJECT_DIR/staticfiles
mkdir -p $PROJECT_DIR/media
mkdir -p /var/log/gunicorn
mkdir -p /var/log/nginx

# Step 5: Collect static files
print_step "Coletando arquivos estáticos..."
python manage.py collectstatic --noinput --clear

# Step 6: Run migrations
print_step "Executando migrações do banco de dados..."
python manage.py migrate

# Step 7: Configure Nginx
print_step "Configurando Nginx..."
cp $PROJECT_DIR/nginx.conf /etc/nginx/sites-available/prof_milena
ln -sf /etc/nginx/sites-available/prof_milena /etc/nginx/sites-enabled/prof_milena
rm -f /etc/nginx/sites-enabled/default  # Remove default site if exists

# Validate Nginx configuration
if nginx -t; then
    print_step "Nginx recarregando..."
    systemctl reload nginx
else
    print_error "Nginx configuration inválida!"
    exit 1
fi

# Step 8: Setup Systemd service
print_step "Instalando serviço systemd..."
cp $PROJECT_DIR/prof_milena.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable prof_milena.service

# Step 9: Set permissions
print_step "Configurando permissões..."
chown -R www-data:www-data $PROJECT_DIR/media
chown -R www-data:www-data $PROJECT_DIR/staticfiles
chmod -R 755 $PROJECT_DIR/media
chmod -R 755 $PROJECT_DIR/staticfiles
chown -R www-data:www-data /var/log/gunicorn
chown -R www-data:www-data /var/log/nginx

# Step 10: Restart Gunicorn
print_step "Reiniciando Gunicorn..."
systemctl restart prof_milena.service

# Step 11: Check status
print_step "Verificando status dos serviços..."
echo ""
echo "Gunicorn status:"
systemctl status prof_milena.service --no-pager || print_warning "Gunicorn pode não estar rodando"

echo ""
echo "Nginx status:"
systemctl status nginx --no-pager || print_warning "Nginx pode não estar rodando"

echo ""
print_step "========================================="
print_step "Deploy concluído com sucesso! ✓"
print_step "========================================="
echo ""
echo "Próximos passos:"
echo "1. Configure seu domínio no Nginx (nginx.conf)"
echo "2. Configure SSL com Let's Encrypt:"
echo "   sudo certbot certonly --webroot -w /var/www/certbot -d seu_dominio.com"
echo "3. Atualize as paths no nginx.conf com o caminho correto do certificado"
echo "4. Teste com: curl https://seu_dominio.com"
echo ""
