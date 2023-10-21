pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import "@account-abstraction/core/EntryPoint.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {RevocableTrustAssetManagementAccount} from "../../src/final-project/asset-management.sol";

contract RevocableTrustAssetManagementAccountTest is Test {
    using ECDSA for bytes32;

    RevocableTrustAssetManagementAccount public ta;
    address trustor = makeAddr("trustor");
    address successorTrustee  = makeAddr("successorTrustee");
    address witness = makeAddr("witness");
    address publicViewer = makeAddr("publicViewer");

    // Base ERC-4337 entry point contract
    // EntryPoint(payable(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789));
    IEntryPoint ep;

    function setUp() public {
        ep = new EntryPoint();
        vm.prank(trustor);
        ta = new RevocableTrustAssetManagementAccount(
            ep,
            successorTrustee,
            witness,
            42
        );
    }

    function test() public {
        bytes memory callData = hex"";
        bytes memory signature = hex"";
        UserOperation memory userOp = UserOperation(
            address(ta),
            0,
            "",
            callData,
            35000,
            1300000,
            45000,
            2000,
            2005,
            "",
            signature
        );
        //bytes32 userOpHash = ep.getUserOpHash(userOp);
        UserOperation[] memory ops = new UserOperation[](1);
        ops[0] = userOp;
        // TODO(yuyang): left off here, need to figure out how to actually provide a proper signature
        // ep.handleOps(ops, payable(address(ep)));
    }

}
