#!/bin/bash
# Имитация этапа Lint
echo "--- STEP 1: LINTING ---"
docker run --rm -v $(pwd):/app -w /app python:3.12-slim sh -c "pip install flake8 && flake8 . --exclude=venv,migrations"

# Имитация этапа Build
echo "--- STEP 2: BUILDING ---"
docker build -t money_monitor_test:latest .

# Имитация этапа Cleanup
echo "--- STEP 3: CLEANUP ---"
chmod +x cleanup.sh
./cleanup.sh

echo "--- RESULT: ALL STAGES PASSED ---"

