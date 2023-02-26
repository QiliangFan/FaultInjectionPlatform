default: test

RELEASE := elasticsearch
TIMEOUT := 1200s

install:
	helm upgrade -n elastic --wait --timeout=$(TIMEOUT) --install --values values.yaml $(RELEASE) ../../

test: install
	helm test $(RELEASE)

purge:
	helm del $(RELEASE)
