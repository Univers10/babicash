import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useEffect, type ReactNode } from 'react'

/**
 * Conditions Générales d'Utilisation — Espace Ambassadeur BabiCash.
 *
 * Page publique (accessible avant connexion) qui régit l'utilisation du
 * programme de parrainage. Document de référence : « CGU » opposable à toute
 * personne créant un compte ambassadeur ou utilisant la PWA.
 */

function BackBtn() {
  const navigate = useNavigate()
  const location = useLocation()
  return (
    <button
      className="btn btn--ghost back-btn"
      onClick={() => (location.key === 'default' ? navigate('/login') : navigate(-1))}
    >
      ← Retour
    </button>
  )
}

function Section({ num, title, children }: { num: string; title: string; children: ReactNode }) {
  return (
    <section className="cgu-section">
      <h2>
        <span className="cgu-num">{num}</span> {title}
      </h2>
      <div className="cgu-body">{children}</div>
    </section>
  )
}

export default function TermsScreen() {
  useEffect(() => {
    window.scrollTo(0, 0)
  }, [])

  return (
    <div className="app-shell">
      <div className="screen screen--legal">
        <div className="topbar">
          <h1>Conditions d'utilisation</h1>
          <BackBtn />
        </div>

        <div className="cgu-meta">
          <p className="cgu-intro">
            Les présentes Conditions Générales d'Utilisation (« CGU ») régissent l'accès et
            l'utilisation de l'Espace Ambassadeur BabiCash (l'« Application »), édité par
            <strong> Univers10</strong>, ainsi que la participation au programme de parrainage
            et le versement des commissions.
          </p>
          <p className="cgu-intro">
            En créant un compte ambassadeur, en t'inscrivant ou en utilisant l'Application, tu
            acceptes sans réserve l'ensemble des présentes CGU.
          </p>
          <p className="cgu-date">Version du 10 août 2026</p>
        </div>

        <Section num="1" title="Objet">
          <p>
            L'Application permet à toute personne physique volontaire (l'« Ambassadeur ») de
            promouvoir BabiCash, solution de gestion de caisse et de boutique (l'« Offre »), via
            un code de parrainage personnel. L'Ambassadeur perçoit une commission calculée sur
            les abonnements payants souscrits par les commerçants qu'il parraine (les
            « Filleuls »), dans les conditions décrites ci-dessous.
          </p>
        </Section>

        <Section num="2" title="Acceptation des conditions">
          <p>L'accès à l'Application implique l'acceptation pleine et entière des présentes CGU.</p>
          <ul>
            <li>
              Si tu n'acceptes pas ces CGU, tu ne dois pas créer de compte ni utiliser
              l'Application.
            </li>
            <li>
              L'inscription en tant qu'Ambassadeur est volontaire et ouverte à toute personne
              majeure capable. Tu garantis l'exactitude des informations fournies lors de
              l'inscription.
            </li>
            <li>
              L'éditeur peut modifier ces CGU à tout moment. Les modifications prennent effet
              dès leur publication dans l'Application ; la poursuite de l'utilisation vaut
              acceptation des CGU modifiées.
            </li>
          </ul>
        </Section>

        <Section num="3" title="Création du compte ambassadeur">
          <p>
            Pour devenir Ambassadeur, tu fournis un nom, une adresse email valide, un mot de
            passe, un numéro et un opérateur Mobile Money (WAVE, ORANGE, MTN ou MOOV) pour le
            versement de tes commissions.
          </p>
          <ul>
            <li>
              Tu es responsable de la confidentialité de tes identifiants. Toute utilisation de
              ton compte est réputée faite par toi.
            </li>
            <li>
              Tu t'engages à fournir des informations exactes, à jour et complètes, et à les
              actualiser (notamment ton numéro Mobile Money).
            </li>
            <li>
              Un seul compte ambassadeur est autorisé par personne. La création de comptes
              multiples ou fictifs peut entraîner la suspension de tes droits.
            </li>
          </ul>
        </Section>

        <Section num="4" title="Code de parrainage">
          <ul>
            <li>
              Le code de parrainage est choisi par l'Ambassadeur (4 à 20 caractères
              alphanumériques), sous réserve de disponibilité et de non-appartenance à la liste
              noire des codes réservés.
            </li>
            <li>
              Le code est personnel et non transférable. Tu ne peux pas utiliser ton propre code
              pour parrainer un compte que tu contrôles (auto-parrainage interdit).
            </li>
            <li>
              Un commerçant qui s'inscrit avec ton code est rattaché définitivement à ton compte
              en tant que Filleul ; ce rattachement ne peut pas être modifié ni transféré.
            </li>
            <li>
              L'éditeur se réserve le droit de désactiver un code en cas de fraude, d'abus ou de
              violation des présentes CGU, sans préjudice pour les Filleuls déjà rattachés.
            </li>
          </ul>
        </Section>

        <Section num="5" title="Commissions">
          <ul>
            <li>
              L'Ambassadeur perçoit une commission de <strong>20 %</strong> du montant
              effectivement payé par chaque Filleul pour un abonnement payant (hors formule
              gratuite), pendant une durée maximale de <strong>12 mois</strong> à compter du
              premier paiement du Filleul.
            </li>
            <li>
              La commission n'est due que sur les paiements réellement reçus et confirmés par
              l'éditeur. Aucune commission n'est due sur les inscriptions, essais gratuits,
              crédits, remises ou paiements annulés ou non confirmés.
            </li>
            <li>
              La commission apparaît sur le compte de l'Ambassadeur après confirmation du
              paiement du Filleul et peut être ajustée ou annulée si le paiement sous-jacent est
              annulé ou recrédité.
            </li>
          </ul>
        </Section>

        <Section num="6" title="Versement des commissions">
          <ul>
            <li>
              Les commissions sont versées chaque semaine, par Mobile Money, au numéro et à
              l'opérateur enregistrés sur le compte de l'Ambassadeur.
            </li>
            <li>
              Le versement est effectué une fois les commissions confirmées et après application
              éventuelle d'un seuil minimum de versement. Les commissions inférieures au seuil
              sont reportées au versement suivant.
            </li>
            <li>
              L'Ambassadeur s'assure que son numéro Mobile Money est valide et correctement
              renseigné. L'éditeur ne peut être tenu responsable d'un versement effectué sur un
              numéro erroné fourni par l'Ambassadeur.
            </li>
            <li>
              <strong>Vérification d'identité selon le niveau de commissions</strong> : tout
              compte ambassadeur dont le cumul de commissions atteint ou dépasse{' '}
              <strong>200 000 FCFA sur un mois</strong> doit, pour continuer à recevoir ses
              versements, fournir un justificatif d'identité en cours de validité (pièce
              d'identité nationale, passeport ou permis de conduire) ainsi que, le cas échéant,
              une pièce confirmant que le numéro de versement lui appartient (attestation de
              ligne, relevé ou carte SIM à son nom).
            </li>
            <li>
              <strong>Plafond de versement d'un compte non validé</strong> : tant que la
              vérification d'identité n'a pas été effectuée, le montant total des versements à
              un compte ambassadeur est limité à <strong>200 000 FCFA par mois</strong>. Au-delà
              de ce plafond, les commissions sont conservées sur le compte et versées une fois
              le compte validé.
            </li>
            <li>
              <strong>Changement du numéro de reversement</strong> : tout changement du numéro
              Mobile Money de reversement est soumis à une vérification d'identité. L'Ambassadeur
              doit fournir un justificatif d'identité en cours de validité ainsi que, le cas
              échéant, une pièce confirmant que le nouveau numéro lui appartient. Le changement
              n'est effectif qu'après validation du justificatif par l'éditeur.
            </li>
            <li>
              En attendant la validation du justificatif, les commissions continuent d'être
              versées sur le numéro précédemment enregistré ; leur versement peut être
              temporairement suspendu si le justificatif est manquant ou invalide.
            </li>
            <li>
              En cas de fraude, de manoeuvre abusive ou de violation des présentes CGU,
              l'éditeur peut suspendre le versement des commissions, les annuler ou les
              réclamer, selon le cas.
            </li>
          </ul>
        </Section>

        <Section num="7" title="Conduite de l'Ambassadeur">
          <p>L'Ambassadeur s'engage à :</p>
          <ul>
            <li>promouvoir BabiCash de manière loyale, honnête et conforme à la réglementation ;</li>
            <li>ne pas faire de promesses, garanties ou présentations mensongères sur l'Offre ;</li>
            <li>ne pas utiliser de procédés de spam, de publicité non sollicitée ou de moyens frauduleux ;</li>
            <li>ne pas créer de Filleuls fictifs ni simuler des paiements pour générer des commissions ;</li>
            <li>ne pas s'autoparrainer, ni parrainer un compte qu'il contrôle directement ou indirectement ;</li>
            <li>respecter les droits de propriété intellectuelle de l'éditeur.</li>
          </ul>
        </Section>

        <Section num="8" title="Propriété intellectuelle">
          <p>
            L'Application, la marque BabiCash, les textes, graphismes, logos, icônes et tout
            contenu affiché sont la propriété exclusive d'Univers10 ou de ses ayants droit.
            Aucun droit n'est accordé à l'Ambassadeur, hormis un droit d'usage strictement
            personnel et non exclusif de l'Application.
          </p>
        </Section>

        <Section num="9" title="Données personnelles">
          <ul>
            <li>
              Les données collectées (nom, email, téléphone, numéro Mobile Money, code de
              parrainage, données d'activité) sont utilisées pour la gestion du compte, le
              calcul et le versement des commissions, la relation client et l'amélioration du
              service.
            </li>
            <li>
              Le justificatif d'identité exigé pour tout changement du numéro de reversement est
              collecté dans le seul but de vérifier l'identité de l'Ambassadeur et de prévenir
              les détournements de fonds. Il est conservé de manière confidentielle, traité
              avec des mesures de sécurité renforcées et supprimé une fois la vérification
              terminée et les délais légaux expirés.
            </li>
            <li>
              Les données sont traitées conformément à la réglementation applicable en matière
              de protection des données personnelles. Tu disposes d'un droit d'accès, de
              rectification et de suppression de tes données en écrivant à{' '}
              <a href="mailto:support@babicash.ci">support@babicash.ci</a>.
            </li>
            <li>
              Les informations des Filleuls visibles depuis l'Application sont strictement
              limitées (nom, plan, statut, dates). Tu t'engages à ne pas les utiliser à des fins
              autres que le suivi de ton activité de parrainage.
            </li>
          </ul>
        </Section>

        <Section num="10" title="Responsabilité">
          <ul>
            <li>
              L'Application est fournie « en l'état », sans garantie d'aucune sorte. L'éditeur
              s'efforce d'assurer la disponibilité et l'exactitude des informations mais ne peut
              garantir l'absence d'interruption ou d'erreur.
            </li>
            <li>
              Les montants affichés (commissions, soldes, versements) sont fournis à titre
              indicatif ; la source de vérité demeure la comptabilité de l'éditeur issue des
              paiements confirmés.
            </li>
            <li>
              L'éditeur ne saurait être tenu responsable des dommages indirects, de la perte de
              gains ou de toute conséquence liée à l'utilisation de l'Application ou au
              programme de parrainage.
            </li>
          </ul>
        </Section>

        <Section num="11" title="Suspension et résiliation">
          <ul>
            <li>
              L'éditeur peut suspendre ou clôturer un compte ambassadeur, de façon temporaire ou
              définitive, en cas de violation des présentes CGU, de fraude ou de comportement
              nuisible à la plateforme ou à ses utilisateurs.
            </li>
            <li>
              L'Ambassadeur peut cesser d'utiliser l'Application à tout moment. Les commissions
              légitimement acquises et confirmées avant la clôture du compte restent dues, sous
              réserve de leur conformité aux présentes CGU.
            </li>
            <li>
              La clôture du compte ne met pas fin au rattachement des Filleuls déjà inscrits, ni
              à leurs abonnements.
            </li>
          </ul>
        </Section>

        <Section num="12" title="Droit applicable et litiges">
          <p>
            Les présentes CGU sont soumises au droit ivoirien. En cas de litige, les parties
            s'efforceront de trouver une solution amiable. À défaut, le litige sera porté devant
            les juridictions compétentes de Côte d'Ivoire.
          </p>
        </Section>

        <Section num="13" title="Contact">
          <p>
            Pour toute question relative aux présentes CGU, au programme de parrainage ou au
            traitement de tes données, contacte-nous à{' '}
            <a href="mailto:support@babicash.ci">support@babicash.ci</a>.
          </p>
        </Section>

        <div className="cgu-end">
          <Link className="link" to="/register">
            ← Retour à l'inscription
          </Link>
        </div>
      </div>
    </div>
  )
}
