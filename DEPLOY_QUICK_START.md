# 🚀 Quick Start Deploy - Prof. Milena Prado

## 📌 Resumo executivo

Você tem 3 opções para fazer deploy:

### Opção 1: Script Automático (Recomendado)
```bash
sudo bash /root/software_projects/prof_milena_prado/deploy.sh
```

### Opção 2: Passo a Passo Manual
Siga o arquivo `DEPLOYMENT.md`

### Opção 3: Docker (Futuro)
Não implementado ainda

---

## ⚡ Quick Start em 5 minutos

### 1. Clone o projeto
```bash
cd /root/software_projects
git clone seu_repo prof_milena_prado
cd prof_milena_prado
```

### 2. Configure o banco de dados
```bash
# Editar .env com suas credenciais PostgreSQL
nano .env
```

### 3. Execute o script de deploy
```bash
sudo bash deploy.sh
```

### 4. Configure SSL
```bash
sudo certbot certonly --webroot -w /var/www/certbot \
  -d seu_dominio.com -d www.seu_dominio.com

# Editar nginx.conf com as paths do certificado
sudo nano /etc/nginx/sites-available/prof_milena

# Recarregar
sudo nginx -t && sudo systemctl reload nginx
```

### 5. Acesse
```
https://seu_dominio.com
```

---

## 🔍 Verificar que está funcionando

```bash
# Ver status do Gunicorn
sudo systemctl status prof_milena.service

# Ver status do Nginx
sudo systemctl status nginx

# Ver logs
sudo journalctl -u prof_milena.service -f
sudo tail -f /var/log/nginx/prof_milena_error.log

# Testar conectividade
curl -I https://seu_dominio.com
```

---

## 📋 Arquivos criados

- ✅ `gunicorn_config.py` - Configuração do Gunicorn
- ✅ `nginx.conf` - Configuração do Nginx (EDITAR COM SEU DOMÍNIO!)
- ✅ `prof_milena.service` - Serviço systemd
- ✅ `deploy.sh` - Script automático de deployment
- ✅ `DEPLOYMENT.md` - Guia completo
- ✅ `settings.py` - Atualizado para produção
- ✅ `requirements.txt` - Adicionado Gunicorn

---

## ⚠️ IMPORTANTE - Antes de rodar deploy.sh

1. **Editar nginx.conf**
   - Procure por `seu_dominio.com` e substitua pelo seu domínio real
   - Procure por `/root/software_projects/prof_milena_prado` - se o caminho for diferente, atualize

2. **Garantir PostgreSQL funcionando**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl status postgresql
   ```

3. **Criar banco de dados**
   ```bash
   sudo -u postgres psql
   CREATE DATABASE seu_banco_db;
   CREATE USER seu_usuario WITH PASSWORD 'sua_senha';
   GRANT ALL PRIVILEGES ON DATABASE seu_banco_db TO seu_usuario;
   ```

4. **Testar venv e imports**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   python manage.py check
   ```

---

## 🆘 Se algo der errado

1. **Logs do Gunicorn**
   ```bash
   sudo journalctl -u prof_milena.service -n 50 -e
   ```

2. **Logs do Nginx**
   ```bash
   sudo tail -f /var/log/nginx/prof_milena_error.log
   ```

3. **Testar conexão com BD**
   ```bash
   source venv/bin/activate
   python manage.py dbshell
   ```

4. **Testar Gunicorn manualmente**
   ```bash
   cd /root/software_projects/prof_milena_prado
   source venv/bin/activate
   gunicorn --bind 127.0.0.1:8000 pro_milena.wsgi:application
   ```

---

## 📞 Documentação

- Completo: `DEPLOYMENT.md`
- Gunicorn: https://docs.gunicorn.org/
- Django Deploy: https://docs.djangoproject.com/en/5.2/howto/deployment/
- Nginx: https://nginx.org/en/docs/
