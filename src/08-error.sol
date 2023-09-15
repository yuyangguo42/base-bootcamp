// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * Finds the difference between each uint with it's neighbor (a to b, b to c, etc.)
     * and returns a uint array with the absolute integer difference of each pairing.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);

        results[0] = _absDiff(_a, _b);
        results[1] = _absDiff(_b, _c);
        results[2] = _absDiff(_c, _d);

        return results;
    }

    function _absDiff(uint _a, uint _b) private pure returns (uint) {
        unchecked {
            return _a > _b ? _a-_b : _b-_a;
        }
    }

    /**
     * Changes the _base by the value of _modifier.  Base is always > 1000.  Modifiers can be
     * between positive and negative 100;
     */
    error ModifierCausesOverflow(uint _base, int _modifier);

    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint) {
        if (_modifier > 0 && type(uint).max - _base < uint(_modifier)) {
            // eh not sure what the behavior here should be, throw?
            revert ModifierCausesOverflow(_base, _modifier);
        }
        return uint(int(_base) + _modifier);
    }

    /**
     * Pop the last element from the supplied array, and return the modified array and the popped
     * value (unlike the built-in function)
     */
    uint[] arr;
    error ArrayEmpty();
    function popWithReturn() public returns (uint) {
        if (arr.length == 0) {
            revert ArrayEmpty();
        }
        uint result = arr[arr.length-1];
        arr.pop();
        return result;
    }

    // The utility functions below are working as expected
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function resetArr() public {
        delete arr;
    }
}

