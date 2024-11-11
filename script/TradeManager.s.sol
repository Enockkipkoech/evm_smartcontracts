// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {TradeManager} from "../src/TradeManager.sol";

contract TradeManagerScript is Script {
    TradeManager public tradeManager;
    // VARIABLES
    address public LISK = vm.envAddress("LISK_ADDRESS");
    address public ROUTER = vm.envAddress("ROUTER_V2");

    address public owner;

    function setUp() public {
        console.log("GasManagerScript setup & deploy");
        tradeManager = new TradeManager(ROUTER, LISK);
        owner = vm.envAddress("OWNER_ADDRESS");
        console.log("Owner address: ", owner);
    }

    function run() public {
        vm.startBroadcast();
        tradeManager = new TradeManager(ROUTER, LISK);
        console.log("Deploing GasManager contract with transaction fee at: ", address(tradeManager));
        vm.stopBroadcast();
    }
}
