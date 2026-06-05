# Prof. Milena Prado - Espaço Infantil

## Introdução

Este projeto é um site institucional e educativo para a Prof. Milena Prado, com foco em alfabetização, psicopedagogia e atividades infantis. A página apresenta uma experiência visual leve e acolhedora, com navegação interativa entre seções de apresentação, vídeos, projetos pedagógicos e uma área administrativa para gerenciar conteúdos.

## Objetivo do Site

O site foi criado para:

- comunicar a proposta pedagógica da Prof. Milena Prado
- apresentar conteúdos voltados à primeira infância
- exibir vídeos e desenhos selecionados para aprendizagem lúdica
- apoiar famílias e educadores com projetos autorais e relatórios avaliativos
- oferecer uma área administrativa protegida para gerenciamento de conteúdo

## Paleta de Cores

A identidade visual do projeto segue uma paleta suave, vibrante e infantil:

- `#FFFDF9` — fundo creme claro, gera sensação acolhedora
- `#FF6B6B` — rosa vivo, usado em títulos e CTAs
- `#FBBF24` / `#FFC700` — amarelo alegre, usado em destaques e bordas
- `#A78BFA` — roxo suave, usado em textos e destaques complementares
- `#374151` — cinza escuro, cor principal dos textos
- `#FDE68A` / `#FEF08A` — amarelo claro, usado em fundos e padrões

## Estrutura do Projeto

O projeto é construído com Django e conta com os seguintes caminhos principais:

- `manage.py` — comando de gerenciamento do Django
- `pro_milena/settings.py` — configurações do Django, database e static files
- `templates/index.html` — template principal do site
- `static/css/style.css` — estilos personalizados do projeto
- `static/js/app.js` — lógica de interação da interface
- `static/media/profe_milena.jpg` — imagem principal da professora
- `static/images/milena_site.png` — favicon do site
- `core/` — app Django principal com views, modelos e URLs

## Tecnologias Utilizadas

- **Python 3.14** — linguagem de programação do backend
- **Django 5.2** — framework web principal
- **PostgreSQL** — banco de dados relacional usado em produção
- **python-dotenv** — carregamento de variáveis de ambiente de `.env`
- **psycopg2-binary** — driver de conexão PostgreSQL para Python
- **Tailwind CSS (CDN)** — framework utilitário para estilos rápidos
- **Lucide Icons** — biblioteca de ícones utilizada no frontend
- **HTML5 / CSS3 / JavaScript** — base da interface do usuário

## Variáveis de Ambiente

O projeto usa um arquivo `.env` para armazenar configurações sensíveis. As variáveis esperadas são:

```env
POSTGRES_DB=your_database_name
POSTGRES_USER=your_database_user
POSTGRES_PASSWORD=your_database_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

> Se estiver usando PostgreSQL local, mantenha `POSTGRES_HOST=localhost`.

## Como Rodar o Projeto

### 1. Preparar o ambiente

No diretório do projeto:

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### 2. Configurar o `.env`

Crie o arquivo `.env` na raiz do projeto com as variáveis de ambiente acima e preencha os valores corretos.

### 3. Rodar migrações

```bash
python manage.py migrate
```

### 4. Executar o servidor

```bash
python manage.py runserver 8000
```

Em seguida, abra o navegador em `http://127.0.0.1:8000`.

## Dicas Adicionais

- Existe um script de setup opcional: `setup.sh`
- Caso utilize Docker ou servidor remoto, ajuste `POSTGRES_HOST` para o host correto do banco
- Para um ambiente de desenvolvimento local rápido, você pode alternar temporariamente para SQLite, mas a configuração atual usa PostgreSQL

## Considerações Finais

O site é planejado para ser acolhedor e funcional, com foco em uma comunicação clara sobre os serviços pedagógicos da Prof. Milena Prado. A experiência visual mistura cores suaves, ilustrações e uma navegação amigável para famílias e educadores.
