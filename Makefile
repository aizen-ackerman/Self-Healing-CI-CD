SHELL := /bin/bash

CLUSTER_NAME ?= gitops-demo
APP_IMAGE ?= self-healing-app:v1
BROKEN_IMAGE ?= self-healing-app:broken

.PHONY: test bootstrap-local build load deploy install-argocd install-gitops local-git status break heal

test:
	python3 -m unittest discover -s tests -v

build:
	docker build -t $(APP_IMAGE) .

load:
	./scripts/load_image_into_kind.sh $(APP_IMAGE)

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

install-argocd:
	./scripts/install_argocd.sh

install-gitops:
	./scripts/configure_gitops.sh

local-git:
	./scripts/start_local_git_remote.sh

bootstrap-local:
	./scripts/bootstrap_local.sh

status:
	./scripts/status.sh

break:
	./scripts/simulate_failure.sh $(BROKEN_IMAGE)

heal:
	./scripts/recover.sh
