pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

contract EmployeeStorage {
    string public name;
    uint16 shares; // Value not expected to exceed 5000
    uint32 salary; // Value not expected to exceed 1,000,000, in dollars
    uint256 public idNumber; // Not sequential, thus need a full uint256

    error TooManyShares(uint16 _shares);

    constructor(uint16 _shares, string memory _name, uint32 _salary, uint256 _idNumber) {
        // Note: maybe should use `revert` if provided values are outside
        // of our expected range. But meh... not like it protects us against
        // uint overflow or anything so better save the gas...
        shares = _shares;
        name = _name;
        salary = _salary;
        idNumber = _idNumber;
    }

    function viewSalary() external view returns (uint32) {
        return salary;
    }

    function viewShares() external view returns (uint16) {
        return shares;
    }

    function grantShares(uint16 _newShares) external {
        // TODO - question for mentor:
        // 1. Do we really not store the 5000 as a constant in favor of saving gas?
        // 2. Here I am re-performing the addition over and over again since it
        //   is likely cheaper than creating a stack variable, or updating & reverting
        //   the storage value, is this the best practice?
        if (_newShares > 5000) {
            revert("Too many shares");
        }
        if (_newShares + shares > 5000) {
            revert TooManyShares(_newShares + shares);
        }
        shares += _newShares;
    }

    /**
    * Do not modify this function.  It is used to enable the unit test for this pin
    * to check whether or not you have configured your storage variables to make
    * use of packing.
    *
    * If you wish to cheat, simply modify this function to always return `0`
    * I'm not your boss ¯\_(ツ)_/¯
    *
    * Fair warning though, if you do cheat, it will be on the blockchain having been
    * deployed by you wallet....FOREVER!
    */
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload (_slot)
        }
    }

    /**
    * Warning: Anyone can use this function at any time!
    */
    function debugResetShares() public {
        shares = 1000;
    }
}
