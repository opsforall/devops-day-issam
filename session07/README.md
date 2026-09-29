# AKS tools - Session 07: Deploy a microservice and expose it to the internet

This session covers the dockerization , the deployement and the expose of the microservice to the internet

## 0.Connect to Dockehub
1. Open `https://hub.docker.com/`
2. Login to your account (if you don't have an account, click Signup and create one)
3. Create a `Repository` named `frontend`

## 1. Dockerize the App
1. Access the file named `frontend.zip` and download it to your `laptop`. Extract the content and copy the folder `frontend` inside the folder `devops-day`.

2. Access the folder `frontend`, and open it inside VS Code.

3. Create a file named `Dockerfile` and copy the following content inside

```bash
FROM nginx:alpine

COPY . /usr/share/nginx/html

EXPOSE 80 
```

4. Open `Terminal` in `VS code`and run the following command

```bash
docker ps
```

If you receive any error, open `Docker Desktop` app and ensure it's working 

5. Run the following command to connect to Dockerhub

```bash
docker login
```

6. Copy the following command inside the `Terminal` to build the App

```bash
docker build -t username/frontend:v1 .

```

Replace `username` with your `Dockerhub` username 

7. Copy the following command inside the `Terminal` to push the Docker image to Dockerhub

```bash
docker push username/frontend:v1 
```

Replace `username` with your `Dockerhub` username 

8. Copy the following command inside the `Terminal` to test in the App

```bash
docker run --name frontend -d -p 8080:80 username/frontend:v1
```

Replace `username` with your `Dockerhub` username 

To check if it's working, open `Chrome` and open the following `URL`

```bash
localhost:8080
```

9. Stop and Remove the app

Copy the following command inside the `Terminal` to get the name the `App` 

```bash
docker rm -f frontend
```
## 2. Deploy the App to AKS
1. Go back to `aks-tools` project in `VS Code`

2. Inside the folder `kubernetes` that exist in the root folder, open the folder `manifests`, create a folder named `frontend`

3. Inside the folder `frontend`, create a file named `deploy.yaml` and copy the following content inside

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: username/frontend:v1
          ports:
            - containerPort: 80
```

Replace `username` with your `Dockerhub` username 

4. Inside the folder `frontend`, create a file named `svc.yaml` and copy the following content inside

```bash
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

### Access the frontend using port forwarding

After deploying the app and service to AKS, run the following command in your terminal:

```bash
kubectl port-forward svc/frontend-svc 8080:80
```

If you deployed the service in a specific namespace, add `-n <namespace>` to the command.

Keep the terminal open and visit [http://localhost:8080](http://localhost:8080) in your browser. Press `Ctrl+C` to stop port forwarding.

### Step 3: desinstall tools 

1. In your github repository, click on `Actions`

2. In the left panel, click on `Desinstall tools`, click on `Run workflow`, choose `dev` workspace, fill the fields `cluster_name` and `rg_name` with your own cluster name and rg name. Click on `Run workflow` under them.
