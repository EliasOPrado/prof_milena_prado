# 🚀 Guia de Deployment - Prof. Milena Prado

## ✅ Pré-requisitos na VPS

Antes de começar, certifique-se de ter na sua VPS (Ubuntu/Debian):

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências básicas
sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y postgresql postgresql-contrib
sudo apt install -y nginx
sudo apt install -y git
sudo apt install -y certbot python3-certbot-nginx
sudo apt install -y build-essential python3-dev libpq-dev
```

---

## 📋 Checklist de Deployment

### Fase 1: Preparação (Local ou VPS)

- [ ] Clone do projeto para `/root/software_projects/prof_milena_prado`
- [ ] Arquivo `.env` com credenciais do banco PostgreSQL
- [ ] Virtual environment criado e requirements instalados
- [ ] Arquivo `settings.py` atualizado (já feito ✓)
- [ ] Arquivo `gunicorn_config.py` criado (já feito ✓)
- [ ] Arquivo `nginx.conf` criado (já feito ✓)
- [ ] Arquivo `prof_milena.service` criado (já feito ✓)

### Fase 2: Banco de Dados

- [ ] PostgreSQL instalado e rodando
- [ ] Banco de dados criado com nome correto
- [ ] Usuário PostgreSQL com permissões corretas
- [ ] Arquivo `.env` com credenciais corretas
- [ ] Conexão testada: `python manage.py shell` deve conectar ao BD

### Fase 3: Aplicação Django

- [ ] Migrações executadas: `python manage.py migrate`
- [ ] Static files coletados: `python manage.py collectstatic`
- [ ] Super usuário criado (admin): `python manage.py createsuperuser`
- [ ] Testado localmente com Gunicorn: `gunicorn pro_milena.wsgi:application`

### Fase 4: Nginx & SSL

- [ ] Nginx instalado e configurado
- [ ] Arquivo nginx.conf copiado e editado com seu domínio
- [ ] Certificado SSL gerado com Let's Encrypt
- [ ] HTTPS funcionando

### Fase 5: Systemd

- [ ] Serviço systemd criado
- [ ] Serviço habilitado e iniciado
- [ ] Logs verificados

---

## 🛠️ Passos de Execução

### **1. Conectar na VPS e clonar o projeto**

```bash
ssh root@seu_ip_vps

# Criar diretório e clonar projeto
mkdir -p /root/software_projects
cd /root/software_projects
git clone seu_repositorio.git prof_milena_prado
cd prof_milena_prado
```

### **2. Configurar variáveis de ambiente**

```bash
# Criar arquivo .env com suas credenciais PostgreSQL
nano .env
```

Exemplo de `.env`:
```dotenv
POSTGRES_DB=seu_banco_db
POSTGRES_USER=seu_usuario
POSTGRES_PASSWORD=sua_senha_forte
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DEBUG=False
ALLOWED_HOSTS=seu_dominio.com,www.seu_dominio.com
SECRET_KEY=gere_uma_chave_segura_aqui
```

Para gerar uma SECRET_KEY segura:
```python
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### **3. Criar virtual environment e instalar dependências**

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn
pip install psycopg2-binary
```

### **4. Configurar PostgreSQL**

```bash
sudo -u postgres psql
```

Inside PostgreSQL:
```sql
CREATE DATABASE seu_banco_db;
CREATE USER seu_usuario WITH PASSWORD 'sua_senha_forte';
ALTER ROLE seu_usuario SET client_encoding TO 'utf8';
ALTER ROLE seu_usuario SET default_transaction_isolation TO 'read committed';
ALTER ROLE seu_usuario SET default_transaction_deferrable TO on;
ALTER ROLE seu_usuario SET default_transaction_level TO 'read committed';
GRANT ALL PRIVILEGES ON DATABASE seu_banco_db TO seu_usuario;
\q
```

### **5. Executar migrações e coletar static files**

```bash
cd /root/software_projects/prof_milena_prado
source venv/bin/activate

python manage.py migrate
python manage.py collectstatic --noinput
python manage.py createsuperuser
```

### **6. Testar com Gunicorn localmente**

```bash
gunicorn --config gunicorn_config.py pro_milena.wsgi:application
```

Teste em outro terminal:
```bash
curl http://127.0.0.1:8000
```

### **7. Configurar Nginx**

```bash
# Editar nginx.conf com seu domínio
nano /root/software_projects/prof_milena_prado/nginx.conf

