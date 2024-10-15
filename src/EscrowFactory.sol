// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Escrow.sol";

contract EscrowFacotry {
    Escrow[] public EscrowArray;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function CreateNewEscrow(address _beneficiary, address _arbiter) public {
        Escrow escrow = new Escrow(_beneficiary, _arbiter);
        EscrowArray.push(escrow);
    }
}
