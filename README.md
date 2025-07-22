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
