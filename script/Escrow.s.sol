// script/Escrow.s.sol
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowScript is Script {
    Escrow public escrow;

    address _buyer = address(0x1);
    address _seller = address(0x2);
    address _arbiter = address(0x3);

    function run() public {
        vm.startBroadcast();

        escrow = new Escrow(_buyer, _seller, _arbiter);

        vm.stopBroadcast();
    }
}
