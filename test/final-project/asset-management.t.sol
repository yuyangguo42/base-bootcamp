pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import "@account-abstraction/core/EntryPoint.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {VmSafe} from "@forge-std/src/Vm.sol";
import {RevocableTrustAssetManagementAccount} from "../../src/final-project/asset-management.sol";


contract RevocableTrustAssetManagementAccountTest is Test {
    using ECDSA for bytes32;

    RevocableTrustAssetManagementAccount public ta;
    VmSafe.Wallet trustorWallet = vm.createWallet("trustor's wallet");
    address trustor = makeAddr("trustor");
    address successorTrustee  = makeAddr("successorTrustee");
    address witness = makeAddr("witness");
    address publicViewer = makeAddr("publicViewer");

    // Base ERC-4337 entry point contract
    // EntryPoint(payable(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789));
    IEntryPoint ep;

    function setUp() public {
        ep = new EntryPoint();
        vm.prank(trustorWallet.addr);
        ta = new RevocableTrustAssetManagementAccount(
            ep,
            trustorWallet.addr,
            successorTrustee,
            witness,
            42
        );
    }

    function _sign(VmSafe.Wallet memory wallet, bytes memory message) private returns (bytes memory){
        bytes32 digest = keccak256(abi.encodePacked(message));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wallet, digest);
        return abi.encodePacked(v, r, s);
    }

    function test() public {
        bytes memory callData = hex"";
        bytes memory signature = _sign(trustorWallet, callData);
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
        //ep.handleOps(ops, payable(address(ep)));
    }

}
