# Sayari Assessment  

### HOW-TO: Provision Terraform Infrastructure
- Clone down the repository (`git clone https://github.com/kabirg/sayari.git`)
- Set your AWS credentials (either as environment variables or in the *~/.aws/credentials* file)
- `cd` into the *infrastructure* directory.
- **Optional:** Modify the *terraform.tfvars* file if you want to use any CIDR other than the pre-configured CIDR's.
- **Optional:**: set a value for *ec2_keypair* within *terraform.tfvars* with the name of a pre-existing EC2 keypair. If you skip this, you'll just be prompted for it during the subsequent _apply_ command.
- Run the following:
`terraform init`\
`terraform apply`
- Wait a few minutes for the user_data and Ansible playbook to complete execution (if you SSH into the instance, you can view the */root/status.txt* file to see the progress of the user_data script).

**Note:** If you are unable to run docker commands as 'ec2-user' after the user_data script is complete, reboot the machine.

### HOW-TO: Build the Flask App (as a container) and Deploy
- `cd` into the *app* directory.
- Notice the `current_version` variable in `app.py` which contains the application version.
- Build the app into a container (which should also be tagged with a matching version):\
  Syntax: `docker build -t <docker_repo_name>/<container_name>:<version_tag>`\
  Ex: `docker build -t kabirgupta3/sayari-flask-app:v1.0 .`

> **Version format:** `<major_version>.<minor_version>`\
> The version number in the container-tag should match the version set in the *current_version* variable at the top of `app.py`.

- Push the image up to your registry:\
  `docker push kabirgupta3/sayari-flask-app:v1.0`
- SSH into the webserver and run the container:\
  `docker run -d -p 5000:5000 --name flask-app kabirgupta3/sayari-flask-app:v1.0`

### HOW-TO: Access the API
Enter `<public_ip>:5000/<endpoint>` into a browser or `curl` it from a command line.

### HOW-TO: Verify the Server and API are Up and Running
- Install the Python `requests` module if you don't already have it (`pip install requests`).
- Run the `test.py` Python script located in the `scripting/` directory. It requires one argument for the Public IP of the instance.
- Ex: `python3 test.py 52.7.153.51`

### HOW-TO: Update the App with a New Version
- After making your updates to the application, update the `current_version` variable at the top of `app.py`. Commit to Git repo if you're using source control.
  -
- Once ready to be pushed, build the new container (and tag it with a version that matches what you set in `app.py`):
  `docker build -t kabirgupta3/sayari-flask-app:v2.0 .`
- Within the webserver, stop the old container:
  `docker stop flask-app`
  `docker rm flask-app`
- Deploy the new container:
  `docker run -d -p 5000:5000 --name flask-app-v2 kabirgupta3/sayari-flask-app:v2.0`

### Notes, Assumptions, Improvements
- Using Terraform v14.2 and Python v3.8.2
- The webserver is a standalone instance in a public subnet with full inbound access on port 22 to allow user-access to manage the application. This is obviously not secure/scalable and wouldn't be implemented as such in a production environment.
- Using an Ansible playbook to install Docker on the webserver since it's more reliable (re: less error-prone) compared to running the docker-installation commands directly in user_data. I would've used this to deploy the container also but had some hiccups getting the playbook to play nice with Python, so going manual on the container-deployment for now.
- The Flask application listens on port 5000, but in a real environment this would be placed behind a WSGI-compliant app-server like Gunicorn, which in-turn would be behind a reverse-proxy so that it could listen on an HTTP(S) port.
- For less downtime, rather than stopping the old app before deploying the new one, we could also deploy the new one first (while mapping it to a different port), and only stop the old container if the new one is running fine.
- Everythin could be made more efficient by wrapping it in a pipeline to automate the process of building/deploying the app upon new updates.
