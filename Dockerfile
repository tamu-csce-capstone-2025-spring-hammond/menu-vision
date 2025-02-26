# Use Python base image
FROM python:3.9

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY app /app

# Expose the port Flask runs on
EXPOSE 8080

# Command to run the application
CMD ["python", "app.py"]
