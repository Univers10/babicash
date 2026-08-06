export interface Token {
  access_token: string
  token_type: string
  role: string
  boutique_id: string | null
  nom: string | null
  email: string | null
  avatar_url: string | null
}

export type Operateur = 'WAVE' | 'ORANGE' | 'MTN' | 'MOOV'

export interface RegisterPayload {
  nom: string
  email: string
  mot_de_passe: string
  telephone?: string | null
  code: string
  momo_numero: string
  momo_operateur: Operateur
}

export interface MonEspace {
  id: string
  nom: string
  email: string | null
  code: string
  momo_numero: string
  momo_operateur: string
  actif: boolean
  nb_filleuls: number
  nb_filleuls_payants: number
  solde_a_recevoir: number | string
  total_gagne: number | string
}

export interface Filleul {
  filleul_id: string
  nom: string
  plan: string
  abonnement_actif: boolean
  date_inscription: string
  commission_cumulee: number | string
}

export interface Commission {
  id: string
  filleul_nom: string
  montant_paye: number | string
  montant_commission: number | string
  statut: string
  date_creation: string
}

export interface Versement {
  id: string
  semaine: string
  montant_total: number | string
  statut: string
  reference_transfert: string | null
  date_creation: string
  date_execution: string | null
}

export interface CodeDisponible {
  code: string
  disponible: boolean
  raison: string | null
}
