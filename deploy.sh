#!/bin/bash
export project_id=speedy-victory-336109
export region=us-central1

gcloud iam service-accounts create serverlessimagehandler \
    --description="Service account for image handler" \
    --display-name="serverlessimagehandler" \
    --project=$project_id 

gcloud projects add-iam-policy-binding $project_id \
    --member=serviceAccount:serverlessimagehandler@$project_id.iam.gserviceaccount.com \
    --role='roles/viewer' \
    --condition=None

gcloud functions deploy serverlessimagehandler \
  --trigger-http \
  --allow-unauthenticated \
  --runtime nodejs18 \
  --service-account serverlessimagehandler@$project_id.iam.gserviceaccount.com \
  --source=. \
  --region $region

gcloud compute network-endpoint-groups create serverlessimagehandler-neg \
    --region=$region \
    --network-endpoint-type=serverless  \
    --cloud-function-name=serverlessimagehandler \
    --project=$project_id

gcloud compute backend-services create serverlessimagehandler-bd \
    --load-balancing-scheme=EXTERNAL \
    --global \
    --enable-cdn \
    --project=$project_id

gcloud compute backend-services add-backend serverlessimagehandler-bd \
    --global \
    --network-endpoint-group=serverlessimagehandler-neg \
    --network-endpoint-group-region=us-central1 \
    --project=$project_id
    
gcloud compute url-maps create serverlessimagehandler-lb \
    --default-service serverlessimagehandler-bd \
    --project=$project_id
      
gcloud compute target-http-proxies create serverlessimagehandler-target-proxy \
    --url-map=serverlessimagehandler-lb \
    --project=$project_id
      
gcloud compute forwarding-rules create serverlessimagehandler-forward-rule \
    --load-balancing-scheme=EXTERNAL \
    --network-tier=PREMIUM \
    --target-http-proxy=serverlessimagehandler-target-proxy \
    --global \
    --ports=80 \
    --project=$project_id

gcloud compute forwarding-rules describe serverlessimagehandler-forward-rule --global --project=$project_id --format="csv(IPAddress)"    