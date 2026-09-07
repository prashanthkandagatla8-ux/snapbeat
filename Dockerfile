FROM python:3.11-slim

WORKDIR /app

# Install dependencies (only ~150MB, no heavy libraries or FFmpeg needed)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY gateway.py .

ENV PORT=8000
EXPOSE 8000

CMD ["python", "gateway.py"]
