### MongoDB (Production Docker Setup)

- MongoDB is exposed on **port 27018** (since 27017 might be in use).
- Default admin credentials are stored in `mongo.env`.
- Persistent volumes used:
  - `mongo_data` for database files
  - `mongo_config` for internal config files

#### Usage

```bash
docker-compose up -d
mongo --host 127.0.0.1 --port 27018 -u admin -p
```

#### Setup TLS with mongo and Caddy

Here's a complete, **step-by-step guide** with all necessary files and instructions to set up **MongoDB with automatic TLS using Caddy certificates** — fully dynamic, secure, and production-ready.

---

## ✅ Overview

- **Caddy** handles TLS for `mongo.example.com`, auto-generating and renewing certs.
- **MongoDB** runs in Docker with `--tlsMode requireTLS`.
- A custom `entrypoint.sh` script in Mongo's container dynamically **combines the cert + key** from Caddy into a single `mongo.pem`.
- No manual sync or cron needed — certs always reflect the current Let's Encrypt certs on restart.

---

## 🛠️ Step-by-Step Setup

---

### 🔹 1. Caddy TLS Setup

Your Caddy should already be configured like this (replace with your actual domain):

**Caddyfile**

```caddyfile
/etc/caddy/Caddyfile

mongo.makerverse.app {
  handle {
    respond "MongoDB TLS" 200
  }

  tls hello@makerverse.app
}

```

Run Caddy once to get certs issued:

```bash
sudo caddy reload --config /etc/caddy/Caddyfile
```

---

### 🔹 2. Folder Structure

```bash
project/
│
├── docker-compose.yml
├── mongo.env
├── entrypoint.sh
```

---

### 🔹 3. `mongo.env`

```env
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=strongpassword
```

---

### 🔹 4. `entrypoint.sh`

> ✅ This script waits for certs to be ready and prepares the `.pem` dynamically.

Make it executable:

```bash
chmod +x entrypoint.sh
```

---

### 🔹 5. `docker-compose.yml`

> 🔐 Change `/home/hp/.local/share/caddy/certificates` if your Caddy is in a different path.

---

### 🔹 6. Permissions (Critical)

Give Docker permission to read the Caddy certs:

```bash
sudo chgrp -R docker ~/.local/share/caddy/certificates
sudo chmod -R g+rx ~/.local/share/caddy/certificates
```

---

### 🔹 7. Start Everything

```bash
docker-compose up -d
```

The logs should show:

```sh
Combining cert.pem and privkey.pem into mongo.pem
Starting MongoDB with TLS...
```

---

## ✅ Test Connection Securely

```bash
mongo "mongodb://admin:strongpassword@mongo.makerverse.app:27018/?tls=true"
# or 
mongo "mongodb://admin:strongpassword@mongo.example.com/?tls=true&authSource=admin"

```

Make sure MongoDB is not reachable on port `27017` unless through Caddy.

---

## 🔐 Security Tips

- Mongo listens only on `127.0.0.1` to avoid direct exposure.
- Use a **firewall** to block direct access to port `27017`.
- Limit MongoDB users to least privilege.
- Let Caddy handle external TLS certs and reverse proxy duties.

Check firewall setup here: [Firewall.md](Firewall.md)
