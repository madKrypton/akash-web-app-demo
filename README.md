# DevOps Authentication Application

A full-stack web application with React frontend, Node.js Express backend, and PostgreSQL database. Features user authentication (login/signup) and a DevOps information portal.

## 🚀 Features

- **User Authentication**: Secure login and signup functionality
- **JWT-based Authorization**: Token-based authentication system
- **Password Hashing**: Secure password storage using bcrypt
- **DevOps Information Portal**: Educational content about DevOps practices
- **Responsive Design**: Modern, gradient UI with smooth animations
- **Dockerized**: Complete Docker setup for easy deployment

## 📁 Project Structure

```
Akash-web-app/
├── frontend/                      # React frontend application
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── Login.js          # Login page component
│   │   │   ├── Signup.js         # Signup page component
│   │   │   └── MainPage.js       # Main DevOps info page
│   │   ├── App.js                # Main app component
│   │   ├── App.css               # Global styles
│   │   └── index.js              # React entry point
│   ├── Dockerfile                # Frontend Docker image
│   ├── nginx.conf                # Nginx configuration
│   ├── .dockerignore
│   ├── .env
│   └── package.json
├── backend/                       # Node.js Express backend
│   ├── server.js                 # Express API server
│   ├── Dockerfile                # Backend Docker image
│   ├── .dockerignore
│   ├── .env                      # Environment variables
│   └── package.json
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── postgres-configmap.yaml   # PostgreSQL config
│   ├── postgres-secret.yaml      # Secrets (passwords, JWT)
│   ├── postgres-pvc.yaml         # Persistent volume claim
│   ├── postgres-deployment.yaml  # PostgreSQL deployment
│   ├── backend-configmap.yaml    # Backend config
│   ├── backend-deployment.yaml   # Backend deployment
│   ├── frontend-deployment.yaml  # Frontend deployment
│   ├── ingress.yaml              # Ingress configuration
│   └── README.md                 # K8s deployment guide
├── .github/
│   └── copilot-instructions.md   # GitHub Copilot instructions
├── docker-compose.yml            # Docker Compose orchestration
├── deploy-k8s.ps1                # K8s deployment script (Windows)
├── deploy-k8s.sh                 # K8s deployment script (Linux/Mac)
├── cleanup-k8s.ps1               # K8s cleanup script
├── k8s-helper.ps1                # K8s helper utilities
├── KUBERNETES.md                 # K8s deployment summary
├── .gitignore
└── README.md                     # Main documentation
```

## 🛠️ Technologies Used

### Frontend
- React 18
- Axios for API calls
- CSS3 with gradients and animations

### Backend
- Node.js
- Express.js
- PostgreSQL
- JWT for authentication
- Bcrypt for password hashing

### DevOps & Infrastructure
- Docker & Docker Compose
- Kubernetes (K8s)
- Nginx (for serving React app)
- ConfigMaps & Secrets
- Persistent Volumes
- Health Checks & Probes

## 📋 Prerequisites

### For Docker Compose
- Docker Desktop installed
- Docker Compose installed

### For Kubernetes
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl installed and configured
- Docker (for building images)

### For Manual Setup
- Node.js 18+ and npm
- PostgreSQL 15+

## 🚀 Quick Start

### Option 1: Using Kubernetes (Production-Ready)

1. **Prerequisites**:
   - Kubernetes cluster (minikube, kind, GKE, EKS, AKS)
   - kubectl installed and configured

2. **Deploy using the script**:
   ```powershell
   .\deploy-k8s.ps1
   ```
   
   Or deploy manually:
   ```powershell
   kubectl apply -f k8s/
   ```

3. **Access the application**:
   ```powershell
   # Using port-forward
   kubectl port-forward service/frontend-service 3000:80 -n devops-app
   
   # Or using minikube
   minikube service frontend-service -n devops-app
   ```

4. **Check deployment status**:
   ```powershell
   kubectl get all -n devops-app
   ```

📖 **Full Kubernetes guide**: See [k8s/README.md](k8s/README.md)

### Option 2: Using Docker Compose (Local Development)

1. **Clone the repository** (if not already done):
   ```bash
   cd c:\Akash-web-app
   ```

2. **Start all services**:
   ```powershell
   docker-compose up --build
   ```

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - PostgreSQL: localhost:5432

4. **Stop all services**:
   ```powershell
   docker-compose down
   ```

5. **Stop and remove volumes** (clean database):
   ```powershell
   docker-compose down -v
   ```

### Manual Setup (Without Docker)

#### Backend Setup

