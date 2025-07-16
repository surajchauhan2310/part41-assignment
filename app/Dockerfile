# Use a lightweight official Python image
FROM python:3.12-slim

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set working directory
WORKDIR /app

# Copy requirements first for layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the port your Flask app will run on
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
