# Use an official Go image as a base image
FROM golang:1.23.3-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the Go project files into the container
COPY . .

# Install dependencies (if needed)
RUN go mod tidy

# Expose port 8080 inside the container
EXPOSE 8080

# Run the Go application
CMD ["go", "run", "main.go"]