# Use lightweight Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt .

# Upgrade pip and install dependencies system-wide
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the entire application
COPY . .

# Expose Flask/Gunicorn port
EXPOSE 5000

# Run the app with Gunicorn as a production server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "3", "app:app"]

