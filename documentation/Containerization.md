Dockerfile Breakdown
Stage 1: Build the Go App
dockerfile
Copy code
FROM golang:1.21 AS builder

WORKDIR /app
COPY . .
RUN go mod tidy 
RUN CGO_ENABLED=0 GOOS=linux go build -v -o go-app
Explanation:
Base Image: Uses golang:1.21 for the Go development environment.
Dependency Management: Downloads and cleans dependencies using go mod tidy.
Static Build: Compiles the application into a statically linked binary for portability.
Stage 2: Add CA Certificates
dockerfile
Copy code
FROM alpine:latest as ca-certificates
RUN apk --update add ca-certificates
Explanation:
Installs CA certificates using apk, enabling secure HTTPS communication.
Stage 3: Execute the Go App
dockerfile
Copy code
FROM scratch
COPY --from=ca-certificates /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
WORKDIR /app
COPY --from=builder /app/data/ipfs_cids.csv ./data/ipfs_cids.csv
COPY --from=builder /app/go-app ./
EXPOSE 8080
CMD [ "./go-app" ]
Explanation:
Minimal Base Image: Uses scratch for a lightweight, secure runtime environment.
Includes CA Certificates: Copies certificates for secure HTTPS communication.
Application Files:
ipfs_cids.csv is copied for runtime use.
go-app is the main application binary.
Expose and Run:
Exposes port 8080.
Executes the application using CMD.
Advantages of This Dockerfile
Multi-Stage Build: Reduces the image size by separating build and runtime stages.
Security: Using scratch minimizes attack surfaces by eliminating unnecessary libraries.
Performance: Produces a lightweight and portable container image for deployment.