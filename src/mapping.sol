// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FavoriteRecords {
    mapping (address => mapping (string => bool)) userFavorites;
    mapping (string => bool) public approvedRecords;
    string[] allRecords;
    string[] allFavoritedRecords;

    error NotApproved(string _record);

    constructor () {
        approvedRecords["Thriller"] = true;
        approvedRecords["Back in Black"] = true;
        approvedRecords["Back in Black"] = true;
        approvedRecords["The Bodyguard"] = true;
        approvedRecords["The Dark Side of the Moon"] = true;
        approvedRecords["Their Greatest Hits (1971-1975)"] = true;
        approvedRecords["Hotel California"] = true;
        approvedRecords["Come On Over"] = true;
        approvedRecords["Rumours"] = true;
        approvedRecords["Saturday Night Fever"] = true;

        allRecords = [
            "Thriller",
            "Back in Black",
            "The Bodyguard",
            "The Dark Side of the Moon",
            "Their Greatest Hits (1971-1975)",
            "Hotel California",
            "Come On Over",
            "Rumours",
            "Saturday Night Fever"
        ];
    }

    function getApprovedRecords() external view returns (string[] memory records) {
        return allRecords;
    }

    function addRecord(string calldata _record) external {
        if (!approvedRecords[_record]) {
            revert NotApproved(_record);
        }
        userFavorites[msg.sender][_record] = true;
    }

    function getUserFavorites(address _addr) external view returns (string[] memory _records) {

        uint count = 0;
        // TODO: test whether loading the allRecords into memory is cheaper, or doing index access directly on storage is cheaper
        string[] memory records = allRecords;
        for (uint i=0; i < allRecords.length; i++) {
            if (userFavorites[_addr][records[i]]) {
                count++;
            }
        }

        string[] memory res = new string[](count);

        uint idx = 0;
        for (uint i=0; i < allRecords.length; i++) {
            string memory record = records[i];
            if (userFavorites[_addr][record]) {
                res[idx] = record;
                idx++;
            }
        }
        return res;
    }

    function resetUserFavorites() external {
        string[] memory records = allRecords;
        for (uint i=0; i < allRecords.length; i++) {
            userFavorites[msg.sender][records[i]] = false;
        }
    }
}
