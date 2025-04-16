#!/bin/bash

REGION="eu-west-1"
BUILD_PROJECT="ecommerce-app-build-new"

echo "Checking build stage logs..."

# Get the latest build ID
BUILD_ID=$(aws codebuild list-builds-for-project \
    --project-name $BUILD_PROJECT \
    --region $REGION \
    --query 'ids[0]' \
    --output text)

if [ "$BUILD_ID" != "None" ]; then
    echo "Build ID: $BUILD_ID"
    
    # Get build details
    BUILD_DETAILS=$(aws codebuild batch-get-builds \
        --ids $BUILD_ID \
        --region $REGION)

    # Get build status
    BUILD_STATUS=$(echo $BUILD_DETAILS | jq -r '.builds[0].buildStatus')
    echo "Build Status: $BUILD_STATUS"

    # Get CloudWatch logs
    LOGS_GROUP=$(echo $BUILD_DETAILS | jq -r '.builds[0].logs.groupName')
    LOGS_STREAM=$(echo $BUILD_DETAILS | jq -r '.builds[0].logs.streamName')
    
    if [ "$LOGS_GROUP" != "null" ] && [ "$LOGS_STREAM" != "null" ]; then
        echo "Build Logs:"
        aws logs get-log-events \
            --log-group-name $LOGS_GROUP \
            --log-stream-name $LOGS_STREAM \
            --region $REGION \
            --query 'events[*].message' \
            --output text
    fi

    # Get build phases
    echo -e "\nBuild Phases:"
    aws codebuild batch-get-builds \
        --ids $BUILD_ID \
        --region $REGION \
        --query 'builds[0].phases[*].[phaseType,phaseStatus]' \
        --output text
else
    echo "No build found for project $BUILD_PROJECT"
fi 