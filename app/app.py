from flask import Flask, render_template, request, redirect, url_for
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)


# -----------------------------
# Database Connection
# -----------------------------
def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ.get("DB_PORT", "5432"),
        database=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        sslmode=os.environ.get("DB_SSLMODE", "require")
    )


# -----------------------------
# Initialize Database
# -----------------------------
def initialize_database():
    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS pets (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    breed VARCHAR(100) NOT NULL,
                    age INTEGER NOT NULL,
                    species VARCHAR(50) NOT NULL,
                    status VARCHAR(50) NOT NULL DEFAULT 'Available'
                );
            """)

            # Insert initial pets only if the table is empty
            cur.execute("SELECT COUNT(*) FROM pets;")
            count = cur.fetchone()[0]

            if count == 0:
                cur.execute("""
                    INSERT INTO pets
                    (name, breed, age, species, status)
                    VALUES
                    ('Bruno', 'Labrador', 2, 'Dog', 'Available'),
                    ('Luna', 'Persian Cat', 1, 'Cat', 'Available'),
                    ('Max', 'Beagle', 3, 'Dog', 'Adopted');
                """)

            conn.commit()

    finally:
        conn.close()


# -----------------------------
# Home
# -----------------------------
@app.route("/")
def home():
    conn = get_connection()

    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, breed, age, species, status
                FROM pets
                ORDER BY id;
            """)

            pets = cur.fetchall()

    finally:
        conn.close()

    return render_template("index.html", pets=pets)


# -----------------------------
# Health Check
# -----------------------------
@app.route("/health")
def health():
    try:
        conn = get_connection()

        with conn.cursor() as cur:
            cur.execute("SELECT 1;")

        conn.close()

        return {
            "status": "healthy",
            "database": "connected"
        }

    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }, 500


# -----------------------------
# Get All Pets
# -----------------------------
@app.route("/pets")
def get_pets():
    conn = get_connection()

    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, breed, age, species, status
                FROM pets
                ORDER BY id;
            """)

            pets = cur.fetchall()

    finally:
        conn.close()

    return {"pets": pets}


# -----------------------------
# Get Single Pet
# -----------------------------
@app.route("/pets/<int:pet_id>")
def get_pet(pet_id):
    conn = get_connection()

    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, breed, age, species, status
                FROM pets
                WHERE id = %s;
            """, (pet_id,))

            pet = cur.fetchone()

    finally:
        conn.close()

    if pet is None:
        return {"error": "Pet not found"}, 404

    return pet


# -----------------------------
# Add Pet
# -----------------------------
@app.route("/pets/add", methods=["POST"])
def add_pet():

    name = request.form["name"]
    breed = request.form["breed"]
    age = int(request.form["age"])
    species = request.form["species"]

    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO pets
                (name, breed, age, species, status)
                VALUES (%s, %s, %s, %s, 'Available');
            """, (name, breed, age, species))

        conn.commit()

    finally:
        conn.close()

    return redirect(url_for("home"))


# -----------------------------
# Adopt Pet
# -----------------------------
@app.route("/pets/<int:pet_id>/adopt", methods=["POST"])
def adopt_pet(pet_id):

    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute("""
                UPDATE pets
                SET status = 'Adopted'
                WHERE id = %s;
            """, (pet_id,))

            if cur.rowcount == 0:
                conn.rollback()
                return {"error": "Pet not found"}, 404

        conn.commit()

    finally:
        conn.close()

    return redirect(url_for("home"))


# -----------------------------
# Start Application
# -----------------------------
if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000)