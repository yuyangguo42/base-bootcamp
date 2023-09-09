pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {GarageStructs, GarageManager} from "../src/05-struct.sol";

contract GarageManagerTest is Test {
    GarageManager public gm;

    function setUp() public {
        gm = new GarageManager();
    }

    function test_addGetUpdateCar() public {
        address addr = address(0x1234567890123456789012345678901234567890);
        vm.startPrank(addr);

        // Empty
        GarageStructs.Car[] memory cars = gm.getMyCars();
        assertEq(cars.length, 0);

        // Add Car
        gm.addCar("Nissan", "Rogue", "Gray", 4);

        GarageStructs.Car[] memory cars2 = gm.getMyCars();
        assertEq(cars2.length, 1);

        // Update with bad index
        bytes4 selector = bytes4(keccak256("BadCarIndex(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 1));
        gm.updateCar(1, "BMW", "iX", "Red", 8);

        // Update valid car
        gm.updateCar(0, "BMW", "iX", "Red", 8);
        GarageStructs.Car[] memory cars3 = gm.getMyCars();
        assertEq(cars3.length, 1);
        assertEq(cars3[0].make, "BMW");
        assertEq(cars3[0].model, "iX");

        vm.stopPrank();

        // Update with a different user
        address addr2 = address(0x9876543210999999999999999999999999999999);
        vm.startPrank(addr2);

        gm.addCar("Bently", "GTC", "Black", 42);
        gm.addCar("Porche", "Taycan", "Yellow", 2);

        GarageStructs.Car[] memory carsOfAddr2 = gm.getMyCars();
        assertEq(carsOfAddr2.length, 2);

        GarageStructs.Car[] memory carsOfAddr1 = gm.getUserCars(addr);
        assertEq(carsOfAddr1.length, 1);


        // Reset
        vm.startPrank(addr);
        gm.resetMyGarage();
        GarageStructs.Car[] memory cars4 = gm.getMyCars();
        assertEq(cars4.length, 0);
    }

}
