#!/bin/bash

# Coding Agent Orchestrator Deployment Script
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ORCHESTRATOR_IMAGE="coding-orchestrator"
AGENT_IMAGE="agent-coding"
TAG="latest"
PORT="8001"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Function to build images
build_images() {
    print_status "Building Docker images..."
    
    # Build orchestrator image
    print_status "Building orchestrator image..."
    docker build -t ${ORCHESTRATOR_IMAGE}:${TAG} ../backend
    
    # Build agent image
    print_status "Building agent image..."
    docker build -t ${AGENT_IMAGE}:${TAG} ../backend
    
    print_status "Images built successfully!"
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    print_status "Deploying with Docker Compose..."
    
    # Create jobs directory if it doesn't exist
    mkdir -p jobs
    
    # Deploy using docker-compose
    docker-compose up -d
    
    print_status "Docker Compose deployment completed!"
}

# Function to deploy to Kubernetes
deploy_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/
    
    print_status "Kubernetes deployment completed!"
}

# Function to check deployment status
check_status() {
    print_status "Checking deployment status..."
    
    # Check if orchestrator is running
    if docker ps | grep -q ${ORCHESTRATOR_IMAGE}; then
        print_status "Orchestrator is running"
    else
        print_warning "Orchestrator is not running"
    fi
    
    # Check if agent image exists
    if docker images | grep -q ${AGENT_IMAGE}; then
        print_status "Agent image is available"
    else
        print_warning "Agent image is not available"
    fi
    
    # Test API endpoint
    sleep 5
    if curl -s http://localhost:${PORT}/docs &> /dev/null; then
        print_status "API is accessible at http://localhost:${PORT}"
    else
        print_warning "API is not accessible"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -m, --mode MODE         Deployment mode (docker-compose|kubernetes)"
    echo "  -p, --port PORT         Port for the orchestrator (default: 8001)"
    echo "  -t, --tag TAG           Docker image tag (default: latest)"
    echo ""
    echo "Examples:"
    echo "  $0 -m docker-compose    Deploy using Docker Compose"
    echo "  $0 -m kubernetes        Deploy to Kubernetes"
    echo "  $0 -m docker-compose -p 8080  Deploy on port 8080"
}

# Main deployment function
main() {
    local mode="docker-compose"
    local port=${PORT}
    local tag=${TAG}
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -m|--mode)
                mode="$2"
                shift 2
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -t|--tag)
                tag="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting deployment..."
    print_status "Mode: $mode"
    print_status "Port: $port"
    print_status "Tag: $tag"
    
    # Check prerequisites
    check_prerequisites
    
    # Build images
    build_images
    
    # Deploy based on mode
    case $mode in
        "docker-compose")
            deploy_docker_compose
            ;;
        "kubernetes")
            deploy_kubernetes
            ;;
        *)
            print_error "Invalid mode: $mode"
            print_error "Valid modes: docker-compose, kubernetes"
            exit 1
            ;;
    esac
    
    # Check status
    check_status
    
    print_status "Deployment completed successfully!"
    print_status "API documentation: http://localhost:${port}/docs"
    print_status "Health check: http://localhost:${port}/health"
}

# Run main function with all arguments
main "$@" 