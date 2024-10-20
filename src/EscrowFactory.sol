// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Escrow.sol";

contract EscrowFactory {
    address public owner;
    Escrow[] public escrows;

    event EscrowCreated(
        address indexed escrowAddress,
        address buyer,
        address seller,
        address arbiter
    );

    constructor() {
        owner = msg.sender;
    }

    function createEscrow(
        address _buyer,
        address _seller,
        address _arbiter
    ) external returns (address) {
        Escrow escrow = new Escrow(_buyer, _seller, _arbiter);
        escrows.push(escrow);
        emit EscrowCreated(address(escrow), _buyer, _seller, _arbiter);
        return address(escrow);
    }

    function getEscrows() external view returns (Escrow[] memory) {
        return escrows;
    }

    function getEscrow(uint256 index) external view returns (address) {
        require(index < escrows.length, "Index out of range");
        return address(escrows[index]);
    }
}
