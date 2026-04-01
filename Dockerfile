# Build stage
FROM golang:1.26-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Set work directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -o svm ./cmd/svm/main.go

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Set work directory
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/svm .

# Expose the port
EXPOSE 8000

# Set environment variable for port
ENV PORT=8000

# Start the application
CMD ["./svm"]
