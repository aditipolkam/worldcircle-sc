// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {WorldCircle} from "../src/WorldCircle.sol";

contract WorldCircleScript is Script {
    WorldCircle public worldCircle;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        worldCircle = new WorldCircle();

        vm.stopBroadcast();
    }
}
