// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter;

    enum Stages {
        DealSetup,
        TokenTransferedByBuyer,
        SellerCompletedTheDeal,
        Final,
        GoodToDestruct
    }

    Stages public stage = Stages.DealSetup;

    modifier atStage(Stages _stage) {
        require(stage == _stage, "Wrong pooling stage. Action not allowed.");
        _;
    }

    event StageChanged(Stages stage);
    event Withdrawn(address buyer, uint256 amount);
    event Cancelled(address arbiter, uint256 amount);
    event Finalized(address arbiter, uint256 amount);
    event Destroyed(address arbiter, uint256 amount);

    constructor(address _buyer, address _seller, address _arbiter) {
        stage = Stages.DealSetup;
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }

    function tokenTransferedByBuyer() public atStage(Stages.DealSetup) {
        require(msg.sender == buyer, "Only buyer can call this function.");

        stage = Stages.TokenTransferedByBuyer;
        emit StageChanged(stage);
    }

    function sellerCompletedTheDeal()
        public
        atStage(Stages.TokenTransferedByBuyer)
    {
        require(msg.sender == seller, "Only seller can call this function.");

        stage = Stages.SellerCompletedTheDeal;
        emit StageChanged(stage);
    }

    function finalize() public atStage(Stages.SellerCompletedTheDeal) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");

        stage = Stages.Final;
        emit StageChanged(stage);
    }

    function getStage() public view returns (Stages) {
        return stage;
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }

    function getSeller() public view returns (address) {
        return seller;
    }

    function getArbiter() public view returns (address) {
        return arbiter;
    }

    function getEscrowBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public nonReentrant {
        require(msg.sender == buyer, "Only buyer can call this function.");
        require(stage == Stages.Final, "The deal is not finalized yet.");
        stage = Stages.Final;
        emit Withdrawn(buyer, address(this).balance);
        payable(buyer).transfer(address(this).balance);
        emit Withdrawn(buyer, address(this).balance);
    }

    function tokenTransferedByBuyer() public payable atStage(Stages.DealSetup) {
        require(msg.sender == buyer, "Only buyer can call this function.");
        require(msg.value > 0, "No funds sent.");
        stage = Stages.TokenTransferedByBuyer;
        emit StageChanged(stage);
    }

    function cancel() public {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        require(stage != Stages.Final, "The deal is already finalized.");

        payable(buyer).transfer(address(this).balance);
        stage = Stages.DealSetup;
        emit StageChanged(stage);
        emit Cancelled(arbiter, address(this).balance);
    }

    function finalizeToSeller() public atStage(Stages.SellerCompletedTheDeal) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        payable(seller).transfer(address(this).balance);
        emit Finalized(arbiter, address(this).balance);
        stage = Stages.Final;
        emit StageChanged(stage);
    }

    function finalizeToBuyer() public atStage(Stages.SellerCompletedTheDeal) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        payable(buyer).transfer(address(this).balance);
        emit Finalized(arbiter, address(this).balance);
        stage = Stages.Final;
        emit StageChanged(stage);
    }
    receive() external payable {}

    fallback() external payable {}

    function destroy() public atStage(Stages.GoodToDestruct) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        selfdestruct(payable(arbiter));
        emit Destroyed(arbiter, address(this).balance);
    }

    function destroyAndSend(
        address payable _recipient
    ) public atStage(Stages.GoodToDestruct) {
        require(msg.sender == arbiter, "Only arbiter can call this function.");
        selfdestruct(_recipient);
        emit Destroyed(arbiter, address(this).balance);
    }
}
