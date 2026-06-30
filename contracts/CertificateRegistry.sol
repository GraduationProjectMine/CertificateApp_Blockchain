// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract CertificateRegistry {
    address public owner;
    
    struct Certificate {
        bytes32 sha3Hash;
        string cid;
        bytes signature;
        address issuer;
        uint256 timestamp;
        bool isRevoked;
        bool exists;
    }
    
    // Mapping from SHA-3 hash to Certificate data
    mapping(bytes32 => Certificate) private certificates;
    
    // Mapping of authorized issuers
    mapping(address => bool) public authorizedIssuers;
    
    // Events
    event IssuerAuthorized(address indexed issuer);
    event IssuerDeauthorized(address indexed issuer);
    event CertificateRegistered(bytes32 indexed sha3Hash, string cid, address indexed issuer, uint256 timestamp);
    event CertificateRevoked(bytes32 indexed sha3Hash, address indexed revoker, uint256 timestamp);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
    
    modifier onlyIssuer() {
        require(authorizedIssuers[msg.sender] || msg.sender == owner, "Only authorized issuers or owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedIssuers[msg.sender] = true; // Owner is authorized by default
        emit IssuerAuthorized(msg.sender);
    }
    
    /**
     * @dev Authorizes a new issuer address. Only owner can authorize.
     */
    function authorizeIssuer(address _issuer) external onlyOwner {
        require(_issuer != address(0), "Invalid issuer address");
        require(!authorizedIssuers[_issuer], "Issuer is already authorized");
        authorizedIssuers[_issuer] = true;
        emit IssuerAuthorized(_issuer);
    }
    
    /**
     * @dev Deauthorizes an issuer address. Only owner can deauthorize.
     */
    function deauthorizeIssuer(address _issuer) external onlyOwner {
        require(authorizedIssuers[_issuer], "Issuer is not authorized");
        authorizedIssuers[_issuer] = false;
        emit IssuerDeauthorized(_issuer);
    }
    
    /**
     * @dev Registers a new certificate. Only authorized issuers or owner can register.
     */
    function registerCertificate(
        bytes32 _sha3Hash,
        string calldata _cid,
        bytes calldata _signature
    ) external onlyIssuer {
        require(_sha3Hash != bytes32(0), "Invalid certificate hash");
        require(bytes(_cid).length > 0, "Invalid CID");
        require(!certificates[_sha3Hash].exists, "Certificate already registered");
        
        certificates[_sha3Hash] = Certificate({
            sha3Hash: _sha3Hash,
            cid: _cid,
            signature: _signature,
            issuer: msg.sender,
            timestamp: block.timestamp,
            isRevoked: false,
            exists: true
        });
        
        emit CertificateRegistered(_sha3Hash, _cid, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Revokes an existing certificate. Only original issuer or owner can revoke.
     */
    function revokeCertificate(bytes32 _sha3Hash) external onlyIssuer {
        require(certificates[_sha3Hash].exists, "Certificate does not exist");
        require(!certificates[_sha3Hash].isRevoked, "Certificate is already revoked");
        require(
            certificates[_sha3Hash].issuer == msg.sender || msg.sender == owner,
            "Only original issuer or owner can revoke"
        );
        
        certificates[_sha3Hash].isRevoked = true;
        emit CertificateRevoked(_sha3Hash, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Retrieves a registered certificate's details by its SHA-3 hash.
     */
    function getCertificate(bytes32 _sha3Hash) external view returns (
        bytes32 sha3Hash,
        string memory cid,
        bytes memory signature,
        address issuer,
        uint256 timestamp,
        bool isRevoked,
        bool exists
    ) {
        Certificate memory cert = certificates[_sha3Hash];
        require(cert.exists, "Certificate does not exist");
        return (
            cert.sha3Hash,
            cert.cid,
            cert.signature,
            cert.issuer,
            cert.timestamp,
            cert.isRevoked,
            cert.exists
        );
    }
}
