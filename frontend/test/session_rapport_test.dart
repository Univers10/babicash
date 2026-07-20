import 'package:flutter_test/flutter_test.dart';
import 'package:babicash/data/local/database.dart';
import 'package:babicash/features/sessions/services/session_rapport_service.dart';

LocalSession _session({
  String id = 'sess-1',
  double montantInitial = 10000,
  double? montantFinalDeclare,
}) {
  return LocalSession(
    id: id,
    boutiqueId: 'btq-1',
    utilisateurNom: 'Awa',
    dateOuverture: DateTime(2026, 7, 18, 8, 0),
    dateFermeture: DateTime(2026, 7, 18, 20, 0),
    montantInitial: montantInitial,
    montantFinalDeclare: montantFinalDeclare,
    statut: 'FERME',
    synced: true,
  );
}

LocalVente _vente({
  required String idLocal,
  String? sessionId = 'sess-1',
  required String modePaiement,
  required double montantTotal,
}) {
  return LocalVente(
    idLocal: idLocal,
    boutiqueId: 'btq-1',
    sessionId: sessionId,
    modePaiement: modePaiement,
    montantTotal: montantTotal,
    dateVente: DateTime(2026, 7, 18, 12, 0),
    synced: true,
  );
}

LocalDepense _depense({
  required String idLocal,
  String? sessionId = 'sess-1',
  required double montant,
}) {
  return LocalDepense(
    idLocal: idLocal,
    boutiqueId: 'btq-1',
    sessionId: sessionId,
    montant: montant,
    motif: 'Achat divers',
    dateTransaction: DateTime(2026, 7, 18, 14, 0),
    synced: true,
  );
}

void main() {
  group('SessionRapport.compute', () {
    test('calcule les totaux par mode de paiement et le total global', () {
      final rapport = SessionRapport.compute(
        session: _session(montantFinalDeclare: 20000),
        ventes: [
          _vente(idLocal: 'v1', modePaiement: 'ESPECES', montantTotal: 5000),
          _vente(idLocal: 'v2', modePaiement: 'ESPECES', montantTotal: 3000),
          _vente(
              idLocal: 'v3', modePaiement: 'MOBILE_MONEY', montantTotal: 2500),
          _vente(idLocal: 'v4', modePaiement: 'CREDIT', montantTotal: 1500),
        ],
        depenses: [
          _depense(idLocal: 'd1', montant: 2000),
        ],
      );

      expect(rapport.nbVentes, 4);
      expect(rapport.totalEspeces, 8000);
      expect(rapport.totalMobile, 2500);
      expect(rapport.totalCredit, 1500);
      expect(rapport.totalVentes, 12000);
      expect(rapport.totalDepenses, 2000);
    });

    test(
        'théorique = fond initial + espèces - dépenses ; '
        'écart = déclaré - théorique', () {
      final rapport = SessionRapport.compute(
        session: _session(montantInitial: 10000, montantFinalDeclare: 15500),
        ventes: [
          _vente(idLocal: 'v1', modePaiement: 'ESPECES', montantTotal: 8000),
          _vente(
              idLocal: 'v2', modePaiement: 'MOBILE_MONEY', montantTotal: 4000),
        ],
        depenses: [
          _depense(idLocal: 'd1', montant: 2000),
        ],
      );

      // 10000 + 8000 (espèces uniquement) - 2000 = 16000
      expect(rapport.montantTheorique, 16000);
      // 15500 - 16000 = -500 (manquant en caisse)
      expect(rapport.ecart, -500);
    });

    test('écart nul quand le fond déclaré égale le théorique', () {
      final rapport = SessionRapport.compute(
        session: _session(montantInitial: 5000, montantFinalDeclare: 9000),
        ventes: [
          _vente(idLocal: 'v1', modePaiement: 'ESPECES', montantTotal: 4000),
        ],
        depenses: [],
      );

      expect(rapport.montantTheorique, 9000);
      expect(rapport.ecart, 0);
    });

    test('écart null si aucun fond final déclaré (session ouverte)', () {
      final rapport = SessionRapport.compute(
        session: _session(montantFinalDeclare: null),
        ventes: [],
        depenses: [],
      );

      expect(rapport.ecart, isNull);
      expect(rapport.montantTheorique, 10000);
    });

    test('ignore les ventes et dépenses des autres sessions', () {
      final rapport = SessionRapport.compute(
        session: _session(montantInitial: 0, montantFinalDeclare: 1000),
        ventes: [
          _vente(idLocal: 'v1', modePaiement: 'ESPECES', montantTotal: 1000),
          _vente(
              idLocal: 'v2',
              sessionId: 'autre-session',
              modePaiement: 'ESPECES',
              montantTotal: 9999),
          _vente(
              idLocal: 'v3',
              sessionId: null,
              modePaiement: 'ESPECES',
              montantTotal: 7777),
        ],
        depenses: [
          _depense(idLocal: 'd1', sessionId: 'autre-session', montant: 5555),
        ],
      );

      expect(rapport.nbVentes, 1);
      expect(rapport.totalVentes, 1000);
      expect(rapport.totalDepenses, 0);
      expect(rapport.montantTheorique, 1000);
      expect(rapport.ecart, 0);
    });
  });

  group('buildRapportLines', () {
    test('génère un ticket 32 colonnes avec totaux et écart', () {
      final rapport = SessionRapport.compute(
        session: _session(montantInitial: 10000, montantFinalDeclare: 15500),
        ventes: [
          _vente(idLocal: 'v1', modePaiement: 'ESPECES', montantTotal: 8000),
        ],
        depenses: [
          _depense(idLocal: 'd1', montant: 2000),
        ],
      );

      final lines = buildRapportLines(rapport, nomBoutique: 'Ma Boutique');

      expect(lines.any((l) => l.contains('Ma Boutique')), isTrue);
      expect(lines.any((l) => l.contains('RAPPORT DE SESSION')), isTrue);
      expect(lines.any((l) => l.contains('Caissier') && l.contains('Awa')),
          isTrue);
      expect(
          lines.any((l) => l.contains('Total ventes') && l.contains('8000 F')),
          isTrue);
      expect(lines.any((l) => l.contains('Depenses') && l.contains('2000 F')),
          isTrue);
      // Théorique : 10000 + 8000 - 2000 = 16000
      expect(
          lines.any(
              (l) => l.contains('Theorique caisse') && l.contains('16000 F')),
          isTrue);
      // Écart : 15500 - 16000 = -500
      expect(lines.any((l) => l.contains('ECART') && l.contains('-500 F')),
          isTrue);
      // Aucune ligne ne dépasse la largeur du papier 58 mm
      for (final line in lines) {
        expect(line.length, lessThanOrEqualTo(32),
            reason: 'Ligne trop longue : "$line"');
      }
    });
  });
}
