// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Escrow {

    enum Stages {
        DealSetup,
        TokenTransferedByBuyer,
        SellerCompletedTheDeal,
        Final
    }

    Stages public stage = Stages.DealSetup;

    modifier atStage(Stages _stage) {
        require(stage == _stage, "Wrong pooling stage. Action not allowed.");
        _;
    }

    constructor(address _buyer, address _seller, address _arbiter) {
        
    }

}
