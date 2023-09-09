// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library GarageStructs {
    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }
}

contract GarageManager {
    error BadCarIndex(uint idx);

    mapping(address => GarageStructs.Car[]) garage;

    function addCar(string memory make, string memory model, string memory color, uint numberOfDoors) external {
        garage[msg.sender].push(GarageStructs.Car(make, model, color, numberOfDoors));
    }

    function getMyCars() external view returns (GarageStructs.Car[] memory cars) {
        return garage[msg.sender];
    }

    function getUserCars(address addr) external view returns (GarageStructs.Car[] memory cars) {
        return garage[addr];
    }

    function updateCar(
        uint idx,
        string memory make,
        string memory model,
        string memory color,
        uint numberOfDoors
    ) external {
        if (!(idx < garage[msg.sender].length)) {
            revert BadCarIndex(idx);
        }

        garage[msg.sender][idx] = GarageStructs.Car(make, model, color, numberOfDoors);
    }

    function resetMyGarage() external {
        delete garage[msg.sender];
    }
}
