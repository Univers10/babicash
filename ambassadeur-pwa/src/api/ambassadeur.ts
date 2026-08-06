import { api } from './client'
import type {
  CodeDisponible,
  Commission,
  Filleul,
  MonEspace,
  Operateur,
  Versement,
} from './types'

export const getMonEspace = () => api<MonEspace>('/ambassadeurs/moi')

export const getFilleuls = () => api<Filleul[]>('/ambassadeurs/filleuls')

export const getCommissions = () => api<Commission[]>('/ambassadeurs/commissions')

export const getVersements = () => api<Versement[]>('/ambassadeurs/versements')

export const checkCode = (code: string) =>
  api<CodeDisponible>(
    `/ambassadeurs/code-disponible?code=${encodeURIComponent(code)}`,
    { auth: false },
  )

export const updateMomo = (momo_numero: string, momo_operateur: Operateur) =>
  api<MonEspace>('/ambassadeurs/moi', {
    method: 'PATCH',
    body: { momo_numero, momo_operateur },
  })
