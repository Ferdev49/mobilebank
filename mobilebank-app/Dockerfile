FROM python:3.11-slim

# Crear usuario no-root (Week 5 - Day 25 PSS restricted)
RUN groupadd --gid 1000 app && \
    useradd  --uid 1000 --gid app --shell /bin/bash --create-home app

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Crear /app/data con permisos para el user 1000 (PVC se montara aqui)
RUN mkdir -p /app/data && chown -R app:app /app

USER 1000

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
