// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract Voting {
    address public officialAddress;
    string[] public candidateList;

    mapping(string => uint256) private votesReceived;
    mapping(address => bool) public isVoted;

    enum State {
        Created,
        Voting,
        Ended
    }

    State public state;

    constructor(string[] memory candidateNames) {
        officialAddress = msg.sender;
        candidateList = candidateNames;
        state = State.Created;
    }

    modifier onlyOfficial() {
        require(msg.sender == officialAddress, "ONLY OFFICIAL");
        _;
    }

    modifier inState(State requiredState) {
        require(state == requiredState, "INCORRECT STATE");
        _;
    }

    function startVote()
        public
        onlyOfficial
        inState(State.Created)
    {
        state = State.Voting;
    }

    function endVote()
        public
        onlyOfficial
        inState(State.Voting)
    {
        state = State.Ended;
    }

    function voteForCandidate(string memory candidate)
        public
        inState(State.Voting)
    {
        require(!isVoted[msg.sender], "ALREADY VOTED");
        require(isValidCandidate(candidate), "INVALID CANDIDATE");

        isVoted[msg.sender] = true;
        votesReceived[candidate] += 1;
    }

    function totalVotesFor(string memory candidate)
        public
        view
        inState(State.Ended)
        returns (uint256)
    {
        require(isValidCandidate(candidate), "INVALID CANDIDATE");

        return votesReceived[candidate];
    }

    function getCandidateList()
        public
        view
        returns (string[] memory)
    {
        return candidateList;
    }

    function isValidCandidate(string memory candidate)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < candidateList.length; i++) {
            if (
                keccak256(bytes(candidateList[i])) ==
                keccak256(bytes(candidate))
            ) {
                return true;
            }
        }

        return false;
    }
}