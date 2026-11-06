FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Version = commit Git, injectée par le pipeline
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]