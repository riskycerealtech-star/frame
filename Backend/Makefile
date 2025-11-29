.PHONY: help install test lint format local-up local-down local-logs db-setup seed clean deploy build check

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
NC     := $(shell tput -Txterm sgr0)

help: ## Show this help message
	@echo "$(BLUE)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "$(BLUE)📦 Installing dependencies...$(NC)"
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install pytest pytest-cov pytest-asyncio flake8 black isort

test: ## Run tests
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	bash scripts/run-tests.sh

lint: ## Run linter
	@echo "$(BLUE)🔍 Running linter...$(NC)"
	flake8 app tests --count --select=E9,F63,F7,F82 --show-source --statistics || true
	black --check app tests || true
	isort --check-only app tests || true

format: ## Format code
	@echo "$(BLUE)✨ Formatting code...$(NC)"
	black app tests
	isort app tests

local-up: ## Start local development environment
	@echo "$(BLUE)🚀 Starting local development environment...$(NC)"
	docker-compose -f docker-compose.dev.yml up -d
	@echo "$(GREEN)✅ Local environment started!$(NC)"
	@echo "$(BLUE)📊 API: http://localhost:8000$(NC)"
	@echo "$(BLUE)📊 PgAdmin: http://localhost:5050$(NC)"

local-down: ## Stop local development environment
	@echo "$(BLUE)🛑 Stopping local development environment...$(NC)"
	docker-compose -f docker-compose.dev.yml down
	@echo "$(GREEN)✅ Local environment stopped!$(NC)"

local-logs: ## View local development logs
	docker-compose -f docker-compose.dev.yml logs -f

db-up: ## Start database only
	@echo "$(BLUE)🗄️  Starting database...$(NC)"
	docker-compose up -d postgres
	@echo "$(GREEN)✅ Database started!$(NC)"

db-down: ## Stop database
	@echo "$(BLUE)🛑 Stopping database...$(NC)"
	docker-compose down
	@echo "$(GREEN)✅ Database stopped!$(NC)"

db-setup: ## Setup local database
	@echo "$(BLUE)🗄️  Setting up local database...$(NC)"
	bash scripts/setup-local-db.sh

seed: ## Seed sample data
	@echo "$(BLUE)🌱 Seeding sample data...$(NC)"
	python scripts/seed-data.py
	@echo "$(GREEN)✅ Data seeded!$(NC)"

clean: ## Clean up generated files
	@echo "$(BLUE)🧹 Cleaning up...$(NC)"
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov
	rm -rf dist
	rm -rf build
	@echo "$(GREEN)✅ Cleanup complete!$(NC)"

deploy: ## Deploy to Cloud Run
	@echo "$(BLUE)🚀 Deploying to Cloud Run...$(NC)"
	bash deploy.sh

build: ## Build and push Docker image
	@echo "$(BLUE)🔨 Building Docker image...$(NC)"
	bash scripts/build-and-push.sh

check: ## Check deployment health
	@echo "$(BLUE)🏥 Checking deployment...$(NC)"
	bash scripts/check-deployment.sh

dev: ## Start development server
	@echo "$(BLUE)🚀 Starting development server...$(NC)"
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

migrate: ## Run database migrations
	@echo "$(BLUE)📦 Running migrations...$(NC)"
	alembic upgrade head

migrate-create: ## Create new migration (usage: make migrate-create MESSAGE="description")
	@echo "$(BLUE)📝 Creating migration...$(NC)"
	alembic revision --autogenerate -m "$(MESSAGE)"



