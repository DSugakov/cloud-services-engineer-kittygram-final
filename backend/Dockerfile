FROM python:3.9
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/bin:$PATH"

WORKDIR /app

COPY requirements.txt /app/

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

RUN gunicorn --version

COPY . /app/

CMD ["gunicorn", "--bind", "0.0.0.0:9000", "kittygram_backend.wsgi"]