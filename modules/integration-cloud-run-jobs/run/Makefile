REGISTRY := "YOUR_ARTIFACT_REGISTRY"
TAG := "latest"

auth:
	@gcloud auth configure-docker asia-northeast1-docker.pkg.dev

build:
	@docker build -t $(REGISTRY):$(TAG) .

push:
	@docker push $(REGISTRY):$(TAG)

# https://cloud.google.com/sdk/gcloud/reference/beta/run/jobs/create
create-job:
	@gcloud beta run jobs create integration-cloud-run-jobs \
	    --region europe-west9 \
		--image $(REGISTRY) \
		--cpu 1.0 --memory 512Mi \
		--tasks 2 --task-timeout 3m \
		--max-retries 2 \
		--parallelism 2
