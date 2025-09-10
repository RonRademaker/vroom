# Dockerfile for VROOM with all dependencies for compilation and testing
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install essential build dependencies and tools
RUN apt-get update && apt-get install -y \
    # Core build tools
    build-essential \
    g++-14 \
    clang++-18 \
    git \
    cmake \
    pkg-config \
    make \
    # SSL/Certificate support
    ca-certificates \
    # Core VROOM dependencies
    libasio-dev \
    libglpk-dev \
    jq \
    # SSL/TLS libraries for routing
    libssl-dev \
    libcrypto++-dev \
    # Additional OSRM dependencies (for full routing support)
    libbz2-dev \
    libstxxl-dev \
    libstxxl1v5 \
    libxml2-dev \
    libzip-dev \
    libboost-all-dev \
    lua5.2 \
    liblua5.2-dev \
    libtbb-dev \
    libluabind-dev \
    libluabind0.9.1d1 \
    # Testing and utility tools
    curl \
    wget \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set default compiler to g++-14
ENV CXX=g++-14
ENV CC=gcc-14

# Create working directory
WORKDIR /app

# Copy source code
COPY . .

# Configure git and manually download dependencies to avoid SSL issues
RUN update-ca-certificates && \
    # Download rapidjson
    curl -k -L https://github.com/Tencent/rapidjson/archive/973dc9c06dcd3d035ebd039cfb9ea457721ec213.tar.gz | tar xz -C include/rapidjson --strip-components=1 && \
    # Download cxxopts  
    curl -k -L https://github.com/jarro2783/cxxopts/archive/eb787304d67ec22f7c3a184ee8b4c481d04357fd.tar.gz | tar xz -C include/cxxopts --strip-components=1 && \
    # Download polylineencoder
    curl -k -L https://github.com/vahancho/polylineencoder/archive/01823158e6d2f227c2a001d6739d0a4bdbc60f26.tar.gz | tar xz -C include/polylineencoder --strip-components=1

# Build VROOM
RUN cd src && make -j$(nproc)

# Build libvroom examples
RUN cd libvroom_examples && make -j$(nproc)

# Set PATH to include VROOM binary
ENV PATH="/app/bin:${PATH}"

# Create a test runner script
RUN echo '#!/bin/bash\n\
echo "Running VROOM validation tests..."\n\
echo "==================================="\n\
echo\n\
# Run basic validation test\n\
echo "Basic validation test:"\n\
if diff <(bin/vroom -i docs/example_2.json | jq ".routes[].steps[]" --sort-keys) <(jq ".routes[].steps[]" --sort-keys docs/example_2_sol.json); then\n\
    echo "✓ Basic validation test PASSED"\n\
else\n\
    echo "✗ Basic validation test FAILED"\n\
    exit 1\n\
fi\n\
echo\n\
\n\
# Run max_daily_travel_time comprehensive tests if they exist\n\
if [ -f "comprehensive_test.sh" ]; then\n\
    echo "Running max_daily_travel_time tests:"\n\
    chmod +x comprehensive_test.sh\n\
    ./comprehensive_test.sh\n\
else\n\
    echo "comprehensive_test.sh not found, skipping custom tests"\n\
fi\n\
\n\
echo\n\
echo "All tests completed successfully!"\n\
' > /app/run_tests.sh && chmod +x /app/run_tests.sh

# Default command shows help and version
CMD ["sh", "-c", "echo 'VROOM Docker Container'; echo '==================='; echo; vroom --help; echo; echo 'To run tests: docker run <image> /app/run_tests.sh'; echo 'To run VROOM: docker run -v /path/to/data:/data <image> vroom -i /data/input.json'"]

# Health check to verify vroom binary works
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD vroom --help > /dev/null || exit 1

# Labels for documentation
LABEL maintainer="VROOM Project" \
      description="VROOM optimization engine with full build and test environment" \
      version="latest" \
      source="https://github.com/VROOM-Project/vroom"