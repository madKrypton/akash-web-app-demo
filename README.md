# Akash DevOps Web App (Full-stack demo)

A small full-stack demo that implements user authentication and a DevOps information portal. The stack is React (frontend) + Node/Express (backend) + PostgreSQL (database). The frontend is served by Nginx after build and the app can be run locally with Docker Compose or deployed to a Kubernetes cluster.

This README covers how the system works, where the important code is, how to run locally using Docker Compose, and how to run on Minikube.

---

## Table of contents

- Overview
- Architecture & key files
- How it works (request flow)
- Run locally with Docker Compose
- Run on Minikube
- Environment variables
- Key code snippets
- Troubleshooting
- Next steps & improvements
- License & author

---

## Overview

This demo app supports signup/login, stores users in PostgreSQL, and issues JWTs for authenticated requests. After login the user sees an information portal about DevOps with a creative galaxy background and a lazy-loaded video card.

---

## Architecture & key files

- Frontend:
  - `frontend/src/App.js` — main app logic, session timeout handling
  - `frontend/src/components/Login.js` — login page (includes welcome text and version/author)
  - `frontend/src/components/Signup.js` — signup page
  - `frontend/src/components/MainPage.js` — main page content, video card and galaxy background
  - `frontend/src/components/GalaxyBackground.js` — animated stars and shapes
  - `frontend/src/App.css` — centralized styling
  - `frontend/Dockerfile` — creates production build and serves with Nginx

- Backend:
  - `backend/server.js` — Express server with routes for signup/login/user/health
  - `backend/Dockerfile` — backend image

- Orchestration & k8s:
  - `docker-compose.yml` — local setup (frontend, backend, postgres)
  - `k8s/` — Kubernetes manifests for namespace, services, deployments, ingress, configmaps and secrets

---

## How it works (request flow)

1. Frontend sends `POST /api/signup` with username/password.
2. Backend hashes password with bcrypt and stores the user in Postgres.
3. Backend signs a JWT and returns it to the client.
4. Frontend stores the token in `localStorage` and includes it in `Authorization` headers for protected requests.
5. After login, the main page shows DevOps content, a lazy-loaded video, and the galaxy background.

---

## Run locally with Docker Compose

Prerequisites: Docker Desktop (or Docker Engine) and Docker Compose v2+

1. Build and start services:

```bash
git clone https://github.com/madKrypton/akash-web-app-demo.git
cd akash-web-app-demo
docker compose up --build
```

2. Visit the app:

- Frontend: http://localhost:3000
- Backend health: http://localhost:5001/api/health

3. Stop and remove containers:

```bash
docker compose down
```

4. Reset DB (remove volumes):

```bash
docker compose down -v
```

Notes:
- The frontend build uses `REACT_APP_API_URL` at build time. By default the compose file sets it to point to the host-mapped backend port (so the browser bundle can reach the API). For Kubernetes builds set it empty/unset to use relative `/api` calls.

---

## Run on Minikube

1. Start Minikube:

```bash
minikube start --driver=docker
```

2. Use Minikube's Docker daemon and build images:

```bash
eval "$(minikube docker-env)"
docker build -t akash-web-app-demo-backend:local -f backend/Dockerfile ./backend
docker build -t akash-web-app-demo-frontend:local -f frontend/Dockerfile ./frontend
```

3. Deploy manifests (namespace first):

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/backend-configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/ingress.yaml
```

4. Access the frontend with Minikube service:

```bash
minikube service frontend-service -n devops-app
```

Notes:
- Update the image names in `k8s/frontend-deployment.yaml` to the local image or push images to a registry.
- Build the frontend for K8s with `REACT_APP_API_URL` unset so the app uses relative `/api` paths.

---

## Environment variables

Backend (`backend/.env` or k8s Secret):

```
PORT=5000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=authdb
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=your_jwt_secret_key_change_in_production
```

Frontend build-time env (`frontend/.env` or build args):

```
REACT_APP_API_URL=http://localhost:5001  # For local dev (browser -> host-mapped backend)
```

---

## Key code snippets

### Signup (backend/server.js) — simplified

```js
app.post('/api/signup', async (req, res) => {
  const { username, password } = req.body;
  const hashed = await bcrypt.hash(password, 10);
  await pool.query('INSERT INTO users (username,password) VALUES ($1,$2)', [username, hashed]);
  const token = jwt.sign({ username }, process.env.JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, user: { username } });
});
```

### Login (backend/server.js) — simplified

```js
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const user = await pool.query('SELECT * FROM users WHERE username=$1', [username]);
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(401).json({ message: 'Invalid credentials' });
  const token = jwt.sign({ username }, process.env.JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, user: { username } });
});
```

### Frontend login call (frontend/src/components/Login.js)

```js
const response = await axios.post(`${API_URL}/api/login`, { username, password });
localStorage.setItem('token', response.data.token);
localStorage.setItem('user', JSON.stringify(response.data.user));
```

---

## Troubleshooting

- If the browser bundle calls `http://backend:5000` and fails with `ERR_NAME_NOT_RESOLVED`, rebuild the frontend with `REACT_APP_API_URL=http://localhost:<backend-host-port>` so the browser can reach the API via host mapping.
- If PostgreSQL fails to init, check `docker compose logs postgres` and verify PVCs in K8s.
- If you see CORS issues, verify backend CORS settings and the frontend origin.

---

## Next steps & improvements

- Implement refresh token flow and server-side token expiry enforcement.
- Convert starfield to a Canvas renderer for more stars and better performance.
- Add automated tests and a CI pipeline.
- Add TLS/HTTPS for ingress (mkcert for local dev).

---

## License & Author

MIT License

Author: Akash

---

If you'd like, I can:

- Add step-by-step screenshots for common flows
- Add a Makefile to automate builds and minikube image creation
- Produce a HOWTO focused on Kubernetes deployment
