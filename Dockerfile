# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Copy the rest of your application code
COPY . .

# Expose the port Cloud Run will listen on
EXPOSE 8080

# Define the command to run your web server
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]