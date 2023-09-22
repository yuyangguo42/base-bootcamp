pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {WeightedVoting, WVLib} from "../src/11-erc20.sol";

contract WeightedVotingTest is Test {
    WeightedVoting public wv;
    WeightedVoting public wv2;

    function setUp() public {
        vm.startPrank(address(42));
        wv = new WeightedVoting("Meow", "MEO");
        wv2 = new WeightedVoting("Meow2", "MEO2");
        vm.stopPrank();
    }

    function testClaim() public {
        vm.startPrank(address(1));
        wv.claim();
        assertEq(wv.balanceOf(address(1)), 100);

        vm.expectRevert();
        wv.claim();

    }

    function testIssueSimple() public {
        // Creation
        vm.startPrank(address(11));
        vm.expectRevert(WeightedVoting.NoTokensHeld.selector);
        uint idx = wv.createIssue("Cats are dogs", 42);

        wv.claim();
        assertEq(wv.balanceOf(address(11)), 100);

        vm.expectRevert(abi.encodeWithSelector(WeightedVoting.QuorumTooHigh.selector, 420));
        idx = wv.createIssue("Cats are dogs", 420);

        idx = wv.createIssue("Cats are dogs", 42);
        assertEq(idx, 1);
        vm.stopPrank();

        // Getting
        WVLib.IssueView memory iss = wv.getIssue(1);
        assertEq(iss.quorum, 42);

        // Voting passing
        vm.startPrank(address(12));
        wv.claim();
        wv.vote(1, WVLib.Votes.FOR);
        iss = wv.getIssue(1);
        assertEq(iss.passed, true);
        assertEq(iss.closed, true);

        vm.expectRevert(WeightedVoting.VotingClosed.selector);
        wv.vote(1, WVLib.Votes.FOR);
    }

    function testIssueClosing() public {
        // Create a total supply of 300 tokens
        vm.startPrank(address(21));
        wv2.claim();
        vm.startPrank(address(22));
        wv2.claim();
        vm.startPrank(address(23));
        wv2.claim();

        vm.startPrank(address(21));
        uint idx = wv2.createIssue("who cares", 1);
        idx = wv2.createIssue("Cats are dogs", 101);

        vm.startPrank(address(22));
        wv2.vote(2, WVLib.Votes.AGAINST);
        WVLib.IssueView memory iss = wv2.getIssue(2);
        assertEq(iss.closed, false);

        vm.startPrank(address(23));
        wv2.vote(2, WVLib.Votes.AGAINST);
        iss = wv2.getIssue(2);
        assertEq(iss.closed, true);
        assertEq(iss.passed, false);
    }
}

