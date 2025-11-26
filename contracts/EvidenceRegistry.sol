// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IEvidenceRegistry {
    function logEvidence(
        address caller,
        uint8 gps,
        uint8 pc,
        uint8 pmd,
        uint8 pr,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    ) external returns (uint256);
}

/// @title EvidenceRegistry
/// @notice Stores evidence + posterior pairs for audit/experiments
contract EvidenceRegistry is IEvidenceRegistry {
    struct EvidenceRecord {
        address caller;
        uint8 gps;
        uint8 pc;
        uint8 pmd;
        uint8 pr;
        uint256 posteriorPPH;
        uint256 posteriorPPR;
        uint256 timestamp;
    }

    EvidenceRecord[] private records;

    event EvidenceLogged(
        uint256 indexed evidenceId,
        address indexed caller,
        uint8 gps,
        uint8 pc,
        uint8 pmd,
        uint8 pr,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    );

    function logEvidence(
        address caller,
        uint8 gps,
        uint8 pc,
        uint8 pmd,
        uint8 pr,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    ) external override returns (uint256) {
        records.push(
            EvidenceRecord({
                caller: caller,
                gps: gps,
                pc: pc,
                pmd: pmd,
                pr: pr,
                posteriorPPH: posteriorPPH,
                posteriorPPR: posteriorPPR,
                timestamp: block.timestamp
            })
        );
        uint256 id = records.length - 1;
        emit EvidenceLogged(id, caller, gps, pc, pmd, pr, posteriorPPH, posteriorPPR);
        return id;
    }

    function getEvidence(uint256 id)
        external
        view
        returns (
            uint8 gps,
            uint8 pc,
            uint8 pmd,
            uint8 pr,
            uint256 posteriorPPH,
            uint256 posteriorPPR
        )
    {
        EvidenceRecord storage e = records[id];
        return (e.gps, e.pc, e.pmd, e.pr, e.posteriorPPH, e.posteriorPPR);
    }

    function evidenceCount() external view returns (uint256) {
        return records.length;
    }
}
