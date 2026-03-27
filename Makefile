.PHONY: install uninstall test lint fmt check

SHELL_FILES := bin/pass-ui lib/backend.sh lib/ui.sh lib/utils.sh lib/validation.sh lib/preview-entry.sh lib/preview-field.sh lib/copy-field.sh install uninstall

install:
	bash install

uninstall:
	bash uninstall

test:
	bats tests/

lint:
	shellcheck -x --source-path=SCRIPTDIR $(SHELL_FILES)

fmt:
	shfmt -w -i 2 -ci $(SHELL_FILES)

check: lint test
