// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library WVLib {
    struct Issue {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    struct IssueView {
        address[] voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    enum Votes {
        AGAINST,
        FOR,
        ABSTAIN
    }
}

contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping (address => bool) claimed;
    WVLib.Issue[] issues;
    uint numIssues;

    error TokensClaimed();
    error AllTokensClaimed();
    error NoTokensHeld();
    // TODO(Q): Question requires quorum. But why does it make sense
    // to return the quorum instead of the total supply here? Isn't
    // that a more informative error?
    error QuorumTooHigh(uint quorum);
    error VotingClosed();
    error AlreadyVoted();
    constructor (string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        // Burn the 0th issue
        issues.push();
    }

    function claim() public {
        if (claimed[msg.sender]) {
            revert TokensClaimed();
        }
        if (totalSupply() > 999999) {
            revert AllTokensClaimed();
        }

        claimed[msg.sender] = true;
        _mint(msg.sender, 100);
    }

    function createIssue(string memory _desc, uint _quorum) external returns (uint idx) {
        if (balanceOf(msg.sender) == 0) {
            revert NoTokensHeld();
        }

        if (_quorum > totalSupply()) {
            revert QuorumTooHigh(_quorum);
        }

        idx = issues.length;
        issues.push();
        WVLib.Issue storage iss = issues[idx];
        iss.issueDesc = _desc;
        iss.quorum = _quorum;
        return idx;
    }

    function getIssue(uint _id) external view returns (WVLib.IssueView memory) {
        WVLib.Issue storage iss = issues[_id];
        return WVLib.IssueView(
            iss.voters.values(),
            iss.issueDesc,
            iss.votesFor,
            iss.votesAgainst,
            iss.votesAbstain,
            iss.totalVotes,
            iss.quorum,
            iss.passed,
            iss.closed
        );
    }

    function vote(uint _issueId, WVLib.Votes _vote) external {
        WVLib.Issue storage iss = issues[_issueId];
        if (iss.closed) {
            revert VotingClosed();
        }

        if (iss.voters.contains(msg.sender)) {
            revert AlreadyVoted();
        }

        iss.voters.add(msg.sender);
        uint count = balanceOf(msg.sender);
        if (_vote == WVLib.Votes.FOR) {
            iss.votesFor += count;
        } else if (_vote == WVLib.Votes.AGAINST) {
            iss.votesAgainst += count;
        } else {
            iss.votesAbstain += count;
        }

        if (iss.votesAgainst + iss.votesAbstain + iss.votesFor > iss.quorum) {
            iss.closed = true;
            if (iss.votesFor > iss.votesAgainst) {
                iss.passed = true;
            }
        }
    }
}
