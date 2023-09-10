pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {EngineeringManager, Hourly, Manager, Salaried, Salesperson} from "../src/06-inheritance.sol";

contract InheritanceTest is Test {
    Salaried public se;
    Hourly public he;
    Manager public mg;
    Salesperson public sp;
    EngineeringManager public em;

    function setUp() public {
        se = new Salaried(1, 2, 10000);
        he = new Hourly(3, 2, 42);
        mg = new Manager();
        sp = new Salesperson(51, 28, 80);
        em = new EngineeringManager(54321, 11111, 200000);
    }

    function test_Salaried() public {
        assertEq(se.getAnnualCost(), 10000);
        assertEq(se.idNumber(), 1);
        assertEq(se.managerId(), 2);
    }

    function test_Hourly() public {
        assertEq(he.getAnnualCost(), 42 * 2080);
        assertEq(he.idNumber(), 3);
        assertEq(he.managerId(), 2);
    }

    function test_Manager() public {
        helperTestManager(mg);
    }


    function test_Salesperson() public {
        assertEq(sp.getAnnualCost(), 80 * 2080);
        assertEq(sp.idNumber(), 51);
        assertEq(sp.managerId(), 28);
    }

    function helperTestManager(Manager m) internal {
        m.addReport(42);
        assertEq(m.reports(0), 42);

        m.addReport(84);
        assertEq(m.reports(0), 42);
        assertEq(m.reports(1), 84);

        m.resetReports();

        vm.expectRevert();
        m.reports(0);

        m.addReport(32);
        assertEq(m.reports(0), 32);
    }

    function test_EngineeringManager() public {
        assertEq(em.idNumber(), 54321);
        assertEq(em.managerId(), 11111);
        assertEq(em.annualSalary(), 200000);
        assertEq(em.getAnnualCost(), 200000);

        helperTestManager(em);
    }
}
