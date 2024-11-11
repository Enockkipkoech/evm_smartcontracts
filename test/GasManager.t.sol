// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

import {GasManager} from "../src/GasManager.sol";
import {Test, console} from "forge-std/Test.sol";

contract GasManagerTest is Test {
    // SetUp
    GasManager public gasManager;

    function setUp() public {
        console.log("GasManagerTest");
        gasManager = new GasManager(3);
    }

    function testSetTransactionFee() public view {
        uint256 gasFee = gasManager.setTransactionFee(6000);
        assert(gasFee > 0);
        console.log("Gas Fee: ", gasFee);
    }
}
