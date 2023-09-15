// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

library AddrStructs {
    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
        bool isValid;
    }
}

contract AddressBook is Ownable {
    mapping (uint => AddrStructs.Contact) contacts;
    // Even if a contact is removed, the ID is not deleted from this array
    uint[] allHistoricIds;
    error ContactNotFound(uint _id);

    function addContact(
        uint _id,
        string calldata _firstName,
        string calldata _lastName,
        uint[] calldata _phoneNumbers
    ) public onlyOwner {
        contacts[_id] = AddrStructs.Contact(_id, _firstName, _lastName, _phoneNumbers, true);
        for (uint i=0; i<allHistoricIds.length; i++) {
            if (allHistoricIds[i] == _id) {
                // Already recorded, don't duplicate
                return;
            }
        }
        allHistoricIds.push(_id);
    }

    function deleteContact(uint _id) public onlyOwner {
        if (!contacts[_id].isValid) {
            revert ContactNotFound(_id);
        }

        contacts[_id].isValid = false;
    }

    function getContact(uint _id) public view returns (AddrStructs.Contact memory) {
        if (!contacts[_id].isValid) {
            revert ContactNotFound(_id);
        }

        return contacts[_id];
    }

    function getAllContacts() external view returns (AddrStructs.Contact[] memory) {
        uint count = 0;
        for (uint i=0; i<allHistoricIds.length; i++) {
            AddrStructs.Contact memory c = contacts[allHistoricIds[i]];
            if (c.isValid) {
                count++;
            }
        }

        AddrStructs.Contact[] memory result = new AddrStructs.Contact[](count);

        uint idx = 0;
        for (uint i=0; i<allHistoricIds.length; i++) {
            AddrStructs.Contact memory c = contacts[allHistoricIds[i]];
            if (c.isValid) {
                result[idx] = c;
                idx++;
            }
        }

        return result;

    }

}

contract AddressBookFactory {
    function deploy() external returns (AddressBook) {
        AddressBook ab = new AddressBook();
        ab.transferOwnership(msg.sender);
        return ab;
    }
}
