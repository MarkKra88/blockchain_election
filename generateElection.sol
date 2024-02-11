// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract generateElection{
    
    //Limit access so that only contract owner will be able to use it and give access to it
    address public owner;
    mapping(address => bool) public allowedAddresses;

    // Flag to track if the contract is disabled
    bool public disabled; 


    modifier onlyOwner(){
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Allow owner to add address that can use this contract
    modifier onlyAllowed() {
        require(allowedAddresses[msg.sender], "Sender is not allowed to use this contract");
        _;
    }

    modifier notDisabled() {
        require(!disabled, "Contract is disabled");
        _;
    }

    struct Election {
        address electionAddress;
        string electionName;
        uint256 maxNumerOfCandidates;
        uint256 numberOfCandidatesAdded;
    }

    constructor() {
        owner = msg.sender;
        allowedAddresses[owner] = true;

    }

    function addAllowedAddress(address _address) public onlyOwner {
        allowedAddresses[_address] = true;
    }

    Election[1] public listOfElections;

    function addElection (
        string memory _electionName,
        uint256 _maxNumberOfCandidates) public onlyAllowed notDisabled {
            //listOfElections.push(Election(_electionName,_maxNumberOfCandidates));
            require(bytes(listOfElections[0].electionName).length == 0, "To add another election, first you will have to complete adding the first one");
            listOfElections[0] = Election(address(this),_electionName, _maxNumberOfCandidates,0);
    }

    // Candidate profile
    struct Candidate {
        bytes32 candidateID;
        string candidateFirstName;
        string candidateMiddleName;
        string candidateLastName;
        uint256 candidateDOB;
    }

    Candidate[] public listOfCandidates;
    mapping(bytes32 => bool) public candidateExists;

    // Add a new candidate to the list
    function addCandidate (
        string memory _candidateFirstName, 
        string memory _candidateMiddleName,
        string memory _candidateLastName,
        uint256 _candidateDOB) public onlyAllowed notDisabled {
            // Generate unique candidate ID
            bytes32 _candidateID = keccak256(abi.encodePacked(
                _candidateFirstName,
                _candidateMiddleName,
                _candidateLastName,
                _candidateDOB
            ));

            //Ensure that number of cadidates won't exceed the threshold
            require(listOfElections[0].numberOfCandidatesAdded < listOfElections[0].maxNumerOfCandidates, "Maximum number of candidates reached");

            //Ensure that a candidate with the same ID will be added only once 
            require(!candidateExists[_candidateID], "Candidate already exists");

            listOfCandidates.push(Candidate(_candidateID,_candidateFirstName,_candidateMiddleName,_candidateLastName,_candidateDOB));
            candidateExists[_candidateID] = true;
            
            // Increment the number of candidates added for this election
            listOfElections[0].numberOfCandidatesAdded++;
    }

    // Remove candidate from the list
    function removeCandidate (
        string memory _candidateFirstName, 
        string memory _candidateMiddleName,
        string memory _candidateLastName,
        uint256 _candidateDOB) public onlyAllowed notDisabled {
            // Generate unique candidate ID
            bytes32 _candidateID = keccak256(abi.encodePacked(
                _candidateFirstName,
                _candidateMiddleName,
                _candidateLastName,
                _candidateDOB
            ));

            require(candidateExists[_candidateID], "Candidate is not in the list");

            // Check if the candidate we want to delete actually exists
            for (uint256 i = 0; i < listOfCandidates.length; i++) {
                if (listOfCandidates[i].candidateID == _candidateID) {
                    delete listOfCandidates[i];
                    candidateExists[_candidateID] = false;
                    listOfElections[0].numberOfCandidatesAdded--;
                    break;

                }

            }        
        }            
    // Function to get all candidates
    function getAllCandidates() public view onlyAllowed returns (Candidate[] memory) {
        return listOfCandidates;
    }

    // Function to disable funtions of adding election and candiadtes
    function disableContract() public onlyOwner {
        disabled = true;}

        // Getter function for listOfCandidates
    function getCandidatesCount() public view returns (uint256) {
        return listOfCandidates.length;
    }

    // Function to get the number of candidates added in an election
    function getNumberOfCandidatesAdded() public view returns (uint256) {
        return listOfElections[0].numberOfCandidatesAdded;
    }

    function getCandidateById(uint256 _index) public view returns (bytes32, string memory, string memory, string memory, uint256) {
        require(_index < listOfCandidates.length, "Candidate index out of bounds");

        Candidate memory candidate = listOfCandidates[_index];
        return (candidate.candidateID, candidate.candidateFirstName, candidate.candidateMiddleName, candidate.candidateLastName, candidate.candidateDOB);
    }
        
}
