# Simple Makefile for this package
#
# My test.pypi.org API token is stored in 1Password in TestPyPi-token
# When making 'upload' set username to __token__ and then get and
# paste the token from 1Password.

# Use a blank pypi_repo to upload to the "non-test" repository

pypi_repo=--repository-url https://test.pypi.org/legacy/
#pypi_repo=

SRCS= \
 Makefile \
 README.md \
 LICENSE \
 setup.py \
 example_pkg/__init__.py \
 example_pkg/command_line.py \
 example_pkg/hello.py \
 tests/__init__.py \
 tests/test_hello.py

.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

.PHONY: help
help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


.PHONY: build ## Build
build: build/completed_ts

build/completed_ts: ${SRCS}
	python3 setup.py sdist bdist_wheel
	touch build/completed_ts

.PHONY: upload
upload: build/completed_ts ## Update to pypi
	python3 -m twine upload ${pypi_repo} dist/*

.PHONY: docs
docs: ## Create docs
	make -C docs clean html

.PHONY: showdocs
showdocs: ## show html doc in browser
	$(BROWSER) docs/build/html/index.html

.PHONY: test
test: ## test
	pytest tests

.PHONY: clean
clean: ## clean
	rm -rf build dist example_pkg_winksaville.egg-info __pycache__
	rm -rf .mypy_cache .pytest_cache
