import os
import psycopg2
from flask import Flask

app = Flask(__name__)

def get_db():
    return psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS visits (
            id SERIAL PRIMARY KEY,
            visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

@app.route('/')
def home():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('INSERT INTO visits (visited_at) VALUES (NOW())')
    conn.commit()
    cur.execute('SELECT COUNT(*) FROM visits')
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    return f"Day 06 - PostgreSQL! Visit count: {count}"

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)

