**Stage 1: Build the Go App**

*FROM golang:1.21 AS builder*

*WORKDIR /app*

*COPY . .*

*RUN go mod tidy* 

*RUN CGO\_ENABLED=0 GOOS=linux go build -v -o go-app*

**Explanation:**

- **Base Image**: Uses golang:1.21 for the Go development environment.
- **Dependency Management**: Downloads and cleans dependencies using go mod tidy.
- **Static Build**: Compiles the application into a statically linked binary for portability.
-----
**Stage 2: Add CA Certificates**

*FROM alpine:latest as ca-certificates*

*RUN apk --update add ca-certificates*

**Explanation:**

- **CA Certificates Installation**: Installs certificates using apk, enabling secure HTTPS communication.
-----
**Stage 3: Execute the Go App**

*FROM scratch*

*COPY --from=ca-certificates /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt*

*WORKDIR /app*

*COPY --from=builder /app/data/ipfs\_cids.csv ./data/ipfs\_cids.csv*

*COPY --from=builder /app/go-app ./*

*EXPOSE 8080*

*CMD [ "./go-app" ]*

**Explanation:**

- **Minimal Base Image**: Uses scratch for a lightweight, secure runtime environment.
- **Includes CA Certificates**: Copies certificates for secure HTTPS communication.
- **Application Files**:
  - ipfs\_cids.csv is copied for runtime use.
  - go-app is the main application binary.
- **Expose and Run**:
  - Exposes port 8080.
  - Executes the application using CMD.
-----
**Advantages of This Dockerfile**

- **Multi-Stage Build**: Reduces the image size by separating build and runtime stages.
- **Security**: Using scratch minimizes attack surfaces by eliminating unnecessary libraries.
- **Performance**: Produces a lightweight and portable container image for deployment.

