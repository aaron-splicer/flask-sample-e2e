FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Railway / Heroku / any PaaS injects PORT at runtime. EXPOSE here is informational;
# the actual listen port is read from $PORT at startup (defaults to 5000 for local docker run).
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://localhost:' + os.getenv('PORT', '5000') + '/').read()" || exit 1

# Shell form so ${PORT:-5000} expands. Without this, Flask listens on its 5000 default
# and Railway's edge can't reach the app (planning #1060).
CMD ["sh", "-c", "python -m flask run --host=0.0.0.0 --port=${PORT:-5000}"]
