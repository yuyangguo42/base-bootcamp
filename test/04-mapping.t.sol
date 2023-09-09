// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {FavoriteRecords} from "../src/04-mapping.sol";

contract FavoriteRecordsTest is Test {
    FavoriteRecords public favRecords;

    function setUp() public {
        favRecords = new FavoriteRecords();
    }

    function test_getApprovedRecords() public {

        string[9] memory expectedRecords = [
            "Thriller",
            "Back in Black",
            "The Bodyguard",
            "The Dark Side of the Moon",
            "Their Greatest Hits (1971-1975)",
            "Hotel California",
            "Come On Over",
            "Rumours",
            "Saturday Night Fever"
        ];
        string[] memory records = favRecords.getApprovedRecords();
        assertEq(records.length, expectedRecords.length);
        for (uint i=0; i < records.length; i++) {
            assertEq(records[i], expectedRecords[i]);
        }
    }

    function test_addRecordGetUserFavoriteSuccess() public {
        // TODO(question):
        // If I don't use startPrank. The `msg.sender` in this address
        // is not the same as the one in the FavoriteRecords `msg.sender`
        // this means the `msg.sender` in FavRecords is actually the
        // address of this contract?
        address addr = address(0x1234567890123456789012345678901234567890);
        vm.startPrank(addr);

        // 1. Fav records should be empty to start with
        string[] memory favs = favRecords.getUserFavorites(addr);
        assertEq(favs.length, 0);

        // 2. Adding an approved record should be successful
        favRecords.addRecord("Rumours");
        string[] memory favs1 = favRecords.getUserFavorites(addr);
        // TODO(question):
        // why does the following not work? because the array size was
        // already fixed at 0?
        //favs = favRecords.getUserFavorites(msg.sender);

        assertEq(favs1.length, 1);
        assertEq(favs1[0], "Rumours");

        // 3. Adding a non-approved record should cause a revert
        // TODO(question):
        // Whoa... is there a better way to do this?
        bytes4 selector = bytes4(keccak256("NotApproved(string)"));
        vm.expectRevert(abi.encodeWithSelector(selector, "Meow"));
        favRecords.addRecord("Meow");

        // 4. Add another approved record, should return both
        favRecords.addRecord("Thriller");
        string[] memory favs2 = favRecords.getUserFavorites(addr);

        assertEq(favs2.length, 2);
        assertEq(favs2[0], "Thriller");
        assertEq(favs2[1], "Rumours");

        vm.stopPrank();

        // 5. Add record to another address, should not cris-cross
        address addr2 = address(0x9876543210999999999999999999999999999999);
        vm.startPrank(addr2);
        favRecords.addRecord("Hotel California");
        string[] memory favsOfAddr1 = favRecords.getUserFavorites(addr);
        string[] memory favsOfAddr2 = favRecords.getUserFavorites(addr2);
        assertEq(favsOfAddr1.length, 2);
        assertEq(favsOfAddr1[0], "Thriller");
        assertEq(favsOfAddr1[1], "Rumours");
        assertEq(favsOfAddr2.length, 1);
        assertEq(favsOfAddr2[0], "Hotel California");

        vm.stopPrank();

        // 6. Resetting one address succeeds, and should not affect others
        vm.startPrank(addr);
        favRecords.resetUserFavorites();
        string[] memory favs1OfAddr1 = favRecords.getUserFavorites(addr);
        string[] memory favs1OfAddr2 = favRecords.getUserFavorites(addr2);
        assertEq(favs1OfAddr1.length, 0);
        assertEq(favs1OfAddr2.length, 1);
        assertEq(favsOfAddr2[0], "Hotel California");

        vm.stopPrank();
    }

}