# Copiar para sites-available
sudo cp /root/software_projects/prof_milena_prado/nginx.conf /etc/nginx/sites-available/prof_milena

# Criar symlink
sudo ln -s /etc/nginx/sites-available/prof_milena /etc/nginx/sites-enabled/prof_milena

# Remover site default se existir
sudo rm /etc/nginx/sites-enabled/default

# Validar configuração
sudo nginx -t

# Recarregar Nginx
sudo systemctl reload nginx
```

### **8. Configurar SSL com Let's Encrypt**

```bash
# Criar diretório para validação
sudo mkdir -p /var/www/certbot

# Gerar certificado
sudo certbot certonly --webroot -w /var/www/certbot \
  -d seu_dominio.com \
  -d www.seu_dominio.com

# Atualizar nginx.conf com paths do certificado
# ssl_certificate: /etc/letsencrypt/live/seu_dominio.com/fullchain.pem
# ssl_certificate_key: /etc/letsencrypt/live/seu_dominio.com/privkey.pem

sudo nano /etc/nginx/sites-available/prof_milena

# Validar e recarregar
sudo nginx -t
sudo systemctl reload nginx
```

### **9. Configurar Systemd**

```bash
# Copiar arquivo de serviço
sudo cp /root/software_projects/prof_milena_prado/prof_milena.service /etc/systemd/system/

# Recarregar daemon do systemd
sudo systemctl daemon-reload

# Habilitar serviço
sudo systemctl enable prof_milena.service

# Iniciar serviço
sudo systemctl start prof_milena.service

# Verificar status
sudo systemctl status prof_milena.service
```

### **10. Ajustar permissões**

```bash
sudo chown -R www-data:www-data /root/software_projects/prof_milena_prado/media
sudo chown -R www-data:www-data /root/software_projects/prof_milena_prado/staticfiles
sudo chown -R www-data:www-data /var/log/gunicorn
sudo chown -R www-data:www-data /var/log/nginx

chmod -R 755 /root/software_projects/prof_milena_prado/media
chmod -R 755 /root/software_projects/prof_milena_prado/staticfiles
```

### **11. Usar o script de deploy automático (OPCIONAL)**

Se preferir automatizar tudo:

```bash
sudo bash /root/software_projects/prof_milena_prado/deploy.sh
```

---

## 🔍 Verificação e Troubleshooting

### Ver logs do Gunicorn
```bash
sudo journalctl -u prof_milena.service -f
```

### Ver logs do Nginx
```bash
sudo tail -f /var/log/nginx/prof_milena_error.log
sudo tail -f /var/log/nginx/prof_milena_access.log
```

### Verificar conexão com banco de dados
```bash
cd /root/software_projects/prof_milena_prado
source venv/bin/activate
python manage.py shell
>>> from django.db import connection
>>> connection.ensure_connection()  # Se passar, BD está ok
```

### Reiniciar serviços
```bash
sudo systemctl restart prof_milena.service
sudo systemctl restart nginx
```

### Verificar se portas estão abertas
```bash
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :8000
```

---

## 🚀 Acessar a aplicação

Depois que tudo estiver configurado:

- **Site público**: https://seu_dominio.com
- **Admin panel**: https://seu_dominio.com/admin
- **Debug**: Se `DEBUG=False`, erros retornarão 500 (normal em produção)

---

## 📝 Notas de Segurança

1. **SECRET_KEY**: Nunca compartilhe seu SECRET_KEY. Já foi gerado e está no `.env`
2. **DEBUG=False**: Essencial em produção
3. **HTTPS obrigatório**: Seu nginx redireciona HTTP → HTTPS
4. **Backups**: Configure backups regulares do banco PostgreSQL
5. **Firewall**: Recomendado bloquear portas desnecessárias (ufw)

---

## 🔄 Atualizações futuras

Para atualizar o código:

```bash
cd /root/software_projects/prof_milena_prado
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart prof_milena.service
```

---

## 📞 Contato e suporte

Documentação Django: https://docs.djangoproject.com/en/5.2/howto/deployment/
Documentação Nginx: https://nginx.org/en/docs/
Documentação Gunicorn: https://docs.gunicorn.org/
