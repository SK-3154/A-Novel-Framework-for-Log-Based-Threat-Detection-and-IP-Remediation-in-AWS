def lambda_handler(event, context):

    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_item = record['dynamodb']['NewImage']

            ip = new_item['ip']['S']
            attack = new_item['attack_category']['S']

            print("=== IDS RESPONSE (DRY-RUN) ===")
            print(f"Malicious IP detected: {ip}")
            print(f"Attack category: {attack}")
            print("Action: This IP WOULD be blocked (WAF / NACL)")
            print("==============================")

    return {
        "statusCode": 200
    }
