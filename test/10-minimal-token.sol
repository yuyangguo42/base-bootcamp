pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {UnburnableToken} from "../src/10-minimal-token.sol";

contract UnburnableTokenTest is Test {
    UnburnableToken public ut;

    function setUp() public {
        vm.startPrank(address(42));
        ut = new UnburnableToken();
        vm.stopPrank();
    }

    function testUnburnableToken() public {
        vm.startPrank(address(1));
        ut.claim();
        assertEq(ut.balances(address(1)), 1000);

        vm.expectRevert();
        ut.safeTransfer(address(2), 1001);

        vm.expectRevert();
        ut.claim();

        // Cannot send to target with non eth balance
        vm.expectRevert();
        ut.safeTransfer(address(2), 501);

        vm.deal(address(2), 42);
        ut.safeTransfer(address(2), 501);
        assertEq(ut.balances(address(1)), 499);
        assertEq(ut.balances(address(2)), 501);

        vm.startPrank(address(2));
        ut.claim();
        assertEq(ut.balances(address(2)), 1501);
    }


}
