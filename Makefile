ENGINE_COMMAND := ${shell . ./commands.sh; echo $$ENGINE_COMMAND}

.PHONY: all
all: build

.PHONY: dependencies
dependencies:
	./yarn install

.PHONY: build
build: dependencies
	./hugo --minify
	cd docs && make build
	mv ./docs/site ./public/docs
	# If we run using Docker, we should reset file ownership afterwards.
ifneq (,$(findstring docker,${ENGINE_COMMAND}))
	sudo chown -R ${shell id -u ${USER}}:${shell id -g ${USER}} ./public/
endif

.PHONY: server
server: dependencies
	./hugo server --minify --buildDrafts

.PHONY: clean
clean:
	rm -rf ./node_modules/
	rm -rf ./public/
	rm -rf ./resources/_gen/
