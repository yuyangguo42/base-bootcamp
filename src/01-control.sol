pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

contract ControlStructures {
    error AfterHours(uint _time);

    function fizzBuzz(uint _number) external pure returns (string memory) {
        if (_number % 3 == 0 && _number % 5 == 0) {
            return "FizzBuzz";
        } else if (_number % 3 == 0) {
            return "Fizz";
        } else if (_number % 5 == 0) {
            return "Buzz";
        } else {
            return "Splat";
        }
    }

    function doNotDisturb(uint _time) external pure returns (string memory) {
        assert(_time < 2400);
        if (_time < 800 || _time > 2200) {
            revert AfterHours(_time);
        } else if (_time < 1200) {
            return "Morning!";
        } else if (_time < 1300) {
            revert("At lunch!");
        } else if (_time < 1800) {
            return "Afternoon!";
        } else {
            return "Evening!";
        }
    }
}
