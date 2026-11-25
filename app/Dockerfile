FROM python:3.12-slim

WORKDIR /app

# Pin installs so a later build matches this one.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Flask listens on 5000. Terraform does not publish this port on the host.
EXPOSE 5000

CMD ["python", "app.py"]
