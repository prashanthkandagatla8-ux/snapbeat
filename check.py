import requests
try:
    resp = requests.get("http://192.168.68.104:8772/")
    print("SUCCESS", resp.status_code)
except Exception as e:
    print("ERROR", e)
