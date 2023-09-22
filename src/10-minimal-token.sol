// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract UnburnableToken {
    uint public totalSupply;
    uint public totalClaimed;
    mapping (address => uint) public balances;
    mapping (address => bool) claimed;

    error TokensClaimed();
    error AllTokensClaimed();
    error UnsafeTransfer(address _to);

    constructor () {
        totalSupply = 100_000_000;
    }

    function claim() public {
        if (claimed[msg.sender]) {
            revert TokensClaimed();
        }

        if (totalClaimed == totalSupply) {
            revert AllTokensClaimed();
        }

        claimed[msg.sender] = true;
        totalClaimed += 1000;
        balances[msg.sender] += 1000;
    }

    function safeTransfer(address _to, uint _amount) public {
        if (_to == address(0)) {
            revert UnsafeTransfer(_to);
        }
        uint currentBalance = balances[msg.sender];
        if (currentBalance < _amount) {
            revert UnsafeTransfer(_to);
        }

        if (_to.balance == 0) {
            revert UnsafeTransfer(_to);
        }

        balances[msg.sender] = currentBalance - _amount;
        balances[_to] += _amount;
    }
}
