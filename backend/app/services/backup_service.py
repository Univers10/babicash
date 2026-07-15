"""Gestion des backups PostgreSQL pour l'admin."""
import gzip
import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

BACKUP_DIR = Path(os.environ.get("BACKUP_DIR", "/backups"))
KEEP_DEFAULT = 30


def lister_backups() -> list[dict]:
    """Liste tous les backups disponibles."""
    backups = []
    for f in sorted(BACKUP_DIR.glob("babicash_*.sql.gz"), reverse=True):
        stat = f.stat()
        backups.append({
            "nom": f.name,
            "chemin": str(f),
            "taille": _format_taille(stat.st_size),
            "taille_octets": stat.st_size,
            "date": datetime.fromtimestamp(stat.st_mtime).strftime("%d/%m/%Y %H:%M"),
        })
    return backups


def creer_backup(keep: int = KEEP_DEFAULT) -> dict:
    """Crée un backup de la base de données."""
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"babicash_{timestamp}.sql.gz"
    filepath = BACKUP_DIR / filename

    env = os.environ.copy()

    proc = subprocess.run(
        [
            "pg_dump",
            f"--host={env.get('POSTGRES_HOST', 'db')}",
            f"--port={env.get('POSTGRES_PORT', '5432')}",
            f"--username={env.get('POSTGRES_USER', 'babicash')}",
            f"--dbname={env.get('POSTGRES_DB', 'babicash')}",
            "--no-password",
            "--format=plain",
        ],
        capture_output=True,
        env=env,
    )

    if proc.returncode != 0:
        raise RuntimeError(f"pg_dump échoué : {proc.stderr.decode()}")

    with gzip.open(filepath, "wb") as f:
        f.write(proc.stdout)

    # Rotation
    _rotation(keep)

    taille = filepath.stat().st_size
    return {
        "nom": filename,
        "taille": _format_taille(taille),
        "date": datetime.now().strftime("%d/%m/%Y %H:%M"),
    }


def restaurer_backup(nom_fichier: str) -> None:
    """Restaure un backup."""
    filepath = BACKUP_DIR / nom_fichier
    if not filepath.exists():
        raise FileNotFoundError(f"Backup non trouvé : {nom_fichier}")

    env = os.environ.copy()

    # Supprimer le schéma existant
    subprocess.run(
        [
            "psql",
            f"--host={env.get('POSTGRES_HOST', 'db')}",
            f"--port={env.get('POSTGRES_PORT', '5432')}",
            f"--username={env.get('POSTGRES_USER', 'babicash')}",
            f"--dbname={env.get('POSTGRES_DB', 'babicash')}",
            "--no-password",
            "-c", "DROP SCHEMA public CASCADE; CREATE SCHEMA public;",
        ],
        check=True,
        env=env,
    )

    # Restaurer
    with gzip.open(filepath, "rb") as f:
        proc = subprocess.run(
            [
                "psql",
                f"--host={env.get('POSTGRES_HOST', 'db')}",
                f"--port={env.get('POSTGRES_PORT', '5432')}",
                f"--username={env.get('POSTGRES_USER', 'babicash')}",
                f"--dbname={env.get('POSTGRES_DB', 'babicash')}",
                "--no-password",
                "--quiet",
            ],
            input=f.read(),
            env=env,
        )

    if proc.returncode != 0:
        raise RuntimeError(f"Restauration échouée : {proc.stderr.decode()}")


def supprimer_backup(nom_fichier: str) -> None:
    """Supprime un backup."""
    filepath = BACKUP_DIR / nom_fichier
    if filepath.exists():
        filepath.unlink()


def _rotation(keep: int) -> None:
    """Supprime les anciens backups au-delà de la limite."""
    backups = sorted(BACKUP_DIR.glob("babicash_*.sql.gz"), key=lambda f: f.stat().st_mtime)
    if len(backups) > keep:
        for f in backups[: len(backups) - keep]:
            f.unlink()


def _format_taille(octets: int) -> str:
    """Formate une taille en octets."""
    for unit in ("o", "Ko", "Mo", "Go"):
        if octets < 1024:
            return f"{octets:.1f} {unit}"
        octets /= 1024
    return f"{octets:.1f} To"
