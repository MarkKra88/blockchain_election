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
    event WinningCandidate(bytes32 candidateID, string name, uint256 votes);

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
    function getWinner() public electionContractInitialized returns (string memory winnerName, uint256 maxVotes) {
        maxVotes = 0;
        bytes32 winningCandidateID = bytes32(0);

        uint256 candidatesCount = electionContract.getNumberOfCandidatesAdded();

        for (uint256 i = 0; i < candidatesCount; i++) {
            (bytes32 candidateID, string memory firstName, string memory lastName, ) = electionContract.getCandidateById(i);
            uint256 candidateVotes = getVotesForCandidate(candidateID);
            if (candidateVotes > maxVotes) {
                maxVotes = candidateVotes;
                winningCandidateID = candidateID;
                winnerName = string(abi.encodePacked(firstName, " ", lastName));
            }
        }

        if (maxVotes == 0) { // No votes case
            winnerName = "No winner";
        }

        emit WinningCandidate(winningCandidateID, winnerName, maxVotes); // Emitting all three details as per the new event definition
        return (winnerName, maxVotes);
    }

}
