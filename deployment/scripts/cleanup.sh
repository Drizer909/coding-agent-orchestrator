#!/bin/bash

# Coding Agent Orchestrator Cleanup Script
# This script removes deployed resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Function to cleanup Docker Compose
cleanup_docker_compose() {
    print_status "Cleaning up Docker Compose resources..."
    
    # Stop and remove containers
    docker-compose down -v
    
    # Remove images
    docker rmi coding-orchestrator:latest agent-coding:latest 2>/dev/null || true
    
    print_status "Docker Compose cleanup completed!"
}

# Function to cleanup Kubernetes
cleanup_kubernetes() {
    print_status "Cleaning up Kubernetes resources..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Delete Kubernetes resources
    kubectl delete -f k8s/ --ignore-not-found=true
    
    # Delete any remaining PVCs
    kubectl delete pvc --selector=app=coding-orchestrator --ignore-not-found=true
    
    print_status "Kubernetes cleanup completed!"
}

# Function to cleanup Docker resources
cleanup_docker() {
    print_status "Cleaning up Docker resources..."
    
    # Stop and remove orchestrator container
    docker stop coding-orchestrator 2>/dev/null || true
    docker rm coding-orchestrator 2>/dev/null || true
    
    # Remove agent containers
    docker ps -a --filter "name=agent_" --format "{{.ID}}" | xargs -r docker rm -f
    
    # Remove images
    docker rmi coding-orchestrator:latest agent-coding:latest 2>/dev/null || true
    
    # Remove jobs directory
    rm -rf jobs/
    
    print_status "Docker cleanup completed!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -m, --mode MODE         Cleanup mode (docker-compose|kubernetes|docker|all)"
    echo "  -f, --force             Force cleanup without confirmation"
    echo ""
    echo "Examples:"
    echo "  $0 -m docker-compose    Cleanup Docker Compose resources"
    echo "  $0 -m kubernetes        Cleanup Kubernetes resources"
    echo "  $0 -m all               Cleanup all resources"
    echo "  $0 -m all -f            Force cleanup all resources"
}

# Function to confirm cleanup
confirm_cleanup() {
    local mode="$1"
    
    if [[ "$FORCE" != "true" ]]; then
        echo -e "${YELLOW}Are you sure you want to cleanup $mode resources? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_status "Cleanup cancelled."
            exit 0
        fi
    fi
}

# Main cleanup function
main() {
    local mode="all"
    local force=false
    
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
            -f|--force)
                force=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting cleanup..."
    print_status "Mode: $mode"
    print_status "Force: $force"
    
    # Confirm cleanup
    confirm_cleanup "$mode"
    
    # Cleanup based on mode
    case $mode in
        "docker-compose")
            cleanup_docker_compose
            ;;
        "kubernetes")
            cleanup_kubernetes
            ;;
        "docker")
            cleanup_docker
            ;;
        "all")
            cleanup_docker_compose
            cleanup_kubernetes
            cleanup_docker
            ;;
        *)
            print_error "Invalid mode: $mode"
            print_error "Valid modes: docker-compose, kubernetes, docker, all"
            exit 1
            ;;
    esac
    
    print_status "Cleanup completed successfully!"
}

# Run main function with all arguments
main "$@" 