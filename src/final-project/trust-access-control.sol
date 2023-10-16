// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

library TrustAccessControlConsts {
    enum TrustState {
        // REVOCABLE: initial setup state, Trustor is alive and also the Trustee (manager) of the Trust
        //            modifications to trust rules and roles can stil happen
        REVOCABLE,
        // SUCESSION_PROPOSED: Trustor may have passed and the succession process has been initiated
        //                     Approval required in order for the proposal to go through and move the
        //                     Trust into Irrevocable
        SUCESSION_PROPOSED,
        // SUCESSION_PENDING: All parties have approved the succession event.
        //                    Awaiting the `successionApprovalDelaySeconds` to elapse before the
        //                    succession finalizes.
        SUCESSION_PENDING,
        // SUCESSION_REJECTED: A fraudulent succession proposal while Trustor is alive happened
        //                     Trust is put into a state where only the Trustor can make modifications
        SUCESSION_REJECTED,
        // IRREVOCABLE: Trustor has passed and succession event has been successfully confirmed
        //              SuccessorTrustee becomes the new Trustee (manager) of the Trust.
        //              Trust rules can no longer be modified.
        IRREVOCABLE
    }

    event TrustStateTransition(
        address executor,
        TrustAccessControlConsts.TrustState oldState,
        TrustAccessControlConsts.TrustState newState
    );
}

