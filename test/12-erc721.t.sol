pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {HaikuNFT, HLib} from "../src/12-erc721.sol";

contract HaikuNFTTest is Test {
    HaikuNFT public hn;

    function setUp() public {
        vm.startPrank(address(42));
        hn = new HaikuNFT("MeowMeowNFT", "MEO");
        vm.stopPrank();
    }

    function testMint() public {
        vm.startPrank(address(1));
        hn.mintHaiku(
            "This is not a haiku",
            "But here we are anyways",
            "Meow"
        );
        assertEq(hn.ownerOf(1), address(1));

        // NotUnique
        vm.expectRevert(HaikuNFT.HaikuNotUnique.selector);
        hn.mintHaiku(
            "Hello!",
            "Hi",
            "Meow"
        );

        // Mint another one from another user
        vm.startPrank(address(2));
        hn.mintHaiku(
            "Meeeeoooow",
            "MeowMeowMeow",
            "MeowMeow"
        );
        assertEq(hn.ownerOf(2), address(2));

        // Share
        vm.startPrank(address(3));
        vm.expectRevert(HaikuNFT.NoHaikusShared.selector);
        hn.getMySharedHaikus();

        vm.startPrank(address(2));
        hn.shareHaiku(address(3), 2);
        vm.startPrank(address(3));
        uint[] memory hks = hn.getMySharedHaikus();
        assertEq(hks.length, 1);

        vm.startPrank(address(1));
        hn.shareHaiku(address(3), 1);
        hn.shareHaiku(address(2), 1);
        vm.startPrank(address(3));
        hks = hn.getMySharedHaikus();
        assertEq(hks.length, 2);

        vm.startPrank(address(2));
        hks = hn.getMySharedHaikus();
        assertEq(hks.length, 1);
    }
}
