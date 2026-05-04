PYTHON ?= python
VENV_DIR := .venv
PROCESS_DIR := ../ProcessProse

.PHONY: help venv install-pylibs style-check clean-tex clean-scripts clean-lwarp clean-docs clean-all-exclude-docs clean-all-include-docs n-tree lwarpmk limages find-html-deps compile-tex docs auto-run _check_venv _check_venv_activated
.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo "  make venv                          Create virtual environment and upgrade pip"
	@echo "  make install-pylibs                Install Python libraries from $(PROCESS_DIR)/venvlibs.txt"
	@echo "  make n-tree FILE=<name>            Run n_tree_analysis.py on <name>.tex"
	@echo "  make style-check FILE=<name>       Run Stylometric_Analysis.py on <name>.pdf"
	@echo "  make clean-tex                     Remove TeX build artifacts"
	@echo "  make clean-scripts                 Remove script output artifacts"
	@echo "  make clean-lwarp                   Remove lwarp artifacts"
	@echo "  make clean-docs                    Remove docs/ directory"
	@echo "  make clean-all-exclude-docs        Clean all artifacts except docs/"
	@echo "  make clean-all-include-docs        Clean all artifacts including docs/"
	@echo "  make docs FILE=<name>              Build docs/ from <name>.html"
	@echo "  make lwarpmk FILE=<name>           Run lwarpmk html <name>"
	@echo "  make limages FILE=<name>           Run lwarpmk limages if <name>-images.txt exists"
	@echo "  make find-html-deps FILE=<name>    List href/src dependencies from <name>.html"
	@echo "  make compile-tex FILE=<name>       Compile <name>.tex to PDF"
	@echo "  make auto-run FILE=<name>          Run full build pipeline"

venv:
	@test -d "$(VENV_DIR)" || \
		$(PYTHON) -m venv "$(VENV_DIR)"
	@$(VENV_DIR)/bin/python -m pip install -U pip

_check_venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Error: venv '$(VENV_DIR)' does not exist, run 'make venv' first" >&2; \
		exit 1; \
	fi

_check_venv_activated:
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "Error: venv is not activated in shell; run 'source $(VENV_DIR)/bin/activate'" >&2; \
		exit 1; \
	elif [ "$$VIRTUAL_ENV" != "$(CURDIR)/$(VENV_DIR)" ]; then \
		echo "Error: venv '$(VENV_DIR)' is not the active environment" >&2; \
		echo "Active venv: $$VIRTUAL_ENV" >&2; \
		exit 1; \
	else \
		echo "Using activated venv: $$VIRTUAL_ENV"; \
	fi

install-pylibs: _check_venv _check_venv_activated
	@python -m pip install -r $(PROCESS_DIR)/venvlibs.txt

n-tree: _check_venv _check_venv_activated
	@python $(PROCESS_DIR)/n_tree_analysis.py "$(FILE).tex"

style-check: _check_venv _check_venv_activated
	@python $(PROCESS_DIR)/Stylometric_Analysis.py "$(FILE).pdf" Stylometric_Analysis.json

clean-tex: 
	@echo "Cleaning directory of tex artifacts..."
	@rm -f *.aux *.bbl *.bcf *.blg *.log *.run.xml *.synctex.gz *.out *.toc

clean-scripts:
	@echo "Cleaning directory of scripts artifacts..."
	@rm -f *.txt *.json ~*

clean-lwarp:
	@echo "Cleaning directory of lwarp artifacts..."
	@rm -f *.lwarpmkconf *_html.tex *.cut *.css *.ist *.conf *.xdy *_html.pdf *.sidetoc *_html.html

clean-docs:
	@echo "Cleaning docs/ completely..."
	@rm -rf docs/

clean-all-exclude-docs:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@echo "Cleaned project of all artifacts excluding docs/..."

clean-all-include-docs:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@$(MAKE) clean-docs
	@echo "Cleaned project of all artifacts including docs/..."

docs:
	@echo "FILE is currently set to: '$(FILE)'"; \
	if [ -z "$(FILE)" ]; then \
		echo "Warning: FILE is empty."; \
		echo "Expected usage: make docs FILE=File-Name-Without-Extension"; \
		exit 1; \
	fi; \
	printf "Proceed? [y/N] "; \
	read ans; \
	case "$$ans" in \
		[yY]|[yY][eE][sS]) ;; \
		*) echo "Aborted."; exit 1 ;; \
	esac
	@echo "Building docs/ directory..."
	@mkdir -p docs
	@cp "$(FILE).html" docs/index.html
	@# 1. Copy manual core support files
	@cp lwarp.css lwarp_formal.css lwarp_sagebrush.css lwarp_mathjax.txt docs/
	@# 2. Dynamically discover and copy local assets referenced in the HTML
	@grep -oE '(href|src)="[^"]+"' "$(FILE).html" | \
		sed -n 's/.*="\([^/:][^"]*\)".*/\1/p' | \
		sort -u | \
		while read -r file; do \
			if [ -e "$$file" ]; then \
				cp -r "$$file" docs/; \
				echo "Copied asset: $$file"; \
			fi; \
		done
	
lwarpmk:
	@echo "Running lwarpmk html $(FILE)"
	@lwarpmk html $(FILE)

limages:
	@echo "Running lwarpmk limages for $(FILE)..."
	@if [ -f "$(FILE)-images.txt" ]; then \
		lwarpmk limages $(FILE); \
	else \
		echo "No $(FILE)-images.txt found; skipping limages."; \
	fi

find-html-deps:
	@grep -oE '(href|src)="[^"]+"' '$(FILE).html'

compile-tex:
	@echo "Compiling $(FILE).tex into $(FILE).pdf..."
	@pdflatex "$(FILE).tex"

auto-run:
	@test -n "$(FILE)" || (echo "Usage: make auto-run FILE=Racket-Guide-To-Geometry" >&2; exit 1)
	@$(MAKE) clean-all-include-docs FILE="$(FILE)"
	@$(MAKE) compile-tex FILE="$(FILE)"
	@$(MAKE) lwarpmk FILE="$(FILE)"
	@$(MAKE) limages FILE="$(FILE)"
	@$(MAKE) docs FILE="$(FILE)"
	@$(MAKE) clean-all-exclude-docs FILE="$(FILE)"
	@echo "FILE=$(FILE): completed."