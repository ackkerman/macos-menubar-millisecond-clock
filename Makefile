SWIFT=swift
APP_NAME=msbar
BUILD_DIR=.build
APP_BUNDLE=$(APP_NAME).app

.PHONY: setup build release run test bundle app clean format lint

setup:
	@echo "No extra dependencies. Using system SwiftPM."

build:
	$(SWIFT) build

release:
	$(SWIFT) build -c release

run:
	$(SWIFT) run

test:
	$(SWIFT) test

bundle: release
	./make_app.sh

app: bundle

install: app
	cp -R $(APP_BUNDLE) /Applications/$(APP_BUNDLE)

clean:
	$(SWIFT) package clean
	rm -rf $(APP_BUNDLE)

format:
	@echo "No formatter configured."

lint:
	@echo "No linter configured."
