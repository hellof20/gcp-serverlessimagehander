#!/bin/bash
export project_id=speedy-victory-336109
export region=us-central1

gcloud compute forwarding-rules delete serverlessimagehandler-forward-rule \
    --project=$project_id \
    --global \
    --quiet

gcloud compute target-http-proxies delete serverlessimagehandler-target-proxy \
    --project=$project_id --quiet

gcloud compute url-maps delete serverlessimagehandler-lb \
    --project=$project_id --quiet

gcloud compute backend-services delete serverlessimagehandler-bd \
    --project=$project_id --global --quiet

gcloud compute network-endpoint-groups delete serverlessimagehandler-neg \
    --project=$project_id --region=$region --quiet

gcloud functions delete serverlessimagehandler --project=$project_id --region=$region --quiet

gcloud projects remove-iam-policy-binding $project_id \
    --member=serviceAccount:serverlessimagehandler@$project_id.iam.gserviceaccount.com \
    --role='roles/viewer' \
    --condition=None

gcloud iam service-accounts delete serverlessimagehandler@$project_id.iam.gserviceaccount.com \
    --project=$project_id --quiet