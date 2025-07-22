## Setup new user

- Access your running MongoDB container
- Create a new non-admin user (e.g. `appuser`)
- Grant it only the necessary roles (e.g. readWrite on a database)
- Avoid using the root user for regular app access

---

## 🔧 Step-by-Step Using `docker exec`

### 1. **Open a shell in the container**

```bash
docker exec -it mongo bash
```

---

### 2. **Open the MongoDB shell with root user**

Assuming your root username is `admin` and port is mapped to `27018`:

```bash
mongosh --port 27017 -u admin -p --authenticationDatabase admin
```

Or if you're inside the container (no need for `--port`):

```bash
mongosh -u admin -p --authenticationDatabase admin
```

Enter your password when prompted.

---

### 3. **Create a New User (non-root)**

For example, creating a user named `appuser` with access to `myappdb`:

```javascript
use myappdb

db.createUser({
  user: "appuser",
  pwd: "appsecurepassword",
  roles: [
    { role: "readWrite", db: "myappdb" }
  ]
})
```

You can replace `readWrite` with other roles like:

- `read` – read-only
- `readWrite` – read/write to one DB
- `dbAdmin` – admin on one DB
- `readWriteAnyDatabase` – (not recommended)

---

### 4. **Test New User Access**

From your host:

```bash
mongosh "mongodb://appuser:appsecurepassword@localhost:27018/myappdb?authSource=myappdb"
```

You should see a working prompt without using the root user.

---

## ✅ Automate It (Optional)

You can create a file like `init/mongo-init-user.js`:

```js
db = db.getSiblingDB("myappdb");

db.createUser({
  user: "appuser",
  pwd: "appsecurepassword",
  roles: [{ role: "readWrite", db: "myappdb" }],
});
```

Then mount it in Docker Compose like this:

```yaml
volumes:
  - ./init/mongo-init-user.js:/docker-entrypoint-initdb.d/mongo-init-user.js:ro
```

> ✅ This script only runs the first time the container is initialized (i.e., no data yet in volume).

---

## 🔐 Best Practice

| User       | Use For      | Role        |
| ---------- | ------------ | ----------- |
| `admin`    | Admin tasks  | `root`      |
| `appuser`  | Applications | `readWrite` |
| `readonly` | Reporting/BI | `read`      |
