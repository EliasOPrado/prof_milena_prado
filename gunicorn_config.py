"""
Gunicorn configuration for Prof. Milena Prado project
"""
import os
import multiprocessing

# Socket binding
bind = "127.0.0.1:8002"

# Worker configuration
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Server mechanics
daemon = False
umask = 0o022
tmp_upload_dir = None

# Logging
accesslog = "/var/log/gunicorn/access.log"
errorlog = "/var/log/gunicorn/error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'prof_milena_prado'

# Environment variables
raw_env = [
    'DJANGO_SETTINGS_MODULE=pro_milena.settings',
]

# Reload on code change (development only)
# reload = True

# SSL (if using SSL, configure here)
# keyfile = "/etc/letsencrypt/live/yourdomain.com/privkey.pem"
# certfile = "/etc/letsencrypt/live/yourdomain.com/fullchain.pem"
