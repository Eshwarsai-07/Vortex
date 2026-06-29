# Master Architecture Document — Vortex Production Deployment Topology

This document describes the production architecture, communication interfaces, database schemas, and streaming pipelines of **Vortex** as deployed across **Vercel** and **AWS EC2**.

---

## 1. Production Topology & Component Communication

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Vercel Edge Network                                                         │
│                                                                             │
│   ┌────────────────────────┐                                                │
│   │ React 19 / Vite SPA    │                                                │
│   │ (Cloud-Hosted Edge CDN)│                                                │
│   └────────────────────────┘                                                │
└─────────────────────────────────────────────────────────────────────────────┘
             │
             │ HTTPS API Traffic (/api/*)
             v
┌─────────────────────────────────────────────────────────────────────────────┐
│ AWS EC2 Host Instance (Ubuntu 22.04 LTS via Terraform)                       │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Nginx Reverse Proxy (Port 80/443 Container)                         │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                │                                │                           │
│                │ Proxy /api/                    │ Proxy /console/           │
│                v                                v                           │
│   ┌────────────────────────┐       ┌────────────────────────┐               │
│   │ Node.js Express API    │       │ Redpanda Kafka Console │               │
│   │ (Port 5000 Container)  │       │ (Port 8080 Container)  │               │
│   └────────────────────────┘       └────────────────────────┘               │
│       │           │                                                         │
│       │           └────────────────────────────────┐                        │
│       v Mongoose                                   v Dynamic Spawns         │
│   ┌────────────────────────┐       ┌────────────────────────┐               │
│   │ MongoDB Database       │       │ Build Server Container │               │
│   │ (Port 27017 Container) │       │ (Host Docker Execution)│               │
│   └────────────────────────┘       └────────────────────────┘               │
│                                           │            │                    │
│                                 Push Logs v            v Upload Build Dist  │
│                            ┌─────────────────┐      ┌────────────────────┐  │
│                            │ Kafka Brokers   │      │ AWS S3 Static      │  │
│                            │ (3x KRaft Nodes)│      │ Artifact Hosting   │  │
│                            └─────────────────┘      └────────────────────┘  │
│                                     │                                       │
│                         Kafka Engine│ Stream Ingestion                      │
│                                     v                                       │
│                            ┌─────────────────┐                              │
│                            │ ClickHouse DB   │                              │
│                            │ (Port 8123/9000)│                              │
│                            └─────────────────┘                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Component Communication Protocols

1. **Frontend to Backend**: Vercel-hosted React app issues HTTPS requests to the Elastic IP / domain of the EC2 instance (`/api/*`).
2. **Nginx to Backend**: Nginx intercepts port 80/443 traffic and proxies `/api/*` upstream to `http://backend:5000` over the internal Docker bridge network (`deployment`).
3. **Backend to MongoDB**: Mongoose connects to `mongodb://mongodb:27017/vortex` using internal DNS.
4. **Backend to Host Docker Engine**: Mounted `/var/run/docker.sock` allows Express to dynamically invoke `docker run` to spin up isolated build execution containers on the host.
5. **Build Server to AWS S3**: Extracted static artifacts (`dist`/`build`) are uploaded directly using `@aws-sdk/client-s3`.
6. **Build Server to Kafka**: Logs are streamed in real-time to topic `build-logs` across Kafka brokers (`kafka-1`, `kafka-2`, `kafka-3`).
7. **Kafka to ClickHouse**: ClickHouse automatically pulls logs via Kafka Engine table `log_queue` and Materialized View `kafka_queue` into table `build_logs`.
8. **Backend to ClickHouse**: Log queries are executed via standard HTTP JSON protocol (`http://clickhouse:8123`).

---

## 3. Storage & Schema Specifications

### MongoDB Schema (`vortex` database)
- **`users`**: User registration, hashed passwords, email, and GitHub profile handles.
- **`deployments`**: Metadata for active deployments, repository URLs, branch names, output S3 URL, and build log summaries.

### ClickHouse Analytical Engine (`logs` database)
- **`log_queue`**: Kafka Engine consumer table listening to Kafka topic `build-logs`.
- **`build_logs`**: Indexed MergeTree storage table capturing `created_at`, `log_uuid`, `deployment_id`, `log_message`, and `log_level`.