1. Navigate to backend directory:
   ```powershell
   cd backend
   ```

2. Install dependencies:
   ```powershell
   npm install
   ```

3. Set up PostgreSQL database:
   - Create a database named `authdb`
   - Update `.env` file with your database credentials

4. Start the backend server:
   ```powershell
   npm start
   ```
   Backend will run on http://localhost:5000

#### Frontend Setup

1. Navigate to frontend directory:
   ```powershell
   cd frontend
   ```

2. Install dependencies:
   ```powershell
   npm install
   ```

3. Update `.env` file if needed:
   ```
   REACT_APP_API_URL=http://localhost:5000
   ```

4. Start the React app:
   ```powershell
   npm start
   ```
   Frontend will run on http://localhost:3000

## 🔑 Environment Variables

### Backend (.env)
```
PORT=5000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=authdb
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=your_jwt_secret_key_change_in_production
```

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5000
```

**⚠️ Important**: Change the `JWT_SECRET` in production!

## 📡 API Endpoints

### Authentication

- **POST** `/api/signup`
  - Body: `{ "username": "string", "password": "string" }`
  - Response: `{ "token": "jwt_token", "user": {...} }`

- **POST** `/api/login`
  - Body: `{ "username": "string", "password": "string" }`
  - Response: `{ "token": "jwt_token", "user": {...} }`

- **GET** `/api/user` (Protected)
  - Headers: `Authorization: Bearer <token>`
  - Response: `{ "user": {...} }`

- **GET** `/api/health`
  - Response: `{ "status": "OK", "message": "Server is running" }`

## 🎨 Features Overview

### Login Page
- Username and password authentication
- Error handling and validation
- Switch to signup page

### Signup Page
- Create new user account
- Password confirmation
- Username uniqueness validation
- Minimum password length (6 characters)

### Main Page (After Login)
- Welcome message with username
- Comprehensive DevOps information:
  - Overview of DevOps
  - Core principles
  - Popular tools
  - Benefits
  - DevOps lifecycle
- Logout functionality

## 🔒 Security Features

- Passwords hashed using bcrypt (10 salt rounds)
- JWT tokens for secure authentication
- Token expiration (24 hours)
- Protected API routes
- SQL injection prevention using parameterized queries
- CORS enabled for frontend-backend communication

## 🐛 Troubleshooting

### Docker Issues

1. **Port already in use**:
   ```powershell
   docker-compose down
   # Change ports in docker-compose.yml if needed
   ```

2. **Database connection issues**:
   - Ensure PostgreSQL container is healthy
   - Check logs: `docker-compose logs postgres`

3. **Frontend can't connect to backend**:
   - Verify backend is running: `docker-compose logs backend`
   - Check network configuration in docker-compose.yml

### Common Errors

- **"Username already exists"**: Try a different username
- **"Invalid username or password"**: Check credentials
- **Database errors**: Ensure PostgreSQL is running and accessible

## 📝 Development Notes

- Backend uses Express.js with PostgreSQL connection pooling
- Frontend uses React hooks (useState, useEffect)
- Authentication persists using localStorage
- Responsive design works on mobile and desktop

## ☸️ Kubernetes Deployment

The application is production-ready with complete Kubernetes manifests:

### Features
- **PostgreSQL StatefulSet** with persistent storage
- **Backend Deployment** with 2 replicas and health checks
- **Frontend Deployment** with 2 replicas
- **ConfigMaps** for configuration management
- **Secrets** for sensitive data
- **Services** for internal communication
- **LoadBalancer** for external access
- **Optional Ingress** for advanced routing

### Quick Deploy
```powershell
# Build and deploy everything
.\deploy-k8s.ps1

# Or manually
kubectl apply -f k8s/
```

### Verify Deployment
```powershell
kubectl get all -n devops-app
kubectl logs -f deployment/backend -n devops-app
```

### Scale Applications
```powershell
kubectl scale deployment backend --replicas=3 -n devops-app
kubectl scale deployment frontend --replicas=3 -n devops-app
```

### Cleanup
```powershell
kubectl delete namespace devops-app
```

📖 **Complete Kubernetes documentation**: [k8s/README.md](k8s/README.md)

## 🔄 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 📦 Docker Commands

```powershell
# Build and start all services
docker-compose up --build

# Start services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove volumes (clean database)
docker-compose down -v

# Rebuild specific service
docker-compose build backend
docker-compose build frontend
```

## 🤝 Contributing

Feel free to fork this project and submit pull requests for any improvements!

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Created as a demonstration of full-stack development with DevOps practices.

---

**Happy Coding! 🚀**
