import { api } from './client'
import type {
  CodeDisponible,
  Commission,
  Filleul,
  MonEspace,
  Operateur,
  Versement,
} from './types'

const PAGE_SIZE = 50

export const getMonEspace = () => api<MonEspace>('/ambassadeurs/moi')

export const getFilleuls = (offset = 0, limit = PAGE_SIZE) =>
  api<Filleul[]>(`/ambassadeurs/filleuls?limit=${limit}&offset=${offset}`)

export const getCommissions = (offset = 0, limit = PAGE_SIZE) =>
  api<Commission[]>(`/ambassadeurs/commissions?limit=${limit}&offset=${offset}`)

export const getVersements = (offset = 0, limit = PAGE_SIZE) =>
  api<Versement[]>(`/ambassadeurs/versements?limit=${limit}&offset=${offset}`)

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
