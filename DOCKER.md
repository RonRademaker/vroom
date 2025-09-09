# VROOM Docker Setup

This Dockerfile provides a complete environment for compiling VROOM and running tests.

## Building the Docker Image

```bash
docker build -t vroom .
```

## Running Tests

Run the complete test suite including validation and max_daily_travel_time tests:

```bash
docker run --rm vroom /app/run_tests.sh
```

## Using VROOM

### Basic Usage

```bash
# Run VROOM with a local JSON file
docker run --rm -v /path/to/your/data:/data vroom vroom -i /data/input.json
```

### Interactive Development

```bash
# Start a container with shell access for development
docker run --rm -it vroom bash
```

### Example with Sample Data

```bash
# Run with the included example
docker run --rm vroom vroom -i docs/example_2.json
```

## Dependencies Included

The Docker image includes all necessary dependencies:

- **Build tools**: g++-14, clang++-18, make, cmake
- **Core dependencies**: libasio-dev, libglpk-dev
- **Routing support**: libssl-dev, boost libraries
- **OSRM support**: Complete OSRM build dependencies
- **Testing tools**: jq, bash, curl

## Container Details

- **Base image**: Ubuntu 24.04
- **Default compiler**: g++-14
- **Working directory**: /app
- **VROOM binary location**: /app/bin/vroom (in PATH)

## Health Check

The container includes a health check that verifies the VROOM binary is working correctly.

## Volume Mounts

For processing your own data files:

```bash
docker run --rm -v $(pwd)/data:/data vroom vroom -i /data/my_problem.json
```

This mounts your local `data` directory to `/data` in the container.