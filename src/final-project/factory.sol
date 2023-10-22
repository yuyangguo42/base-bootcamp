pragma solidity 0.8.17;
import "./asset-management.sol";

contract RevocableTrustFactory {
    IEntryPoint private immutable _entryPoint;

    constructor (IEntryPoint _ep) {
        _entryPoint = _ep;
    }

    function deploy(
        address _successorTrustee,
        address _successionWitness,
        uint _successionApprovalDelaySeconds
    ) external returns (RevocableTrustAssetManagementAccount) {
        RevocableTrustAssetManagementAccount ta = new RevocableTrustAssetManagementAccount(
            _entryPoint,
            msg.sender,
            _successorTrustee,
            _successionWitness,
            _successionApprovalDelaySeconds
        );
        return ta;
    }
}
