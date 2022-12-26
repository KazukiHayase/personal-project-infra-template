GCP_PROJECT_ID := ""
REGISTRY_NAME := docker
HASURA_VERSION := v2.16.0

.PHONY: init
init:
	make enable_googleapis
	make create_service_account
	make create_artifact_registry
	make create_secret_manager
	make push_hasura_image

# 必要なAPIの有効化
.PHONY: enable_googleapis
enable_googleapis:
	gcloud services enable artifactregistry.googleapis.com
	gcloud services enable appengine.googleapis.com
	gcloud services enable iam.googleapis.com
	gcloud services enable run.googleapis.com
	gcloud services enable cloudresourcemanager.googleapis.com
	gcloud services enable firebase.googleapis.com
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable runtimeconfig.googleapis.com
	gcloud services enable cloudfunctions.googleapis.com
	gcloud services enable serviceusage.googleapis.com
	gcloud services enable secretmanager.googleapis.com

# Terraform用のサービスアカウントを作成
.PHONY: create_service_account
create_service_account:
	gcloud iam service-accounts create terraform --display-name="terraform"
	gcloud projects add-iam-policy-binding $(GCP_PROJECT_ID) \
		--member serviceAccount:"terraform@$(GCP_PROJECT_ID).iam.gserviceaccount.com" \
		--role "roles/owner" \
		--no-user-output-enable

# Hasuraのイメージを格納するartifact registryを作成
.PHONY: create_artifact_registry
create_artifact_registry:
	gcloud artifacts repositories create $(REGISTRY_NAME) --location=asia-northeast1 --repository-format=docker

# 手動で登録する用のシークレットマネージャーの作成
# NOTE: Neonでデータベースを作成してURLを手動でシークレットマネージャーに登録する
.PHONY: create_secret_manager
create_secret_manager:
	echo -n "" | gcloud secrets create HASURA_GRAPHQL_DATABASE_URL \
    --replication-policy="automatic" \
    --data-file=-

# Hasuraのイメージをartifact registryにpush
.PHONY: push_hasura_image
push_hasura_image:
	docker pull hasura/graphql-engine:$(HASURA_VERSION)
	docker tag hasura/graphql-engine:$(HASURA_VERSION) asia-northeast1-docker.pkg.dev/$(GCP_PROJECT_ID)/$(REGISTRY_NAME)/hasura:latest
	docker push asia-northeast1-docker.pkg.dev/$(GCP_PROJECT_ID)/$(REGISTRY_NAME)/hasura:latest
