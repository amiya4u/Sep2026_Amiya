## Day 06 - Docker Compose + PostgreSQL

## What I built: 
Flask app that stores visit counts in a real PostgreSQL database (not Redis in-memory). Data persists across restarts via Docker volume.

## Python Code understanding in app.py :
- psycopg2-binary — Python library to connect to PostgreSQL. Like a driver. Without it, Python has no idea how to talk to Postgres.It handles the connection, sending SQL queries, and getting results back. 
- Function get_db() returns one object: the connection object. psycopg2.connect() takes all arguments as info, makes the connection to Postgres, and returns one connection object back.
- os.environ is a dictionary that holds all environment variables available to your Python process.
- conn.cursor() — a cursor is like a pointer into the database connection. You use it to send SQL queries. One connection can have multiple cursors.

- Environment variables in compose: Flask reads DB_HOST, DB_NAME etc via os.environ['KEY']. Postgres reads POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD. Both sides must match.
- Python code sequence 
container starts
    → init_db() runs → creates visits table
    → Flask starts listening on port 5000
    → browser hits localhost:8000
    → home() runs → inserts a row → returns count

## Explanation on @app.route('')
@app.route('/') is a decorator — it tells Flask “when someone hits this URL, run the function below it.”
@app.route('/')
def home():
    ...
/ means the root URL — http://localhost:8000/
Whatever function is immediately below the decorator gets called
The function name doesn’t matter — home, index, tinni — Flask doesn’t care
The route path is what matters — '/', '/health', '/users' etc.

So @app.route('/health') → calls whatever def is right below it when someone hits http://localhost:8000/health.

That’s it. Decorator = URL to function mapping.

## docker compose
DB_HOST: db — “db” is the service name in compose. Docker’s internal DNS resolves service names automatically. Flask connects to db and Docker routes it to the postgres container.

depends_on limitation: Only waits for the container to START — not for PostgreSQL inside it to be READY. Postgres takes 3-5 seconds to initialize. If Flask starts first and tries to connect, it crashes.

restart: on-failure — If container crashes, Docker restarts it automatically. Solves the timing race: Flask crashes once → postgres finishes init → Flask restarts and connects successfully.

## Commands 
docker compose down -v
docker logs container-name

## Bugs I fixed today:
- Copied wrong app.py (Day04 Redis version instead of PostgreSQL version)
- Copied wrong docker-compose.yaml (had ${} variable syntax, no .env file → blank passwords) This ${} syntx needs .env file. 
- postgres image without version tag pulled v18, which changed the data directory path — fixed by pinning to postgres:16
Always pin image versions: postgres:16 not postgres. “latest” can break things silently when a major version releases.

- docker compose down -v — the -v flag also removes volumes. Use when you need to start the database completely fresh (e.g. after credential or version changes).
Stale volume data causes issues — if postgres initialized with wrong/blank credentials, the env vars are ignored on next run because the data directory already exists. Fix: docker compose down -v wipes the volume so postgres reinitializes fresh.

POSTGRES_HOST is not a valid postgres env var — it does nothing. Only POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD are valid.

Pass condition: Browser shows visit count → compose down -v → compose up → count resets (new DB) → visit again → count goes up
