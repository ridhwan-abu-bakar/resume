## GCP Hosted Resume

A lightweight, containerized résumé site built with Python/Flask and deployed on Google Cloud Run. This repo demonstrates hands‑on GCP skills: Docker, Artifact Registry, Cloud Build (optional), and Cloud Run with unauthenticated public access.

---

## Features

- **Static résumé + portfolio** served by a minimal Flask app
- **Containerized** with Docker for portability
- **Serverless deployment** on Cloud Run (managed)
- **Public URL** suitable for ATS/resume links
- Clear, copy‑paste‑ready commands for local dev and GCP deployment

---

## Tech stack

- **Python** (Flask)
- **Docker**
- **Google Cloud Run**
- **Artifact Registry**
- (Optional) **Cloud Build** for CI/CD

---

## Repo structure

- `main.py` — Flask app serving the résumé page
- `templates/index.html` or `index.html` — résumé content
- `requirements.txt` — Python dependencies
- `Dockerfile` — container image definition
- `README.md` — this file

---

## Run locally

1. Create and activate a virtual environment (optional but recommended):
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Start the app:
   ```bash
   python main.py
   ```
   Visit http://localhost:8080

---

## Docker: build and run locally

1. Build the image:
   ```bash
   docker build -t resume:local .
   ```

2. Run the container:
   ```bash
   docker run -p 8080:8080 resume:local
   ```
   Visit http://localhost:8080

---

## Deploy to Google Cloud Run (manual)

Prereqs:
- Logged into gcloud and set your project
- Artifact Registry repository exists (or use gcr.io if enabled)

1. Set variables:
   ```bash
   PROJECT_ID="your-project-id"
   REGION="asia-southeast1"
   SERVICE_NAME="resume"
   REPO_NAME="resume-repo"  # Artifact Registry Docker repo name
   ```

2. Create Artifact Registry repo (one-time):
   ```bash
   gcloud artifacts repositories create "$REPO_NAME" \
     --repository-format=docker \
     --location="$REGION" \
     --description="Resume container images"
   ```

3. Configure Docker to authenticate:
   ```bash
   gcloud auth configure-docker "$REGION-docker.pkg.dev"
   ```

4. Build and push the image:
   ```bash
   IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME:latest"
   docker build -t "$IMAGE" .
   docker push "$IMAGE"
   ```

5. Deploy to Cloud Run (unauthenticated):
   ```bash
   gcloud run deploy "$SERVICE_NAME" \
     --image "$IMAGE" \
     --region "$REGION" \
     --platform managed \
     --allow-unauthenticated
   ```
   The command prints a service URL. Open it to verify.

---

## Deploy with Cloud Build (optional CI/CD)

1. Add a `cloudbuild.yaml` (example):
   ```yaml
   steps:
     - name: gcr.io/cloud-builders/docker
       args: ['build', '-t', '${_IMAGE}', '.']
     - name: gcr.io/cloud-builders/docker
       args: ['push', '${_IMAGE}']
     - name: gcr.io/google.com/cloudsdktool/cloud-sdk
       entrypoint: gcloud
       args:
         ['run', 'deploy', '${_SERVICE_NAME}', '--image', '${_IMAGE}', '--region', '${_REGION}', '--platform', 'managed', '--allow-unauthenticated']
   substitutions:
     _REGION: 'asia-southeast1'
     _SERVICE_NAME: 'resume'
     _IMAGE: 'asia-southeast1-docker.pkg.dev/$PROJECT_ID/resume-repo/resume:latest'
   ```

2. Trigger a build:
   ```bash
   gcloud builds submit --config cloudbuild.yaml
   ```

---

## Environment variables (optional)

If you need simple runtime customization (e.g., contact email), set vars at deploy:
```bash
gcloud run services update "$SERVICE_NAME" \
  --region "$REGION" \
  --update-env-vars CONTACT_EMAIL="you@example.com",LAST_UPDATED="2025-11-06"
```

Read them in `main.py` (Flask):
```python
import os
CONTACT_EMAIL = os.getenv("CONTACT_EMAIL", "you@example.com")
```

---

## Cost and access notes

- Cloud Run charges per request/compute, but small, low‑traffic personal sites typically stay within free quotas.
- Keep the service stateless and lightweight; disable excessive concurrency or large memory unless needed.
- Use `--allow-unauthenticated` for a public résumé URL; for private previews, remove that flag and grant IAM to specific viewers.

---

## Troubleshooting

- **403/Unauthenticated**: Ensure `--allow-unauthenticated` was used and no org policy blocks public invoker.
- **Image push fails**: Verify Artifact Registry repo location matches `REGION` and Docker auth is configured.
- **Service URL not loading**: Check Cloud Run logs and revisions, confirm port `8080` is used in the container.

---

## License

MIT — feel free to fork and adapt for your own résumé site.
