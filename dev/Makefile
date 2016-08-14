TAG := fcuny/net-http-spore

dist.ini:
	cp ../dist.ini .

.PHONY: build
build: dist.ini
	docker build -t $(TAG) .
	rm dist.ini

.PHONY: bundle
release: build
	docker run -it -v ${PWD}/..:/project $(TAG) dzil build

.PHONY: deps
deps: build
	docker run -it -v ${PWD}/..:/project $(TAG) /usr/local/bin/install-deps.sh

.PHONY: test
test: build
	@docker run -it -v ${PWD}/..:/project $(TAG) /usr/local/bin/run-tests.sh
