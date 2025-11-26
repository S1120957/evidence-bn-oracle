from typing import Dict, Tuple

from pgmpy.models import BayesianModel
from pgmpy.factors.discrete import TabularCPD
from pgmpy.inference import VariableElimination


class BNOracle:
    """
    Simple 2-latent-node BN:

        PPH, PPR are binary parents
        GPS, PC, PMD, PR are binary children with CPTs P(child=1 | PPH, PPR)

    priors: {"PPH": float, "PPR": float}
    cpts: {
        "GPS": {(pph, ppr): p_true, ...},
        "PC":  {...},
        "PMD": {...},
        "PR":  {...},
    }
    """

    def __init__(self, priors: Dict[str, float], cpts: Dict[str, Dict[Tuple[int, int], float]]) -> None:
        self.model = BayesianModel(
            [
                ("PPH", "GPS"),
                ("PPR", "GPS"),
                ("PPH", "PC"),
                ("PPR", "PC"),
                ("PPH", "PMD"),
                ("PPR", "PMD"),
                ("PPH", "PR"),
                ("PPR", "PR"),
            ]
        )
        self._build_cpds(priors, cpts)
        self._engine = VariableElimination(self.model)

    def _build_cpds(self, priors, cpts) -> None:
        p_pph = priors["PPH"]
        p_ppr = priors["PPR"]

        cpd_pph = TabularCPD("PPH", 2, [[1 - p_pph], [p_pph]])
        cpd_ppr = TabularCPD("PPR", 2, [[1 - p_ppr], [p_ppr]])

        def evidence_cpd(name: str) -> TabularCPD:
            # Order of parent configs in pgmpy: PPH (0,1) x PPR (0,1)
            vals = []
            for pph_state in (0, 1):
                for ppr_state in (0, 1):
                    p_true = cpts[name][(pph_state, ppr_state)]
                    p_false = 1.0 - p_true
                    vals.append([p_false, p_true])

            # vals = [[P(e=0|p), P(e=1|p)] for each parent config]
            # we need a 2 x 4 matrix: rows = states (0,1), cols = parent configs
            row0 = [v[0] for v in vals]
            row1 = [v[1] for v in vals]

            return TabularCPD(
                variable=name,
                variable_card=2,
                values=[row0, row1],
                evidence=["PPH", "PPR"],
                evidence_card=[2, 2],
            )

        cpd_gps = evidence_cpd("GPS")
        cpd_pc = evidence_cpd("PC")
        cpd_pmd = evidence_cpd("PMD")
        cpd_pr = evidence_cpd("PR")

        self.model.add_cpds(cpd_pph, cpd_ppr, cpd_gps, cpd_pc, cpd_pmd, cpd_pr)
        self.model.check_model()

    def infer(self, evidence: Dict[str, bool]) -> Dict[str, float]:
        """
        evidence: e.g. {"GPS": True, "PC": False, "PMD": True, "PR": False}
        Returns P(PPH=1 | evidence), P(PPR=1 | evidence).
        """
        q_pph = self._engine.query(variables=["PPH"], evidence=evidence)
        q_ppr = self._engine.query(variables=["PPR"], evidence=evidence)
        return {
            "PPH": float(q_pph.values[1]),
            "PPR": float(q_ppr.values[1]),
        }
