import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../data/models/abonnement_model.dart';

/// Numéro WhatsApp BabiCash (format international sans '+').
const kWhatsAppNumber = '2250555745936';

/// Définition d'un plan d'abonnement (catalogue de présentation, côté client).
class PlanDef {
  const PlanDef({
    required this.id,
    required this.nom,
    required this.tagline,
    required this.prixMensuel,
    required this.icon,
    required this.features,
    this.populaire = false,
  });

  final String id;
  final String nom;
  final String tagline;
  final double prixMensuel;
  final IconData icon;
  final List<String> features;
  final bool populaire;

  bool get gratuit => prixMensuel == 0;

  /// Prix annuel : 2 mois offerts.
  double get prixAnnuel => prixMensuel * 10;

  /// Prix annuel sans remise (affiché barré).
  double get prixAnnuelBarre => prixMensuel * 12;
}

const kPlansCatalog = [
  PlanDef(
    id: 'FREE',
    nom: 'Gratuit',
    tagline: 'Pour découvrir BabiCash',
    prixMensuel: 0,
    icon: Symbols.storefront,
    features: [
      '20 ventes par mois',
      '1 boutique',
      '1 gérant',
      'Gestion de stock de base',
      'Historique des ventes',
      'Mode hors-ligne complet',
    ],
  ),
  PlanDef(
    id: 'KIOSQUE',
    nom: 'Kiosque',
    tagline: 'Pour les petits commerces',
    prixMensuel: 2000,
    icon: Symbols.store,
    features: [
      '200 ventes par mois',
      '1 boutique',
      '1 gérant',
      'Stock et catégories illimités',
      'Crédit clients',
      'Support WhatsApp',
    ],
  ),
  PlanDef(
    id: 'BOUTIQUE',
    nom: 'Boutique',
    tagline: 'Le choix des commerçants sérieux',
    prixMensuel: 5000,
    icon: Symbols.workspace_premium,
    populaire: true,
    features: [
      'Ventes illimitées',
      '1 boutique',
      'Jusqu\'à 3 gérants',
      'Crédit clients et fournisseurs',
      'Reçus PDF et impression thermique',
      'Tableau de bord complet',
      'Support prioritaire WhatsApp',
    ],
  ),
  PlanDef(
    id: 'COMMERCE',
    nom: 'Commerce',
    tagline: 'Pour plusieurs points de vente',
    prixMensuel: 10000,
    icon: Symbols.domain,
    features: [
      'Ventes illimitées',
      'Jusqu\'à 3 boutiques',
      'Jusqu\'à 6 gérants',
      'Dashboard consolidé multi-boutiques',
      'Reçus PDF et impression thermique',
      'Support prioritaire',
    ],
  ),
  PlanDef(
    id: 'ENTREPRISE',
    nom: 'Entreprise',
    tagline: 'Pour les réseaux en croissance',
    prixMensuel: 15000,
    icon: Symbols.corporate_fare,
    features: [
      'Ventes illimitées',
      'Jusqu\'à 6 boutiques',
      'Jusqu\'à 12 gérants',
      'Dashboard consolidé et rapports avancés',
      'Accompagnement à l\'installation',
      'Support prioritaire 7j/7',
    ],
  ),
  PlanDef(
    id: 'EMPIRE',
    nom: 'Empire',
    tagline: 'Aucune limite, que de la croissance',
    prixMensuel: 20000,
    icon: Symbols.crown,
    features: [
      'Ventes illimitées',
      'Boutiques illimitées',
      'Gérants illimités',
      'Dashboard consolidé et rapports avancés',
      'Formation de votre équipe offerte',
      'Ligne de support dédiée',
    ],
  ),
];

/// Retrouve la carte du catalogue correspondant à l'abonnement backend.
///
/// Le backend ne connaît aujourd'hui que 'FREE' et 'PRO' ; un plan 'PRO'
/// est rattaché à la carte payante dont le prix correspond à [AbonnementOut.prixBase]
/// (Boutique par défaut). Les codes futurs ('KIOSQUE', 'EMPIRE', …) matchent par id.
PlanDef? planFromAbonnement(AbonnementOut abonnement) {
  final code = abonnement.plan.trim().toUpperCase();
  if (code == 'PRO') {
    return kPlansCatalog.firstWhere(
      (p) => p.prixMensuel > 0 && p.prixMensuel == abonnement.prixBase,
      orElse: () =>
          kPlansCatalog.firstWhere((p) => p.id == 'BOUTIQUE'),
    );
  }
  for (final plan in kPlansCatalog) {
    if (plan.id == code) return plan;
  }
  if (code == 'FREE') {
    return kPlansCatalog.first;
  }
  return null;
}
