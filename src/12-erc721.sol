// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

library HLib {
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }
}

contract HaikuNFT is ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;
    HLib.Haiku[] public haikus;
    mapping (address => EnumerableSet.UintSet) sharedHaikus;
    mapping (string => bool) usedLines;
    uint public counter;

    error HaikuNotUnique();
    error NotOwner();
    error NoHaikusShared();
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        counter = 1;
    }

    function mintHaiku(string memory line1, string memory line2, string memory line3) external {
        if (usedLines[line1] || usedLines[line2] || usedLines[line3]) {
            revert HaikuNotUnique();
        }

        usedLines[line1] = true;
        usedLines[line2] = true;
        usedLines[line3] = true;

        HLib.Haiku memory h = HLib.Haiku(msg.sender, line1, line2, line3);
        haikus.push(h);
        _safeMint(msg.sender, counter);
        counter++;
    }

    function shareHaiku(address _to, uint _id) external {
        if (ownerOf(_id) != msg.sender) {
            revert NotOwner();
        }
        sharedHaikus[_to].add(_id);
    }

    function getMySharedHaikus() external view returns (uint[] memory) {
        EnumerableSet.UintSet storage hks = sharedHaikus[msg.sender];
        if (hks.length() == 0) {
            revert NoHaikusShared();
        }
        return hks.values();
    }
}
