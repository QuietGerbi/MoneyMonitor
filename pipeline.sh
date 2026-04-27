#!/bin/bash
set -e  # Остановить выполнение, если какая-то команда упадет

# Цвета для красоты
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}>>> Starting Full Pipeline Simulation...${NC}"

# STAGE 1: LINT
echo -e "\n${GREEN} [1/3] Running Stage: LINT${NC}"
docker run --rm -v $(pwd):/app -w /app python:3.12-slim sh -c "pip install flake8 && flake8 . --exclude=venv,migrations,lib,bin,include"

# STAGE 2: BUILD
echo -e "\n${GREEN} [2/3] Running Stage: BUILD${NC}"
# Собираем образ твоего приложения
docker build -t moneymonitor_app:latest .

# STAGE 3: CLEANUP (Твой кастомный скрипт)
echo -e "\n${GREEN} [3/3] Running Stage: CLEANUP${NC}"
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh

echo -e "\n${GREEN}>>> PIPELINE PASSED SUCCESSFULLY! 🚀${NC}"

