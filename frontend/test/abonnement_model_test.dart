import 'package:flutter_test/flutter_test.dart';

import 'package:babicash/data/models/abonnement_model.dart';

void main() {
  test('AbonnementOut parse les Decimal sérialisés en chaînes par FastAPI', () {
    // Payload réel du backend : Pydantic v2 sérialise les Decimal en chaînes.
    final abo = AbonnementOut.fromJson({
      'proprietaire_id': 'owner-1',
      'plan': 'PRO',
      'quota_ventes_par_boutique': 2147483647,
      'prix_base': '5000.00',
      'nb_boutiques': 2,
      'prix_total_mensuel': '8750.00',
      'date_fin': '2026-08-15T00:00:00Z',
      'actif': true,
    });

    expect(abo.prixBase, 5000.0);
    expect(abo.prixTotalMensuel, 8750.0);
    expect(abo.dateFin, isNotNull);
    expect(abo.plan, 'PRO');
  });

  test('AbonnementOut tolère les champs optionnels absents (ancien backend)', () {
    final abo = AbonnementOut.fromJson({
      'proprietaire_id': 'owner-1',
      'plan': 'FREE',
      'quota_ventes_par_boutique': 20,
    });

    expect(abo.prixBase, 0.0); // défaut du modèle (FREE = 0 FCFA)
    expect(abo.nbBoutiques, 1);
    expect(abo.dateFin, isNull);
    expect(abo.actif, isTrue);
  });

  test('UpgradePlanRequest sérialise date_fin en snake_case', () {
    final req = UpgradePlanRequest(
      plan: 'PRO',
      dateFin: DateTime.utc(2026, 8, 15),
    );

    final json = req.toJson();
    expect(json.containsKey('date_fin'), isTrue);
    expect(json.containsKey('dateFin'), isFalse);
  });

  test('QuotaInfo parse la réponse quota du backend', () {
    final quota = QuotaInfo.fromJson({
      'boutique_id': 'b1',
      'plan': 'FREE',
      'quota_par_boutique': 20,
      'ventes_ce_mois': 5,
      'ventes_restantes': 15,
      'illimite': false,
    });

    expect(quota.ventesRestantes, 15);
    expect(quota.illimite, isFalse);
  });
}
