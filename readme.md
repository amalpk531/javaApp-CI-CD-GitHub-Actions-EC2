## 1. Architectural Overview

The project implements a modern, cloud-native architecture combining **Spring Boot (Java REST Microservice)**, **Docker (Containerization)**, **GitHub Actions (CI/CD)**, and **Amazon Web Services (AWS)** hosting.

```
       Local Dev
    +--------------+
    |   VS Code    |
    |  Java / Maven|
    +-------+------+
            | Git Push
            v
   +-------------------------------------------------------------+
   |                       GitHub Actions                        |
   |                                                             |
   | [Compile & Test] -> [OIDC AWS Auth] -> [Docker Build & Push]|
   +--------------------------+-----------------------+----------+
                              |                       |
                 Docker Push  |                       | SSH Deploy Script
                              v                       v
                    +---------+---------+   +---------+---------+
                    |    Amazon ECR     |   |    Amazon EC2     |
                    |                   |   |                   |
                    |  Container Registry|   |  Docker Container |
                    +-------------------+   +-------------------+
```

### Core Design Patterns
- **Three-Tier REST Architecture:** Separates the presentation layer (Controller), business logic layer (Service), and data modeling (Model).
- **In-Memory Store:** Uses safe thread structures (`HashMap` + `AtomicLong` counter) to handle data quickly and easily without needing external database servers for prototyping.
- **Security-First CI/CD (OIDC):** Employs **OpenID Connect (OIDC)** to securely acquire temporary AWS tokens, completely removing the security risks of hardcoding long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub secrets.
- **Multi-Stage Docker Builds:** Decouples compile-time tooling from run-time components to produce small, fast, secure alpine-based container images.

---


## 2. Project Directory Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions pipeline definition
├── src/
│   ├── main/
│   │   └── java/com/demo/taskapi/
│   │       ├── TaskApiApplication.java # Spring Boot main entry point
│   │       ├── Task.java               # Task Entity / POJO Model
│   │       ├── TaskService.java        # Business Logic & memory persistence
│   │       ├── TaskController.java     # REST Controller exposing /tasks endpoint
│   │       └── HealthController.java   # App Health check exposing /health endpoint
│   └── test/
│       └── java/com/demo/taskapi/
│           └── TaskControllerTest.java # Integration tests for Controller & Health
├── Dockerfile                      # Multistage optimized Docker build file
├── .dockerignore                   # Filters out heavy or unnecessary build paths
├── iam-oidc-setup.md               # Quick manual checklist for AWS configurations
└── pom.xml                         # Maven configuration (dependencies, plug-ins)
```
