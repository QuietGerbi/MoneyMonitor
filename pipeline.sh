set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}>>> Starting Full Pipeline Simulation...${NC}"

echo -e "\n${GREEN} [1/3] Running Stage: LINT${NC}"
docker run --rm -v $(pwd):/app -w /app python:3.12-slim sh -c "pip install flake8 && flake8 . --exclude=venv,migrations,lib,bin,include"

echo -e "\n${GREEN} [2/3] Running Stage: BUILD${NC}"
docker build -t moneymonitor_app:latest .

echo -e "\n${GREEN} [3/3] Running Stage: CLEANUP${NC}"
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh

echo -e "\n${GREEN}>>> PIPELINE PASSED SUCCESSFULLY ${NC}"

