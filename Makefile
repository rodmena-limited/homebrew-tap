.PHONY: update check fetch test all

TAP      := rodmena-limited/tap
FORMULAE := $(wildcard Formula/*.rb)
NAMES    := $(FORMULAE:Formula/%.rb=%)

update:           ## Query PyPI and update formulae with newer versions
	python3 scripts/update.py

check:            ## Dry-run: check for updates (exits 1 if any available)
	python3 scripts/update.py --dry-run

fetch:            ## Download source archives to verify URL & SHA256
	@# NOT $${f//_/-}: the formula name IS the file name, underscores and
	@# all. resilient_circuit is a real formula and resilient-circuit is
	@# not, so that substitution made this target fail on the one formula
	@# whose name contains an underscore -- and pass on every other, which
	@# is why it went unnoticed.
	@for f in $(NAMES); do \
		echo "==> $$f"; \
		brew fetch --formula "$(TAP)/$$f" || exit 1; \
	done

audit:            ## Run brew audit --strict on all formulae
	@# By TAP, not by path: `brew audit [path ...]` is disabled in current
	@# Homebrew and exits with "Use `brew audit [name ...]` instead", so
	@# this target could not run at all.
	brew audit --strict --tap $(TAP)

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
