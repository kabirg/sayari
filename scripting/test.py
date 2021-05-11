import requests
from sys import argv

def main(server):
    domain = "http://{server}:5000".format(server=server)
    url = f'{domain}/version'

    try:
        response = requests.get(url)
        if response.status_code == 200:
            print("Server is up and returned an HTTP status of: {code}".format(code=response.status_code))
        else:
            print("Uh oh..! The server is down")
    except Exception as e:
        print("Uh oh..! The server is down")
        print(e.message)

if __name__ == '__main__':
    server = argv[1]
    app = main(server)
