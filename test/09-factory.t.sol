pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {AddressBook, AddressBookFactory, AddrStructs} from "../src/09-factory.sol";

contract FactoryExerciseTest is Test {
    AddressBook public ab;
    AddressBookFactory public abf;

    function setUp() public {
        vm.startPrank(address(42));
        ab = new AddressBook();
        abf = new AddressBookFactory();
        vm.stopPrank();
    }

    function testAddressBook() public {
        // Empty
        vm.startPrank(address(42));
        assertEq(ab.getAllContacts().length, 0);

        // Insert
        uint[] memory phone = new uint[](1);
        ab.addContact(0, "Katze", "Mr", phone);

        assertEq(ab.getAllContacts().length, 1);
        AddrStructs.Contact memory c = ab.getContact(0);
        assertEq(c.firstName, "Katze");

        // Delete
        ab.deleteContact(0);

        // GetInvalid (never added)
        vm.expectRevert();
        ab.getContact(3);

        // GetInvalid (deleted)
        vm.expectRevert();
        ab.getContact(0);

        // DeleteInvalid (never added)
        vm.expectRevert();
        ab.deleteContact(7);

        // DeleteInvalid (never added)
        vm.expectRevert();
        ab.deleteContact(0);

        // GetAllContacts
        assertEq(ab.getAllContacts().length, 0);

        ab.addContact(0, "Katze", "Mr", phone);
        assertEq(ab.getAllContacts().length, 1);

        ab.addContact(1, "Katze2", "Mr2", phone);
        ab.addContact(2, "Katze3", "Mr3", phone);
        ab.addContact(3, "Katze4", "Mr4", phone);
        ab.addContact(4, "Katze5", "Mr5", phone);

        assertEq(ab.getAllContacts().length, 5);

        ab.deleteContact(1);
        ab.deleteContact(4);
        assertEq(ab.getAllContacts().length, 3);


        ab.deleteContact(0);
        ab.deleteContact(2);
        ab.deleteContact(3);
        assertEq(ab.getAllContacts().length, 0);

        vm.stopPrank();

        // testNonOwner
        vm.startPrank(address(14));
        vm.expectRevert();
        ab.addContact(52, "Katze", "Mr", phone);
    }

    function testAddressBookFactory() public {
        address factoryOwner = address(42);
        address ab1Owner = address(98);
        address ab2Owner = address(97);
        address nobody = address(96);

        vm.startPrank(ab1Owner);
        AddressBook ab1 = abf.deploy();
        uint[] memory phone = new uint[](1);
        ab1.addContact(0, "Katze", "Mr", phone);

        vm.startPrank(ab2Owner);
        AddressBook ab2 = abf.deploy();
        ab2.addContact(0, "KatzeMeow", "MrMeow", phone);

        // Factory shouldn't have access
        vm.startPrank(factoryOwner);
        vm.expectRevert();
        ab1.deleteContact(0);
        vm.expectRevert();
        ab2.deleteContact(0);

        // Unrelated people shouldn't have access
        vm.startPrank(nobody);
        vm.expectRevert();
        ab1.deleteContact(0);
        vm.expectRevert();
        ab2.deleteContact(0);

        // Other owners shouldn't have access
        vm.startPrank(ab1Owner);
        vm.expectRevert();
        ab2.deleteContact(0);
        vm.startPrank(ab2Owner);
        vm.expectRevert();
        ab1.deleteContact(0);
    }

}
