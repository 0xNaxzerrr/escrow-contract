// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard {
    address public buyer;
    address public seller;
    address public arbiter;

    enum Stages {
        DealSetup,
        TokenTransferredByBuyer,
        SellerCompletedTheDeal,
        Final,
        GoodToDestruct
    }

    Stages public stage = Stages.DealSetup;

    modifier atStage(Stages _stage) {
        require(stage == _stage, "Wrong stage. Action not allowed.");
        _;
    }

    event StageChanged(Stages stage);
    event Withdrawn(address indexed buyer, uint256 amount);
    event Cancelled(address indexed arbiter, uint256 amount);
    event Finalized(address indexed arbiter, address recipient, uint256 amount);
    event Destroyed(address indexed arbiter, uint256 amount);

    constructor(address _buyer, address _seller, address _arbiter) {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }

    function getStage() external view returns (Stages) {
        return stage;
    }

    function getEscrowBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function tokenTransferredByBuyer()
        external
        payable
        atStage(Stages.DealSetup)
    {
        require(msg.sender == buyer, "Only buyer can call this function.");
        require(msg.value > 0, "No funds sent.");
        stage = Stages.TokenTransferredByBuyer;
        emit StageChanged(stage);
    }

    function sellerCompletedTheDeal()
        external
        atStage(Stages.TokenTransferredByBuyer)
    {
        require(msg.sender == seller, "Only seller can call this function.");
        stage = Stages.SellerCompletedTheDeal;
        emit StageChanged(stage);
    }

    function finalizeTo(
        address payable recipient
    ) external atStage(Stages.SellerCompletedTheDeal) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        uint256 balance = address(this).balance;
        stage = Stages.Final;
        emit StageChanged(stage);
        emit Finalized(arbiter, recipient, balance);
        recipient.transfer(balance);
    }

    function withdraw() external nonReentrant atStage(Stages.Final) {
        require(msg.sender == buyer, "Only buyer can call this function.");
        uint256 balance = address(this).balance;
        emit Withdrawn(buyer, balance);
        payable(buyer).transfer(balance);
    }

    function cancel() external {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        require(stage != Stages.Final, "The deal is already finalized.");
        uint256 balance = address(this).balance;
        stage = Stages.DealSetup;
        emit StageChanged(stage);
        emit Cancelled(arbiter, balance);
        payable(buyer).transfer(balance);
    }

    function destroy() external atStage(Stages.GoodToDestruct) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        uint256 balance = address(this).balance;
        emit Destroyed(arbiter, balance);
        selfdestruct(payable(arbiter));
    }

    function destroyAndSend(
        address payable _recipient
    ) external atStage(Stages.GoodToDestruct) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        uint256 balance = address(this).balance;
        emit Destroyed(arbiter, balance);
        selfdestruct(_recipient);
    }

    receive() external payable {
        require(
            stage == Stages.DealSetup,
            "Cannot accept funds at this stage."
        );
    }

    fallback() external payable {
        require(
            stage == Stages.DealSetup,
            "Cannot accept funds at this stage."
        );
    }
}
