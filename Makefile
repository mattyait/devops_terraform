TF_CMD                     ?= docker compose run --rm terraform
TF_WS					   					 ?= test
TF_AUTOAPPROVE             ?= false
terraform_folderpath			 ?= deployment
environment_folderpath		= env/${TF_WS}


override TF_AUTOAPPROVE := $(if $(filter true,$(TF_AUTOAPPROVE)),-auto-approve,)

envset:
	@cat /dev/null > .env
	echo "TF_WS=$(TF_WS)" >> .env
ifdef AWS_PROFILE
	echo "AWS_PROFILE=$(AWS_PROFILE)" >> .env
endif
	@echo AWS_ACCESS_KEY_ID=$(value AWS_ACCESS_KEY_ID) >> .env
	@echo AWS_SECRET_ACCESS_KEY=$(value AWS_SECRET_ACCESS_KEY) >> .env
	@echo AWS_SESSION_TOKEN=$(value AWS_SESSION_TOKEN) >> .env

check:
ifndef TF_WS
	$(error TF_WS is undefined)
endif

shell: envset
	$(TF_CMD) /bin/bash

init: envset check
	$(TF_CMD) terraform -chdir=${terraform_folderpath} init --var-file=../${environment_folderpath}/variables.tfvars --backend-config=../${environment_folderpath}/backend.hcl --reconfigure

fmt:
	$(TF_CMD) terraform fmt --recursive

sync: envset check
	$(TF_CMD) terraform apply --refresh-only

validate: envset
	$(TF_CMD) terraform validate

plan: envset check
	$(TF_CMD) terraform -chdir=${terraform_folderpath} workspace select $(TF_WS) || $(TF_CMD) terraform -chdir=${terraform_folderpath} workspace new $(TF_WS)
	$(TF_CMD) terraform -chdir=${terraform_folderpath} plan -out=$(TF_WS).tfplan -var-file=../${environment_folderpath}/variables.tfvars
	$(TF_CMD) terraform -chdir=${terraform_folderpath} show -json $(TF_WS).tfplan | jq -er . > $(TF_WS).tfplan.json

apply: envset check
	$(TF_CMD) terraform -chdir=${terraform_folderpath} workspace select $(TF_WS) || $(TF_CMD) terraform -chdir=${terraform_folderpath} workspace new $(TF_WS)
	$(TF_CMD) terraform -chdir=${terraform_folderpath} apply -var-file=../${environment_folderpath}/variables.tfvars $(TF_AUTOAPPROVE)
