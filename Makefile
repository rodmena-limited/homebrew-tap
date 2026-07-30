.PHONY: update check fetch test all

TAP      := rodmena-limited/tap
FORMULAE := $(wildcard Formula/*.rb)
NAMES    := $(FORMULAE:Formula/%.rb=%)

update:           ## Query PyPI and update formulae with newer versions
	python3 scripts/update.py

check:            ## Dry-run: check for updates (exits 1 if any available)
	python3 scripts/update.py --dry-run

fetch:            ## Download source archives to verify URL & SHA256
	@for f in $(NAMES); do \
		echo "==> $$f"; \
		brew fetch "$(TAP)/$${f//_/-}"; \
	done

audit:            ## Run brew audit --strict on all formulae
	brew audit --strict $(FORMULAE)

test: fetch audit ## Fetch + audit (safe CI check without full install)

all: update test  ## Update then test

ci:               ## CI pipeline: check → update → PR body printed
	@echo "::group::Check for updates"
	python3 scripts/update.py --dry-run; \
		status=$$?; \
		if [ $$status -eq 0 ]; then \
			echo "All formulae up to date."; \
			echo "::endgroup::"; \
			exit 0; \
		fi; \
		echo "::endgroup::"
	@echo "::group::Apply updates"
	python3 scripts/update.py
	echo "::endgroup::"
	@echo "::group::Show changes"
	git diff --stat
	echo "::endgroup::"
	@echo ""
	@echo "changes_detected=true" >> "$(GITHUB_OUTPUT)"
	@echo "PR body follows ---"
	python3 scripts/update.py --dry-run 2>&1 | head -20

help:             ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS=":.*## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
