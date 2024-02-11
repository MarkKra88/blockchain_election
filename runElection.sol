// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./generateElection.sol";

contract runElection {
    generateElection electionContract;

    
    // Mapping to store the address that has voted and the candidate they voted for
    mapping(address => bytes32) public votesByVoter;

    // Mapping to store votes received for each candidate
    mapping(bytes32 => uint256) public votesReceived;

    // Event to log the count of candidates
    event CandidatesCount(uint256 count);

    // Event to log the winning candidate
    event WinningCandidate(bytes32 candidateID);

    // Modifier to ensure that the election contract is initialized
    modifier electionContractInitialized() {
        require(address(electionContract) != address(0), "Election contract not initialized");
        _;
    }

    // Constructor to set the election contract address
    constructor(address _electionContract) {
        electionContract = generateElection(_electionContract);
    }

    // Function for voters to cast their votes
    function voteForCandidate(bytes32 _candidateID) public electionContractInitialized {
        require(electionContract.candidateExists(_candidateID), "Candidate does not exist");
        require(votesByVoter[msg.sender] == bytes32(0), "You have already voted");

        votesReceived[_candidateID] += 1;
        votesByVoter[msg.sender] = _candidateID;
    }

    // Function to retrieve the total number of votes for a candidate
    function getVotesForCandidate(bytes32 _candidateID) public view electionContractInitialized returns (uint256) {
        return votesReceived[_candidateID];
    }


    // Function to determine the winner of the election
    function getWinner() public view electionContractInitialized returns (string memory, uint256) {
        uint256 maxVotes = 0;
        bytes32 winningCandidateID;

        // uint256 candidatesCount = electionContract.getNumberOfCandidatesAdded();


        // Iterate through all candidates to find the one with the most votes
        for (uint256 i = 0; i < candidatesCount; i++) {
            (bytes32 candidateID, , , , ) = electionContract.getCandidateById(i);
            uint256 candidateVotes = votesReceived[candidateID];
            if (candidateVotes > maxVotes) {
                maxVotes = candidateVotes;
                winningCandidateID = candidateID;
            }
        }

        // Retrieve the winner's details
        (, string memory firstName, string memory middleName, string memory lastName, ) = electionContract.getCandidateById(uint256(winningCandidateID));
        string memory winnerName = string(abi.encodePacked(firstName, " ", middleName, " ", lastName));
        return (winnerName, maxVotes);
    }


}
