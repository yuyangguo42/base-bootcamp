pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

contract ArraysExercise {
    uint[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] senders;
    uint[] timestamps;
    uint afterY2KCount = 0;

    function getNumbers() external view returns (uint[] memory result) {
        result = numbers; // make a copy of storage array into memory to be returned
        return result;
    }

    function resetNumbers() external {
        numbers = [1,2,3,4,5,6,7,8,9,10];
    }

    function appendToNumbers(uint[] calldata _toAppend) external {
        for (uint i=0; i<_toAppend.length; i++) {
            numbers.push(_toAppend[i]);
        }
    }

    function saveTimestamp(uint _unixTimestamp) external {
        timestamps.push(_unixTimestamp);
        senders.push(msg.sender);
        if (_unixTimestamp > 946702800) { // Jan 1, 2000, 12:00am
            afterY2KCount++;
        }
    }

    function afterY2K() external view returns (uint[] memory _timestamps, address[] memory _senders) {
        uint cursor = 0;
        _timestamps = new uint[](afterY2KCount);
        _senders = new address[](afterY2KCount);
        for (uint i=0; i<timestamps.length; i++) {
            if (timestamps[i] > 946702800) { // Jan 1, 2000, 12:00am
                _timestamps[cursor] = timestamps[i];
                _senders[cursor] = senders[i];
                cursor++;
            }
        }
        return (_timestamps, _senders);
    }

    function resetSenders() external {
        delete senders;
        afterY2KCount = 0;
    }

    function resetTimestamps() external {
        delete timestamps;
        afterY2KCount = 0;
    }
}
