FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
RUN apk add curl &&\
    curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar zxvf - -C . &&\
    mv qemu-3.0.0+resin-arm/qemu-arm-static .


FROM arm32v7/python:3-slim

# Add QEMU
COPY --from=builder qemu-arm-static /usr/bin

# Install requirements
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application sources
COPY src .

# Run the application
ENV FLASK_APP=app.py
CMD [ "flask", "run" ]
