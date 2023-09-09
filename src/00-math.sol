pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

contract BasicMath {
    // @notice Perform addition between two uints with overflow check
    // @return (sum, false) if no overflow, (0, true) if overflows
    function adder(uint _a, uint _b) external pure returns (uint sum, bool error) {
        if (_a > type(uint).max - _b) {
            // Addition will cause overflow
            return (0, true);
        }
        return (_a + _b, false);
    }

    // @notice Perform substraction between two uints with underflow check
    // @return (difference, false) if no underflow, (0, true) if overflows
    function subtractor(uint _a, uint _b) external pure returns (uint difference, bool error) {
        if (_a < _b) {
            // Substracton will underflow
            return (0, true);
        }
        return (_a - _b, false);
    }
}
