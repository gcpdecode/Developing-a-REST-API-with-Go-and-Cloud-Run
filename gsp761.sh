#!/bin/bash

# Color Codes
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'

BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome message
echo "${BLUE_TEXT}${BOLD_TEXT}"
echo "  ██████╗██╗      ██████╗ ██╗   ██╗██████╗  ██████╗  █████╗ ██████╗  ██████╗ "
echo " ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔════╝ "
echo " ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║███████║██████╔╝██║      "
echo " ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║██╔══██║██╔══██╗██║      "
echo " ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝██║  ██║██║  ██║╚██████╗ "
echo "  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ "
echo "${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}─────────── Cloud Lab ───────────${RESET_FORMAT}"
echo


echo "${RED_TEXT}Enter your Region: ${RESET_FORMAT}"
read REGION

echo "${YELLOW_TEXT}Setting Up Project ID${RESET_FORMAT}"
gcloud config set project ProjectID

echo "${YELLOW_TEXT}${BOLD_TEXT}Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
echo "${GREEN_TEXT}Services enabled successfully${RESET_FORMAT}"

echo "${YELLOW_TEXT}Cloning repository${RESET_FORMAT}"
git clone https://github.com/rosera/pet-theory.git && cd pet-theory/lab08

echo "${YELLOW_TEXT}Creating main.go file${RESET_FORMAT}"
cat > main.go <<EOF
package main

import (
  "fmt"
  "log"
  "net/http"
  "os"
)

func main() {
  port := os.Getenv("PORT")
  if port == "" {
      port = "8080"
  }
  http.HandleFunc("/v1/", func(w http.ResponseWriter, r *http.Request) {
      fmt.Fprintf(w, "{status: 'running'}")
  })
  log.Println("Pets REST API listening on port", port)
  if err := http.ListenAndServe(":"+port, nil); err != nil {
      log.Fatalf("Error launching Pets REST API server: %v", err)
  }
}
EOF


echo "${YELLOW_TEXT}Creating Dockerfile...${RESET_FORMAT}"
cat > Dockerfile <<EOF
FROM gcr.io/distroless/base-debian12
WORKDIR /usr/src/app
COPY server .
CMD [ "/usr/src/app/server" ]
EOF


echo "${YELLOW_TEXT}Building Go binary${RESET_FORMAT}"
go build -o server

ls -la

echo "${YELLOW_TEXT}Submitting build to Cloud Build${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1



echo "${YELLOW_TEXT}Deploying to Cloud Run${RESET_FORMAT}"
gcloud run deploy rest-api \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances=2


echo "${YELLOW_TEXT}${BOLD_TEXT}Creating a Firestore database...${RESET_FORMAT}"
gcloud firestore databases create --location=$REGION


echo "${YELLOW_TEXT}${BOLD_TEXT}Rebuilding for next version...${RESET_FORMAT}"
go build -o server

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2

echo "${RED_TEXT}{ Dockerfile } created${RESET_FORMAT}"
echo "${RED_TEXT}{ main.go } created${RESET_FORMAT}"
echo "${RED_TEXT}Build completed${RESET_FORMAT}"
echo "${RED_TEXT}Image built successfully${RESET_FORMAT}"
echo "${RED_TEXT}Deployment completed${RESET_FORMAT}"
echo "${RED_TEXT}Firestore database created${RESET_FORMAT}"
echo "${RED_TEXT}Updated build submitted${RESET_FORMAT}"

echo
SCRIPT_NAME="gsp761.sh"
if [ -f "$SCRIPT_NAME" ]; then
    echo "${RED_TEXT}${BOLD_TEXT}Deleting the temporary script...${RESET_FORMAT}"
    rm -- "$SCRIPT_NAME"
fi

# Completion message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               LAB COMPLETED SUCCESSFULLY!!!           ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo

# ====== GCP DECODE Footer ======
echo "${RED_TEXT}${BOLD_TEXT}🎥 Watch more labs on:  ${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT}CloudoArc — YouTube${RESET_FORMAT}"
