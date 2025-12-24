#!/bin/bash
# Deployment script for ISBE CertAuth Helm Chart

set -e

# Configuration
RELEASE_NAME="isbe-certauth"
NAMESPACE="certauth"
CHART_PATH="."
VALUES_FILE="values.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ISBE CertAuth Deployment ===${NC}\n"

# Parse command line arguments
COMMAND=${1:-"install"}
DRY_RUN=${2:-""}

case $COMMAND in
  install)
    echo -e "${YELLOW}Installing ISBE CertAuth...${NC}"
    helm install $RELEASE_NAME $CHART_PATH \
      --namespace $NAMESPACE \
      --create-namespace \
      --values $VALUES_FILE \
      $DRY_RUN
    ;;
  
  upgrade)
    echo -e "${YELLOW}Upgrading ISBE CertAuth...${NC}"
    helm upgrade $RELEASE_NAME $CHART_PATH \
      --namespace $NAMESPACE \
      --values $VALUES_FILE \
      --install \
      $DRY_RUN
    ;;
  
  uninstall)
    echo -e "${YELLOW}Uninstalling ISBE CertAuth...${NC}"
    helm uninstall $RELEASE_NAME --namespace $NAMESPACE
    echo -e "${RED}Note: PVCs with retain policy will not be deleted automatically${NC}"
    ;;
  
  status)
    echo -e "${YELLOW}Checking ISBE CertAuth status...${NC}"
    helm status $RELEASE_NAME --namespace $NAMESPACE
    echo ""
    kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=isbe-certauth
    ;;
  
  logs)
    echo -e "${YELLOW}Fetching ISBE CertAuth logs...${NC}"
    kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=isbe-certauth --tail=100 -f
    ;;
  
  template)
    echo -e "${YELLOW}Rendering ISBE CertAuth templates...${NC}"
    helm template $RELEASE_NAME $CHART_PATH \
      --namespace $NAMESPACE \
      --values $VALUES_FILE
    ;;
  
  diff)
    echo -e "${YELLOW}Showing diff for ISBE CertAuth upgrade...${NC}"
    if ! command -v helm-diff &> /dev/null; then
      echo -e "${RED}Error: helm-diff plugin not installed${NC}"
      echo "Install it with: helm plugin install https://github.com/databus23/helm-diff"
      exit 1
    fi
    helm diff upgrade $RELEASE_NAME $CHART_PATH \
      --namespace $NAMESPACE \
      --values $VALUES_FILE
    ;;
  
  *)
    echo -e "${RED}Unknown command: $COMMAND${NC}"
    echo ""
    echo "Usage: $0 <command> [--dry-run]"
    echo ""
    echo "Commands:"
    echo "  install   - Install the chart"
    echo "  upgrade   - Upgrade existing installation"
    echo "  uninstall - Remove the installation"
    echo "  status    - Show deployment status"
    echo "  logs      - Tail application logs"
    echo "  template  - Render templates"
    echo "  diff      - Show upgrade diff (requires helm-diff plugin)"
    echo ""
    echo "Options:"
    echo "  --dry-run - Simulate installation without applying"
    echo ""
    echo "Examples:"
    echo "  $0 install"
    echo "  $0 install --dry-run"
    echo "  $0 upgrade"
    echo "  $0 status"
    echo "  $0 logs"
    exit 1
    ;;
esac

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✓ Command completed successfully${NC}"
else
  echo -e "\n${RED}✗ Command failed${NC}"
  exit 1
fi
