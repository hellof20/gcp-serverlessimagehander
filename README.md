# GCP Serverless Image Handler

## Deploy
### Set environment variable
```
export project_id=speedy-victory-336109
export region=us-central1
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
--role=roles/storage.objects.viewer
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

### Deploy CDN
```

```

## Clean

https://us-central1-speedy-victory-336109.cloudfunctions.net/serverlessimagehandler?bucket=pwm-lowa&image=3jt.jpg&resize={%22width%22:300}