contract RevocableTrustAccessControl is AccessControl {
    // Definitions
    // Succession event: when the current Trustee passes

    // Roles involved:
    // 1. Trustor (aka Trustor / Admin / Owner)
    // - Trust Management:
    // -   Appoint all other roles
    // -   Reject a fraudulent succession event
    // -   Setup all distribution rules & money management guidelines
    // 2. Trustee (aka the "manager" of the trust, usually while Trustor is alive, Trustor also serves Trustee)
    // - Money Management:
    // -   Authority over all funds (make investments, transfers etc)  according to the Trust's rules
    // 3. Successor Trustee
    // - propose a succession event
    // - become the new trustee (admin of this contract) during a succession event
    // 3. Succession Witness
    // - approve/reject a succession event

    bytes32 public constant TRUSTEE = keccak256("TRUSTEE");
    bytes32 public constant SUCCESSOR_TRUSTEE = keccak256("SUCCESSOR_TRUSTEE");
    bytes32 public constant SUCCESSION_WITNESS = keccak256("SUCCESSION_WITNESS");

    address public trustor;
    address public successorTrustee;
    address public successionWitness;

    TrustAccessControlConsts.TrustState public trustState;
    uint public successionProposalTs;
    uint public successionApprovalDelaySeconds;

    error UnauthorizedRole(address performer, string msg);
    error TrustStateMismatch(
        TrustAccessControlConsts.TrustState current,
        TrustAccessControlConsts.TrustState expected
    );
    error SuccessionDelayNotSatisfied(uint tsWhenSuccessionUnlocked);
    // TODO(yuyang, oct-14-2023): Enforce witness and successorTrustee not the same one

    // Initial setup of Trust
    constructor (address _successorTrustee, address _successionWitness, uint _successionApprovalDelaySeconds) {
        trustState = TrustAccessControlConsts.TrustState.REVOCABLE;
        successionApprovalDelaySeconds = _successionApprovalDelaySeconds;

        trustor = msg.sender;
        successorTrustee = _successorTrustee;
        successionWitness = _successionWitness;

        // TODO(yuyang, oct-14-2023): Factory set the DEFAULT_ADMIN_ROLE? Or here?
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRUSTEE, msg.sender);
        _grantRole(SUCCESSOR_TRUSTEE, _successorTrustee);
        _grantRole(SUCCESSION_WITNESS, _successionWitness);
    }

    // ================ Trustor's Management Interfaces =========================
    function changeSuccessorTrustee(address _newSuccessorTrustee) public {
        _checkRole(DEFAULT_ADMIN_ROLE);

        revokeRole(SUCCESSOR_TRUSTEE, successorTrustee);
        successorTrustee = _newSuccessorTrustee;
        grantRole(SUCCESSOR_TRUSTEE, successorTrustee);
    }

    function changeSuccessionWitness(address _newSuccessionWitness) public {
        _checkRole(DEFAULT_ADMIN_ROLE);

        revokeRole(SUCCESSION_WITNESS, successionWitness);
        successionWitness = _newSuccessionWitness;
        grantRole(SUCCESSION_WITNESS, successionWitness);
    }

    function updateSuccessionApprovalDelaySeconds(uint _newDelaySeconds) public {
        _checkRole(DEFAULT_ADMIN_ROLE);

        successionApprovalDelaySeconds = _newDelaySeconds;
    }

    // @notice Called by Trustor after a fraudulent succession event happens to repair Trust state
    function repairTrust(address _newSuccessorTrustee, address _newSuccessionWitness) public {
        _checkRole(DEFAULT_ADMIN_ROLE);

        _checkAndChangeTrustState(
            TrustAccessControlConsts.TrustState.SUCESSION_REJECTED,
            TrustAccessControlConsts.TrustState.REVOCABLE
        );

        changeSuccessorTrustee(_newSuccessorTrustee);
        changeSuccessionWitness(_newSuccessionWitness);
    }

    // ================= Sucession Management Interfaces =========================
    // @notice After Trustor passes, this function can be used by successor trustee to initiate the transition
    function proposeSuccessionEvent() public {
        _checkRole(SUCCESSOR_TRUSTEE);

        _checkAndChangeTrustState(
            TrustAccessControlConsts.TrustState.REVOCABLE,
            TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED
        );
        successionProposalTs = block.timestamp;
    }

    // @notice After Trustor passes, this function can be used by witness to approve the proposed transition
    function approveSuccessionEvent() public {
        _checkRole(SUCCESSION_WITNESS);

        _checkAndChangeTrustState(
            TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED,
            TrustAccessControlConsts.TrustState.SUCESSION_PENDING
        );
    }

    // @notice For Witness or Trustor to reject a fraudulent succession event
    //         Once rejected, Trustor need to call `repairTrust`.
    function rejectSuccessionEvent() public {
        if (!hasRole(SUCCESSION_WITNESS, msg.sender) && !hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert UnauthorizedRole(msg.sender, "Need SUCCESSION_WITNESS or ADMIN role");
        }

        if (trustState != TrustAccessControlConsts.TrustState.SUCESSION_PENDING &&
            trustState != TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED) {
            // TODO(yuyang, oct-14-2023) make the error extensive
            revert TrustStateMismatch(trustState, TrustAccessControlConsts.TrustState.SUCESSION_PROPOSED);
        }
        _unsafeChangeTrustState(TrustAccessControlConsts.TrustState.SUCESSION_REJECTED);
    }

    // @notice For successor trustee to finalize succession event after approval & delay time elapse.
    function finalizeSuccessionEvent() public {
        _checkRole(SUCCESSOR_TRUSTEE);
        _checkTrustState(TrustAccessControlConsts.TrustState.SUCESSION_PENDING);
        if (successionProposalTs == 0) {
            // Uninitialized, likely a bug from the contract
            revert("Contract bug: state moved to SUCESSION_PENDING without setting proposalTS");
        }

        uint expectedTs = successionProposalTs + successionApprovalDelaySeconds;
        if (block.timestamp < expectedTs) {
            revert SuccessionDelayNotSatisfied(expectedTs);
        }
        _unsafeChangeTrustState(TrustAccessControlConsts.TrustState.IRREVOCABLE);
    }

    // Private helpers for trust state management

    function _checkTrustState(TrustAccessControlConsts.TrustState expected) private view {
        if (trustState != expected) {
            revert TrustStateMismatch(trustState, expected);
        }
    }

    function _checkAndChangeTrustState(
        TrustAccessControlConsts.TrustState expected,
        TrustAccessControlConsts.TrustState newState
    ) private {
        _checkTrustState(expected);
        _unsafeChangeTrustState(newState);
    }

    // @dev Performs a state transition without verification. Prefer using _checkAndChangeTrustState instead.
    // TODO: consider centralizing the state transition validity here
    function _unsafeChangeTrustState(TrustAccessControlConsts.TrustState newState) private {
        TrustAccessControlConsts.TrustState prevState = trustState;
        trustState = newState;
        emit TrustAccessControlConsts.TrustStateTransition(msg.sender, prevState, newState);
    }

}
