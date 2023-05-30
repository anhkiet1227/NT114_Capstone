// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library PriLib {

    // Patient
    struct Patient {
        bool registered;
    }

    struct Document {
        uint256 id;
        bool exists;
        address patient;
        address doctor;
        bytes32 keyHash;
    }

    // Doctor
    struct Doctor {
        bool registered;
    }

    // Manager
    struct Manager {
        bool registered;
    }

    // Audit data _ Manager call
    struct CrosschainManager {
        bool exists;
        address requester;
        bytes32 keyHash;
        uint256 requestTime;
    }
    // Audit data _ Doctor call
    struct GrantCrosschainDoctor {
        bool exists;
        bool granted;
        address requester;
        bytes32 keyHash;
        uint256 requestTime;
        bytes32 vtk;
    }
    // Request data _ Doctor & Patient call
    struct requestData {
        bool exist;
        address requester;
        uint256 requestTime;
        bytes32 keyHash;
    }
}
