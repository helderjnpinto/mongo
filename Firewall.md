To **block direct access to MongoDB’s port `27018`** on Ubuntu (while still allowing access through Caddy or localhost), you can use the system firewall: **UFW** (Uncomplicated Firewall). This ensures MongoDB is not reachable directly from the outside world, even if it's mapped via Docker.

---

## ✅ Goal

- MongoDB inside Docker listens on internal port `27017`.
- Docker exposes it on `host:27018`.
- You want to **block external access to `27018`**, but **still allow access from localhost** (e.g., for Caddy).

---

## 🔧 Steps

### ✅ 1. **Enable UFW if not already active**

```bash
sudo ufw enable
```

---

### ✅ 2. **Allow localhost access to port 27018**

UFW allows localhost access by default — but you can explicitly allow it to be sure:

```bash
sudo ufw allow from 127.0.0.1 to any port 27018
```

---

### ❌ 3. **Block all external access to port 27018**

```bash
sudo ufw deny in to any port 27018
```

This denies **external network traffic** to `27018`, even if Docker is exposing it.

---

### ✅ 4. **Check UFW rules**

```bash
sudo ufw status numbered
```

You should see something like:

```
To                         Action      From
--                         ------      ----
27018                     ALLOW       127.0.0.1
27018                     DENY        Anywhere
```

---

### 🧪 5. **Test It**

- ✅ Try connecting **locally**: `mongo --port 27018` → Should work.
- ❌ Try from another machine: `mongo mongo-server:27018` → Should fail.

---

## 🔐 Optional Hardening: Bind Mongo to localhost only

You've likely already done this in your Compose setup:

```yaml
command: ["mongod", "--bind_ip", "127.0.0.1", ...]
```

This ensures MongoDB **never listens on external interfaces**, even before the firewall applies.

---

## ✅ Summary

| Rule                        | Purpose                       |
| --------------------------- | ----------------------------- |
| `allow from 127.0.0.1`      | Allow local apps (like Caddy) |
| `deny in to any port 27018` | Block external connections    |
| `--bind_ip 127.0.0.1`       | Mongo only listens internally |
