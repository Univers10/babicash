"""Service ambassadeurs / parrainage : validation, disponibilité, rattachement."""
import re
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Ambassadeur, User

# Un code = 4 à 20 caractères, lettres majuscules et chiffres uniquement.
_CODE_RE = re.compile(r"^[A-Z0-9]{4,20}$")

# Codes réservés, refusés au choix. Comparaison en correspondance EXACTE
# (pas en sous-chaîne) pour éviter les faux positifs de type « Scunthorpe »
# (ex. FALCON contient CON). Tenir cette liste à jour au fil des besoins.
_BLACKLIST = {
    # Marque & produit
    "BABICASH", "BABI", "CASH", "BABICACH", "BABYCASH", "POS", "CAISSE",
    # Noms de plans (éviter la confusion avec l'offre)
    "FREE", "KIOSQUE", "BOUTIQUE", "COMMERCE", "ENTREPRISE", "EMPIRE",
    # Rôles & mots système
    "ADMIN", "ADMINISTRATEUR", "SUPPORT", "OWNER", "MANAGER", "GERANT",
    "AMBASSADEUR", "AMBASSADOR", "ROOT", "SYSTEM", "SYSTEME", "STAFF",
    "MODERATEUR", "MODERATOR", "OFFICIEL", "OFFICIAL", "NULL", "UNDEFINED",
    "TEST", "DEMO", "EXAMPLE", "EXEMPLE", "HELP", "AIDE", "INFO", "CONTACT",
    # Fintech / Mobile Money / paiement (éviter l'usurpation)
    "WAVE", "ORANGE", "ORANGEMONEY", "OM", "MTN", "MTNMONEY", "MOMO", "MOOV",
    "MOOVMONEY", "FLOOZ", "DJAMO", "CINETPAY", "PAYSTACK", "STRIPE", "PAYPAL",
    "VISA", "MASTERCARD", "BANK", "BANQUE", "MONEY", "ARGENT",
    # Confiance / autorité (usurpation)
    "SECURITE", "SECURITY", "POLICE", "GOUV", "GOUVERNEMENT", "ETAT", "IMPOT",
    "DOUANE", "URGENCE", "VERIFIE", "VERIFIED", "CERTIFIE",
    # Arnaque
    "ARNAQUE", "SCAM", "ESCROC", "FRAUDE", "FRAUD", "HACK", "PHISHING",
    # Grossièretés FR / nouchi
    "CON", "CONNARD", "CONNASSE", "PUTE", "PUTAIN", "PUTIN", "MERDE", "SALOPE",
    "SALAUD", "ENCULE", "ENCULER", "NIQUE", "NIQUER", "NIK", "NIKTAMER",
    "FDP", "PD", "PEDE", "BATARD", "BATAR", "CHIER", "BITE", "COUILLE",
    "ZIZI", "SEXE", "SEX", "CHATTE", "TAPETTE", "GADO",
    # Grossièretés EN
    "FUCK", "FUCKER", "FUCKING", "SHIT", "BITCH", "ASSHOLE", "DICK", "CUNT",
    "PUSSY", "PORN", "PORNO", "XXX", "SLUT", "WHORE",
    # Haine / interdits
    "NIGGER", "NIGGA", "NAZI", "HITLER", "ISIS", "KKK", "RACISTE",
}


def normaliser_code(code: str) -> str:
    """Normalise un code saisi : sans espaces, en majuscules."""
    return code.strip().upper()


def valider_format_code(code: str) -> str | None:
    """Valide un code déjà normalisé.

    Retourne un code de raison si invalide (``"format"`` ou ``"reserve"``),
    ou ``None`` si le code est acceptable.
    """
    if not _CODE_RE.match(code):
        return "format"
    if code in _BLACKLIST:
        return "reserve"
    return None


async def code_existe(db: AsyncSession, code: str) -> bool:
    """Indique si un code (déjà normalisé) est déjà utilisé."""
    row = (
        await db.execute(select(Ambassadeur.id).where(Ambassadeur.code == code))
    ).scalar_one_or_none()
    return row is not None


async def code_disponible(db: AsyncSession, code_brut: str) -> tuple[bool, str | None]:
    """Vérifie qu'un code est disponible.

    Retourne ``(disponible, raison)`` où ``raison`` vaut ``"format"``,
    ``"reserve"``, ``"pris"`` en cas d'indisponibilité, sinon ``None``.
    """
    code = normaliser_code(code_brut)
    raison = valider_format_code(code)
    if raison is not None:
        return False, raison
    if await code_existe(db, code):
        return False, "pris"
    return True, None


async def resoudre_parrain(
    db: AsyncSession,
    code_brut: str,
    *,
    email: str | None = None,
    telephone: str | None = None,
) -> uuid.UUID | None:
    """Résout un code de parrainage vers l'``id`` de l'ambassadeur à créditer.

    Retourne ``None`` (rattachement ignoré, l'inscription se poursuit) si :
    - le code est vide / mal formé / réservé ;
    - aucun ambassadeur **actif** ne porte ce code ;
    - auto-parrainage détecté (le filleul partage email, téléphone ou numéro
      Mobile Money avec l'ambassadeur).
    """
    if not code_brut:
        return None

    code = normaliser_code(code_brut)
    if valider_format_code(code) is not None:
        return None

    amb = (
        await db.execute(
            select(Ambassadeur).where(
                Ambassadeur.code == code, Ambassadeur.actif.is_(True)
            )
        )
    ).scalar_one_or_none()
    if amb is None:
        return None

    # Anti auto-parrainage : le filleul ne peut pas être l'ambassadeur lui-même.
    parrain = await db.get(User, amb.user_id)
    if parrain is not None:
        if email and parrain.email and parrain.email == email:
            return None
        if telephone and parrain.telephone and parrain.telephone == telephone:
            return None
    if telephone and amb.momo_numero and amb.momo_numero == telephone:
        return None

    return amb.id
