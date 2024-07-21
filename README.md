# Kassel.sh

Kassel.sh provides a convenient setup script for Linux and macOS environments, automating the installation of essential tools and configurations. Host the script on a simple webserver using Docker Compose for easy access and download.

## Features

- Automates installation of common tools and configurations for both Linux and macOS.
- Supports automatic mode for unattended installations.
- Provides a simple webserver to download the script.

## Getting Started

### Prerequisites

- Docker
- Docker Compose

### Installation

1. Clone the repository:

   git clone https://github.com/yourusername/kassel.sh.git
   cd kassel.sh

2. Start the Docker Compose service:

   docker-compose up -d

3. Access the script from your browser at `http://localhost:8080` or download it using `curl`:

   curl -O http://localhost:8080

### Usage

1. Download and run the script with a one-liner:

   ```bash
   bash -c "$(curl -sSL http://localhost:8080)"
   ```

2. For automatic mode, use the -a flag:

    ```bash
    bash -c "$(curl -sSL http://localhost:8080)" -a
    ```