import boto3
import csv
import os
from datetime import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

TABLE_NAME = os.environ['DDB_TABLE']

# UNSW-NB15 RAW COLUMN INDEXES (0-based)
SRCIP_INDEX = 0
ATTACK_CAT_INDEX = 47  # empty = normal, non-empty = attack

def lambda_handler(event, context):
    bucket = event['bucket']
    key = event['key']

    table = dynamodb.Table(TABLE_NAME)

    obj = s3.get_object(Bucket=bucket, Key=key)
    lines = obj['Body'].read().decode('utf-8-sig').splitlines()
    # utf-8-sig removes BOM automatically

    reader = csv.reader(lines)

    malicious_ips = {}

    for row in reader:
        try:
            srcip = row[SRCIP_INDEX].strip()
            attack = row[ATTACK_CAT_INDEX].strip()

            # CORE IDS LOGIC
            if attack != "":
                if srcip not in malicious_ips:
                    malicious_ips[srcip] = attack

        except Exception:
            continue

    for ip, attack in malicious_ips.items():
        table.put_item(
    Item={
        'ip': ip,
        'detected_at': datetime.utcnow().isoformat(),
        'attack_category': attack,
        'dataset': os.path.basename(key)
    }
)

    print(f"Detected {len(malicious_ips)} malicious IPs")

    return {
        "statusCode": 200,
        "detected_ips": len(malicious_ips)
    }
