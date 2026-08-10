import { useInstallPrompt } from '../hooks/useInstallPrompt'

/**
 * Bannière « Télécharger l'application » — visible uniquement quand on
 * navigue depuis un navigateur (pas encore installé), Android ou iOS.
 */
export default function InstallBanner() {
  const { canInstall, installed, isIos, install, hide } = useInstallPrompt()

  if (!canInstall || installed) return null

  return (
    <div className="install-banner" role="dialog" aria-label="Installer l'application">
      <div className="install-banner-icon" aria-hidden="true">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
      </div>
      <div className="install-banner-body">
        <div className="install-banner-title">Télécharger l'application</div>
        <div className="install-banner-sub">
          {isIos
            ? "Sur iPhone/iPad : touche Partager puis « Ajouter à l'écran d'accueil »."
            : "Installe l'app BabiCash pour un accès plus rapide."}
        </div>
      </div>
      <div className="install-banner-actions">
        {!isIos && (
          <button className="btn btn--primary btn--sm" onClick={install}>
            Installer
          </button>
        )}
        <button
          className="btn btn--ghost install-banner-close"
          onClick={hide}
          aria-label="Fermer"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>
    </div>
  )
}
