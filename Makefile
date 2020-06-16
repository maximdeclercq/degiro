languages = java go python

all: $(languages)
.PHONY: all

$(languages):
	rm -rf $(CURDIR)/out/$@
	mkdir -p $(CURDIR)/out/$@
	docker run --rm -it \
		-v $(CURDIR):/local \
		--workdir /local \
		--user "$(shell id -u):$(shell id -g)" \
		openapitools/openapi-generator-cli generate \
			-i schema/api-docs.yaml \
			-c config/$@.json \
			-g $@ \
			-o out/$@

python-requirements:
	python3 -m pip install setuptools twine

python-install: python-requirements python
	cd $(CURDIR)/out/python && python3 $(CURDIR)/out/python/setup.py install

python-upload: python-requirements python
	rm -rf $(CURDIR)/out/python/dist/*
	cd $(CURDIR)/out/python && python3 setup.py sdist bdist_wheel
	python3 -m twine upload --repository testpypi -u $(USERNAME) -p $(PASSWORD) $(CURDIR)/out/python/dist/*

clean:
	rm -rf $(CURDIR)/out
