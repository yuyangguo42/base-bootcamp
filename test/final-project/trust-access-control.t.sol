pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {TrustAccessControlConsts, RevocableTrustAccessControl} from "../../src/final-project/trust-access-control.sol";

contract RevocableTrustAccessControlTest is Test {
    RevocableTrustAccessControl public ac;
    address constant trustor = address(100);
    address constant successorTrustee = address(200);
    address constant successorTrustee2 = address(201);
    address constant successorTrustee3 = address(202);
    address constant witness = address(300);
    address constant witness2 = address(301);
    address constant witness3 = address(302);
    address constant publicViewer = address(400);

    function setUp() public {
        vm.prank(trustor);
        ac = new RevocableTrustAccessControl(successorTrustee, witness, uint(100));
    }

    function testTrustManagement() public {
        // Initialization success
        vm.startPrank(publicViewer);
        assertEq(ac.trustor(), trustor);
        assertEq(ac.successorTrustee(), successorTrustee);
        assertEq(ac.successionWitness(), witness);
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.REVOCABLE));
        assertEq(ac.successionApprovalDelaySeconds(), uint(100));


        // Trustor successfully managing trust
        vm.startPrank(trustor);
        ac.changeSuccessorTrustee(successorTrustee2);
        assertEq(ac.successorTrustee(), successorTrustee2);
        ac.changeSuccessionWitness(witness2);
        assertEq(ac.successionWitness(), witness2);
        ac.updateSuccessionApprovalDelaySeconds(uint(42));
        assertEq(ac.successionApprovalDelaySeconds(), uint(42));

        // Successor Trustee cannot manage trust
        vm.startPrank(ac.successorTrustee());
        vm.expectRevert();
        ac.changeSuccessorTrustee(successorTrustee3);
        vm.expectRevert();
        ac.changeSuccessionWitness(witness3);
        vm.expectRevert();
        ac.updateSuccessionApprovalDelaySeconds(1);

        vm.stopPrank();
    }

    function testSuccessionEventSuccess() public {
        uint startTime = 1680616584;
        uint delayTime = 10000;

        _performFullSuccession(startTime, delayTime);
    }

    function testSuccessionEventRejectionByTrustor() public {
        uint startTime = 1680616584;
        uint delayTime = 10000;

        // Successor Trustee initiate
        _prepareProposedSuccessionTrust(startTime, delayTime);

        // Rejection by trustor
        vm.startPrank(trustor);
        vm.expectEmit(false, false, false, true);
        emit TrustAccessControlConsts.TrustStateTransition(
            ac.trustor(),
            TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED,
            TrustAccessControlConsts.TrustState.SUCESSION_REJECTED
        );
        ac.rejectSuccessionEvent();
        vm.stopPrank();

        // Trustor can repair the trust after rejection
        _repairTrust();

        // Trust can successfully transition after one rejection
        _performFullSuccession(startTime + delayTime + 40000, delayTime);
    }

    function testSuccessionEventRejectionByTrustorAfterApproval() public {
        uint startTime = 1680616584;
        uint delayTime = 10000;

        // Successor Trustee initiate
        _prepareProposedSuccessionTrust(startTime, delayTime);

        // Witness approves
        _witnessApprove();

        // Rejection by trustor
        _rejectSuccessionEvent(ac.trustor(), TrustAccessControlConsts.TrustState.SUCESSION_PENDING);

        // Trustor can repair the trust after rejection
        _repairTrust();

        // Trust can successfully transition after one rejection
        _performFullSuccession(startTime + delayTime + 40000, delayTime);
    }

    function testRolesMismatchForSuccessionEvents() public {
        uint startTime = 1680618765;
        uint delayTime = 10000;

        // Random person cannot initiate succession
        vm.prank(trustor);
        ac = new RevocableTrustAccessControl(successorTrustee, witness, delayTime);

        vm.startPrank(publicViewer);
        vm.expectRevert();
        ac.proposeSuccessionEvent();
        vm.stopPrank();

        // Random person cannot approve succession requests
        vm.startPrank(publicViewer);
        vm.expectRevert();
        ac.approveSuccessionEvent();

        // Successor Trustee cannot approve succession requests
        _prepareProposedSuccessionTrust(startTime, delayTime);
        vm.startPrank(ac.successorTrustee());
        vm.expectRevert();
        ac.approveSuccessionEvent();
        vm.stopPrank();

        // Successor, Witness and random person cannot repair trust
        _rejectSuccessionEvent(trustor, TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED);
        vm.startPrank(ac.successorTrustee());
        vm.expectRevert();
        ac.repairTrust(successorTrustee3, witness3);
        vm.startPrank(ac.successionWitness());
        vm.expectRevert();
        ac.repairTrust(successorTrustee3, witness3);
        vm.startPrank(publicViewer);
        vm.expectRevert();
        ac.repairTrust(successorTrustee3, witness3);
    }

    function testAccessAfterRoleChange() public {
        uint startTime = 1680619999;
        uint delayTime = 10000;

        // Old witness cannot approve
        _prepareProposedSuccessionTrust(startTime, delayTime);
        vm.startPrank(trustor);
        ac.changeSuccessionWitness(witness3);
        vm.startPrank(witness);
        vm.expectRevert();
        ac.approveSuccessionEvent();

        // New witness can approve
        vm.startPrank(witness3);
        ac.approveSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.SUCESSION_PENDING));

        // Advance delay time
        vm.warp(startTime + delayTime);

        // Old successorTrustee cannot finalize
        vm.startPrank(trustor);
        ac.changeSuccessorTrustee(successorTrustee3);
        vm.startPrank(successorTrustee);
        vm.expectRevert();
        ac.finalizeSuccessionEvent();

        // New successorTrustee can finalize
        vm.startPrank(successorTrustee3);
        ac.finalizeSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.IRREVOCABLE));

        vm.stopPrank();
    }

    function testAttemptFinalizationBeforeDelay() public {
        uint startTime = 1680619999;
        uint delayTime = 10000;

        _prepareProposedSuccessionTrust(startTime, delayTime);
        _witnessApprove();

        // Attempt finalize before the delay time elapsed
        vm.startPrank(ac.successorTrustee());
        vm.expectRevert();
        ac.finalizeSuccessionEvent();

        vm.warp(startTime + delayTime - 1);
        vm.expectRevert();
        ac.finalizeSuccessionEvent();

        // Finalize after delay time elapsed
        vm.warp(startTime + delayTime + 24);
        _finalizeSuccessionEvent();
    }

    function _performFullSuccession(uint startTime, uint delayTime) private {

        // Successor Trustee initiate
        _prepareProposedSuccessionTrust(startTime, delayTime);

        // Witness approves
        _witnessApprove();

        // Delay elapsed without any rejection
        vm.warp(startTime + delayTime);

        // Finalize succession event
        _finalizeSuccessionEvent();
    }

    function _prepareProposedSuccessionTrust(uint startTime, uint delayTime) private {
        vm.warp(startTime);
        vm.startPrank(trustor);
        ac = new RevocableTrustAccessControl(successorTrustee, witness, delayTime);
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.REVOCABLE));
        vm.stopPrank();

        // SuccessionTrustee initiates
        vm.startPrank(ac.successorTrustee());
        vm.expectEmit(false, false, false, true);
        emit TrustAccessControlConsts.TrustStateTransition(
            ac.successorTrustee(),
            TrustAccessControlConsts.TrustState.REVOCABLE,
            TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED
        );
        ac.proposeSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED));

        vm.stopPrank();
    }

    function _witnessApprove() private {
        vm.startPrank(ac.successionWitness());
        vm.expectEmit(false, false, false, true);
        emit TrustAccessControlConsts.TrustStateTransition(
            ac.successionWitness(),
            TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED,
            TrustAccessControlConsts.TrustState.SUCESSION_PENDING
        );
        ac.approveSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.SUCESSION_PENDING));
        vm.stopPrank();
    }

    function _rejectSuccessionEvent(address rejector, TrustAccessControlConsts.TrustState startState) private {
        vm.startPrank(rejector);
        vm.expectEmit(false, false, false, true);
        emit TrustAccessControlConsts.TrustStateTransition(
            rejector,
            startState,
            TrustAccessControlConsts.TrustState.SUCESSION_REJECTED
        );
        ac.rejectSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.SUCESSION_REJECTED));
        vm.stopPrank();
    }

    function _repairTrust() private {
        vm.startPrank(ac.trustor());
        ac.repairTrust(successorTrustee3, witness3);
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.REVOCABLE));
        assertEq(ac.successorTrustee(), successorTrustee3);
        assertEq(ac.successionWitness(), witness3);
        vm.stopPrank();
    }

    function _finalizeSuccessionEvent() private {
        vm.startPrank(ac.successorTrustee());
        vm.expectEmit(false, false, false, true);
        emit TrustAccessControlConsts.TrustStateTransition(
            ac.successorTrustee(),
            TrustAccessControlConsts.TrustState.SUCESSION_PENDING,
            TrustAccessControlConsts.TrustState.IRREVOCABLE
        );
        ac.finalizeSuccessionEvent();
        assertEq(uint8(ac.trustState()), uint8(TrustAccessControlConsts.TrustState.IRREVOCABLE));

        vm.stopPrank();
    }
}
