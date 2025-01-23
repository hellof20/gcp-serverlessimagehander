# GCP Serverless Image Handler
This solution creates a serverless architecture to initiate cost-effective image processing in the Google Cloud. The architecture combines Google Cloud services with sharp open-source image processing software and is optimized for dynamic image manipulation. You can use this solution to help you maintain high-quality images on your websites and mobile applications to drive user engagement.

## Benefits
- Dynamic content delivery
- Low-cost storage

## Technical details
![image](https://github.com/hellof20/gcp-serverlessimagehander/assets/8756642/f0c21338-7c87-4bcb-a450-aa0caa1579d0)

- The first case: the client send request to Cloud CDN, when cache hit, returned directly from Cloud CDN
- The second case: the client send request to Cloud CDN, when cache miss, Cloud Function will get the original image from GCS and process it through Sharp and return it to Cloud CDN，then Cloud CDN return it to the client

## How to deploy
### Set environment variable
```
export project_id=your_project_id
export region=region_name
export project_num=your_project_number
```

### Enable Services
```
gcloud services enable cloudbuild.googleapis.com run.googleapis.com --project $project_id
```

### Create Service Account for Cloud Function
```
gcloud iam service-accounts create serverlessimagehandler \
--description="Service account for image handler" \
--display-name="serverlessimagehandler" \
--project=$project_id 
```

```
gcloud projects add-iam-policy-binding $project_id \
--member=serviceAccount:serverlessimagehandler@$project_id.iam.gserviceaccount.com \
--role='roles/viewer' \
--condition=None
```

### Deploy Cloud Function
```
gcloud functions deploy serverlessimagehandler \
  --trigger-http \
  --allow-unauthenticated \
  --runtime nodejs18 \
  --service-account serverlessimagehandler@$project_id.iam.gserviceaccount.com \
  --source=. \
  --region $region
```

### Deploy LB with CDN enabled
```
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
```

## Example Test
http://34.102.172.184?bucket=pwm-lowa&image=3jt.jpg&resize={}
![image](https://user-images.githubusercontent.com/8756642/228536293-55b75047-794a-42ea-bad8-24b1981e5fdd.png)

http://34.102.172.184?bucket=pwm-lowa&image=3jt.jpg&resize={"width":700}
![image](https://user-images.githubusercontent.com/8756642/228536603-aa103f58-c8e7-472c-b2f1-8018024b00ce.png)


http://34.102.172.184?bucket=pwm-lowa&image=3jt.jpg&resize={"width":400}
![image](https://user-images.githubusercontent.com/8756642/228536694-d656745c-e8d7-4918-ba4b-f6da33a2ef7e.png)


## Clean
```
gcloud compute forwarding-rules delete serverlessimagehandler-forward-rule --project=$project_id --global --quiet
gcloud compute target-http-proxies delete serverlessimagehandler-target-proxy --project=$project_id --quiet
gcloud compute url-maps delete serverlessimagehandler-lb --project=$project_id --quiet
gcloud compute backend-services delete serverlessimagehandler-bd --project=$project_id --global --quiet
gcloud compute network-endpoint-groups delete serverlessimagehandler-neg --project=$project_id --region=$region --quiet
gcloud functions delete serverlessimagehandler --project=$project_id --region=$region --quiet
gcloud projects remove-iam-policy-binding $project_id --member=serviceAccount:serverlessimagehandler@$project_id.iam.gserviceaccount.com \
  --role='roles/viewer'
gcloud iam service-accounts delete serverlessimagehandler@$project_id.iam.gserviceaccount.com --project=$project_id --quiet
```
