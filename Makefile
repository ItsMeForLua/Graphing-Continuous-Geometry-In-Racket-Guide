PYTHON ?= python
VENV_DIR := .venv
PROCESS_DIR := ../ProcessProse

.PHONY: venv install-pylibs style-check clean n-tree _check_venv _check_venv_activated

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

clean: 
	@echo "Cleaning Directory..."
	@rm -f *.aux *.bbl *.bcf *.blg *.log *.run.xml *.synctex.gz *.out *.toc *.txt *.json ~*