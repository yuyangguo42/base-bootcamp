// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Employee {
    uint public idNumber;
    uint public managerId;

    constructor (uint _id, uint _managerId) {
        idNumber = _id;
        managerId = _managerId;
    }

    function getAnnualCost() public virtual view returns (uint cost);
}

contract Salaried is Employee {

    uint public annualSalary;

    constructor (uint _id, uint _managerId, uint _annualSalary) Employee(_id, _managerId) {
        annualSalary = _annualSalary;
    }

    function getAnnualCost() public override view returns (uint cost) {
        return annualSalary;
    }
}

contract Hourly is Employee {
    uint public hourlyRate;

    constructor (uint _id, uint _managerId, uint _hourlyRate) Employee(_id, _managerId) {
        hourlyRate = _hourlyRate;
    }

    function getAnnualCost() public override view returns (uint cost) {
        return hourlyRate * 2080;
    }
}

contract Manager {
    uint[] public reports;

    function addReport(uint _reportId) public {
        reports.push(_reportId);
    }

    function resetReports() public {
        delete reports;
    }
}

contract Salesperson is Hourly {
    constructor (uint _id, uint _managerId, uint _hourlyRate) Hourly (_id, _managerId, _hourlyRate) {
    }
}

contract EngineeringManager is Salaried, Manager {
    constructor (uint _id, uint _managerId, uint _annualSalary) Salaried (_id, _managerId, _annualSalary) {
    }
}

contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}
