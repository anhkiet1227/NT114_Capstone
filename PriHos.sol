// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriLib.sol";
import "./crosschain/crosschain.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PriHos {
    // Define Variable
    address public hospital;
    mapping(address => PriLib.Patient) public patients;
    mapping(address => PriLib.Doctor) public doctors;
    mapping(address => PriLib.Manager) public managers;
    mapping(bytes32 => PriLib.Document) public documents;
    mapping(uint256 => PriLib.CrosschainManager) public requestManagers;
    mapping(uint256 => PriLib.GrantCrosschainDoctor) public requestDoctors;
    mapping(uint256 => PriLib.requestData) public requestNormals;
    uint256 requestsCount;
    uint256 docsCount; 
    string public docRequestID;

    // Modifier
    modifier onlyHospital {
        require(
            msg.sender == hospital,
            "Only regulatory agency smart contract hospital can call this function"
        );
        _;
    }

    modifier notHospital {
        require(
            msg.sender != hospital,
            "Regulatory agency smart contract hospital cannot call this function"
        );
        _;
    }

    modifier onlyPatient {
        require(
            patients[msg.sender].registered,
            "Only a patient can call this function"
        );
        _;
    }

    modifier onlyDoctor {
        require(
            doctors[msg.sender].registered,
            "Only a doctor can call this function"
        );
        _;
    }
    modifier onlyManager {
        require(managers[msg.sender].registered,
            "Only a manager can call this function"
        );
        _;
    }

    // Constructor
    constructor() {
        hospital = msg.sender;
        requestsCount = 0;
        docsCount = 0;
    }

    // Register
    function registerPatient(address patient) public onlyHospital {
        require(!patients[patient].registered && !doctors[patient].registered &&
                !managers[patient].registered, "Address is already registered");
        patients[patient].registered = true;
    }

    function registerDoctor(address doctor) public onlyHospital {
        require(!patients[doctor].registered && !doctors[doctor].registered &&
                !managers[doctor].registered, "Address is already registered");
        doctors[doctor].registered = true;
    }

    function registerManager(address manager) public onlyHospital {
        require(!patients[manager].registered && !doctors[manager].registered &&
                !managers[manager].registered, "Address is already registered");
        managers[manager].registered = true;
    }

    // Hospital Function
    event normalRequest(uint256 requestId);

    function requestNormal(bytes32 keyhash) public onlyDoctor onlyPatient {
        require(documents[keyhash].patient == msg.sender || documents[keyhash].doctor == msg.sender,
            "Only participants of the document can call this function"
        );
        requestNormals[requestsCount].exist = true;
        requestNormals[requestsCount].requester = msg.sender;
        requestNormals[requestsCount].keyHash = keyhash;
        requestNormals[requestsCount].requestTime = block.timestamp;

        requestsCount += 1;
        emit normalRequest(requestsCount - 1);
    }

    event doctorRequest(uint256 requestId);

    function requestDoctor(bytes32 keyhash, bytes32 vtk) public onlyDoctor {
        requestDoctors[requestsCount].exists = true;
        requestDoctors[requestsCount].granted = false;
        requestDoctors[requestsCount].requester = msg.sender;
        requestDoctors[requestsCount].keyHash = keyhash;
        requestDoctors[requestsCount].requestTime = block.timestamp;
        requestDoctors[requestsCount].vtk = vtk;
        
        requestsCount += 1;
        emit doctorRequest(requestsCount - 1);
    }

    event respondedRequest(uint256 requestId);
    event grantedRequest(uint256 requestId);
    // respond requestDoctor
    function respondDocRes(uint256 id, bytes32 vtk, bool grant) public onlyManager {
        require (documents[requestDoctors[id].keyHash].exists, "Document doesn't exist");
        require (requestDoctors[id].exists, "Request doesn't exist");
        require (requestDoctors[id].vtk == vtk, "Invalid VTK");
        grant = true;
        emit respondedRequest(id);
        if (grant) {
            requestDoctors[id].granted = true;
            emit grantedRequest(id);
        }
    }

    event revokeGrant(uint256 requestId);
    function revoke(uint256 id) public onlyManager {
        requestDoctors[id].granted = false;
        bytes32 empty;
        requestDoctors[id].vtk = empty;
        emit revokeGrant(id);
    }

    event managerRequest(uint256 requestId);

    function requestManager(bytes32 keyhash) public onlyManager {
        requestManagers[requestsCount].exists = true;
        requestManagers[requestsCount].requester = msg.sender;
        requestManagers[requestsCount].keyHash = keyhash;
        requestManagers[requestsCount].requestTime = block.timestamp;

        requestsCount += 1;
        emit managerRequest(requestsCount - 1);
    }

    function getRandomNumber() private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.gaslimit)));
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, block.coinbase)));
        return randomNumber;
    }

    function test() public view returns (bytes32,bytes32) {
        string memory input = "20520815_DauBung_21/5/2022_KhoaNgoaiTH";
        bytes32 bundleHash = keccak256(abi.encodePacked(input));
        
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.gaslimit)));
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, block.coinbase)));
        bytes32 key = bytes32(randomNumber);
        bytes32 keyHash = keccak256(abi.encode(key));
        return (bundleHash, keyHash);
    }

    // Manager Function
    function submitDocument(bytes32 keyHash, address patient, address doctor)
        public
        onlyManager
    {
        PriLib.Document memory document;
        document.exists = true;
        document.id = docsCount;
        document.patient = patient;
        document.doctor = doctor;
        document.keyHash = keyHash;
        documents[keyHash] = document;
        docsCount +=1;
    }

    function requestCrosschain(uint256 docID) onlyManager public view returns (string memory)  {
        return(Strings.toString(docID));
    }

}


