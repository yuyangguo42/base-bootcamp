pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {ErrorTriageExercise} from "../src/08-error.sol";

contract ErrorTriaageExerciseTest is Test {
    ErrorTriageExercise public et;

    function setUp() public {
        et = new ErrorTriageExercise();
    }

    function testDiffWithNeighbor() public {
        // Normal test with both positive and negative diff
        uint[] memory res = et.diffWithNeighbor(5, 2, 8, 3);
        assertEq(res[0], 3);
        assertEq(res[1], 6);
        assertEq(res[2], 5);

        // Edge case test with large values
        uint[] memory res2 = et.diffWithNeighbor(1, type(uint).max, type(uint).max-100, 200);
        assertEq(res2[0], type(uint).max - 1);
        assertEq(res2[1], 100);
        assertEq(res2[2], type(uint).max - 300);
    }

    function testApplyModifier() public {
        assertEq(et.applyModifier(1000, -100), 900);
        assertEq(et.applyModifier(1000, 100), 1100);
        assertEq(et.applyModifier(type(uint).max-101, 100), type(uint).max-1);
        assertEq(et.applyModifier(type(uint).max-1, -100), type(uint).max-101);

        vm.expectRevert();
        et.applyModifier(type(uint).max-1, 100);
    }

    function testPopWithReturn() public {
        vm.expectRevert();
        et.popWithReturn();

        et.addToArr(42);
        assertEq(et.popWithReturn(), 42);

        for (uint8 i=0; i<10; i++) {
            et.addToArr(i);
        }
        for (uint8 r=9; r!=0; r--) {
            assertEq(et.popWithReturn(), r);
        }
    }
}
