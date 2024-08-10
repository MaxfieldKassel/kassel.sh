# Kassel.sh

Kassel.sh provides a convenient setup script for Linux and macOS environments, automating the installation of essential tools and configurations. The script can be hosted on a simple webserver using Docker Compose for easy access and download.

## Features

- Automates installation of common tools and configurations for both Linux and macOS. (No Windows support currently)
- Supports automatic mode for unattended installations.
- Provides a simple web server to download the script.

## Getting Started

### Setup environment
To download the scripts automatically and begin the install run the following command:
```
bash -c "$(curl -sSL kassel.sh)"
```

### Local Installation

Prerequisites:
- Docker
- Docker Compose


  
1. Clone the repository:

   git clone [https://github.com/MaxfieldKassel/kassel.sh.git](https://github.com/MaxfieldKassel/kassel.sh)
   cd kassel.sh

2. Start the Docker Compose service:

   docker-compose up -d --build

3. Access the script from your browser at `localhost:8080` or download it using `curl`:

   curl -O localhost:8080

### Usage

1. Download and run the script with a one-liner:

   ```bash
   bash -c "$(curl -sSL localhost:8080)"
   ```

2. For automatic mode, use the -a flag:

    ```bash
    bash -c "$(curl -sSL localhost:8080)" -a
    ```
