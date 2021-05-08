# pip install requests to run this scrip in your local
import requests

# Edit this with the domain/ip of the VCS with port separated by colon (if ip used)
# Sample http://0.0.0.0:8000 or https://subdomain.domain
domain = "http://localhost:8080"


url = f'{domain}/now'
try:
    resp = requests.get(url)
    if resp.status_code == 200:
        print(f"server is up and returned: `{resp.text}`")
    else:
        print("uh oh..! The server is down")
except Exception:
    print("uh oh..! The server is down")
