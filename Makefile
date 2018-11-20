.PHONY: all dist test init help

all: help

dist: ## Build a release version
	rm -rf examples
	rm -rf test

test: ## Run the automated tests using Terratest
	cd test; go test -v -timeout 60m

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
