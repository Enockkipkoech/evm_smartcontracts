// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {GasManager} from "../src/GasManager.sol";

contract GasManagerScript is Script {
    GasManager public gasManager;
    // VARIABLES
    address public owner;

    function setUp() public {
        console.log("GasManagerScript setup & deploy");
        gasManager = new GasManager(3);
        owner = vm.envAddress("OWNER_ADDRESS");
        console.log("Owner address: ", owner);
    }

    function run() public {
        vm.startBroadcast();
        gasManager = new GasManager(6);
        console.log("Deploing GasManager contract with transaction fee at: ", address(gasManager));
        vm.stopBroadcast();
    }
}
