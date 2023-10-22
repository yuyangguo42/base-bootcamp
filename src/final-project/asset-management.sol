pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@account-abstraction/core/BaseAccount.sol";
import "./trust-access-control.sol";

// NOTE: implementation based on example from https://github.cbhq.net/protocols/base-bundler

contract RevocableTrustAssetManagementAccount is BaseAccount, RevocableTrustAccessControl {
    using ECDSA for bytes32;

    IEntryPoint private immutable _entryPoint;

    constructor (
        IEntryPoint _ep,
        address _trustor,
        address _successorTrustee,
        address _successionWitness,
        uint _successionApprovalDelaySeconds
    ) RevocableTrustAccessControl(
        _trustor,
        _successorTrustee,
        _successionWitness,
        _successionApprovalDelaySeconds
    ) {
        _entryPoint = _ep;
    }

    // @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    receive() external payable {}

    // @inheritdoc BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view override returns (uint256 validationData) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        address recovered = hash.recover(userOp.signature);

        if (hasFullAccessToManageFund(recovered)) {
            return 0;
        }
        return 1;
    }
}
