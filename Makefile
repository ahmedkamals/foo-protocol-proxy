.PHONY: all
.DEFAULT: all
.DEFAULT_GOAL: build

include Makefile.conf
include mk/main.mk

all: setup generate test coverage-html validate format nuke build-x install clean list help deploy ## to run all targets

list: ## to list all targets.
	@$(MAKE) -rRpqn | awk -F':' '/^[a-z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)printf "$(DISCLAIMER_COLOR)%-30s$(NO_COLOR)\n", A[i]}' | sort -u

help: ## to get help about the targets.
	@echo "$(OK_COLOR)$$FOO_PROTOCOL_PROXY$(NO_COLOR)"
	@echo "$(INFO_COLOR)Please use \`make <target>\`, Available options for <target> are:$(NO_COLOR)\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "  $(HELP_COLOR)%-21s$(NO_COLOR)  %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort -u

setup: ## to setup the external used tools.
	@echo "$(OK_COLOR)$(MSG_PREFIX) Setting-up required components $(MSG_SUFFIX)$(NO_COLOR)"
	@$(GO) get -u $(GO_FLAGS) golang.org/x/tools/cmd/cover \
		github.com/golang/lint/golint \
		github.com/mattn/goveralls
	@$(GO) install $(GO_FLAGS) -tags $(GO_TAGS) $(PKGS)

generate: ## to generate related files.
	@echo "$(OK_COLOR)$(MSG_PREFIX) Generating files via go generate $(MSG_SUFFIX)$(NO_COLOR)"
	@$(GO) generate $(GO_FLAGS) $(PKGS)

install: ## to install the generated binary.
	@echo "$(OK_COLOR)$(MSG_PREFIX) Installing generated binary $(MSG_SUFFIX)$(NO_COLOR)"
	@if [ ! -f $(TARGET_BINARY) ] ; then $(MAKE) build; fi
	@cp $(TARGET_BINARY) /usr/local/bin

clean: clean-bin clean-coverage ## to clean up all generated files.
	@$(GO) clean -i $(GO_FLAGS) net

nuke: ## to enforce removing the corresponding installed archive or binary.
	@$(GO) clean -i $(GO_FLAGS) ./...

run: ## to run the generated binary, and build a new one if not existed.
	@if [ ! -f $(TARGET_BINARY) ] ; then $(MAKE) build; fi
	@$(TARGET_BINARY) $(args)
