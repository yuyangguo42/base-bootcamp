pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {ImportExercise, StrUtil} from "../src/07-import.sol";

contract ImportExerciseTest is Test {
    ImportExercise public ex;

    function setUp() public {
        ex = new ImportExercise();
    }

    function test() public {
        string memory l1 = "Base BootCamp is cool";
        string memory l2 = "I learnt a lot fun things";
        string memory l3 = "So let's buidl more stuff";

        ex.saveHaiku(
            l1,
            l2,
            l3
        );

        StrUtil.Haiku memory haiku = ex.getHaiku();
        assertEq(haiku.line1, l1);
        assertEq(haiku.line2, l2);
        assertEq(haiku.line3, l3);

        StrUtil.Haiku memory sHaiku = ex.shruggieHaiku();
        assertEq(sHaiku.line1, l1);
        assertEq(sHaiku.line2, l2);
        assertEq(sHaiku.line3, unicode"So let's buidl more stuff 🤷");
    }
}
