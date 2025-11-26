// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./CPTStore.sol";
import "./EvidenceRegistry.sol";

/// @title OracleController
/// @notice Thin on-chain controller front-end for the off-chain BN oracle
contract OracleController {
    CPTStore public cptStore;
    EvidenceRegistry public evidenceRegistry;

    uint256 public lastEvidenceId;

    event InferenceSubmitted(
        uint256 indexed evidenceId,
        address indexed caller,
        uint8 gps,
        uint8 pc,
        uint8 pmd,
        uint8 pr,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    );

    constructor(address _cptStore, address _evidenceRegistry) {
        cptStore = CPTStore(_cptStore);
        evidenceRegistry = EvidenceRegistry(_evidenceRegistry);
    }

    function submitInference(
        uint8 gps,
        uint8 pc,
        uint8 pmd,
        uint8 pr,
        uint256 posteriorPPH,
        uint256 posteriorPPR
    ) external {
        // Off-chain BN already produced the posterior; we just log it.
        uint256 id = evidenceRegistry.logEvidence(
            msg.sender,
            gps,
            pc,
            pmd,
            pr,
            posteriorPPH,
            posteriorPPR
        );

        lastEvidenceId = id;

        emit InferenceSubmitted(
            id,
            msg.sender,
            gps,
            pc,
            pmd,
            pr,
            posteriorPPH,
            posteriorPPR
        );
    }
}
