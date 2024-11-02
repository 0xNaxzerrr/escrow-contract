// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow escrow;
    address buyer = address(0x1);
    address seller = address(0x2);
    address arbiter = address(0x3);

    function setUp() public {
        escrow = new Escrow(buyer, seller, arbiter);
    }

    function testGetParticipants() public {
        (address _buyer, address _seller, address _arbiter) = escrow
            .getParticipants();
        assertEq(_buyer, buyer, "Incorrect buyer address");
        assertEq(_seller, seller, "Incorrect seller address");
        assertEq(_arbiter, arbiter, "Incorrect arbiter address");
    }

    function testOnlyBuyerCanTransferTokens() public {
        vm.startPrank(buyer);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
        assertEq(
            uint256(escrow.getStage()),
            uint256(Escrow.Stages.TokenTransferredByBuyer),
            "Stage mismatch after transfer by buyer"
        );

        vm.stopPrank();
        vm.expectRevert("Only buyer can call this function.");
        vm.prank(seller);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
    }

    function testOnlySellerCanCompleteDeal() public {
        vm.startPrank(buyer);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(seller);
        escrow.sellerCompletedTheDeal();
        assertEq(
            uint256(escrow.getStage()),
            uint256(Escrow.Stages.SellerCompletedTheDeal),
            "Stage mismatch after seller completion"
        );

        vm.stopPrank();
        vm.expectRevert("Only seller can call this function.");
        vm.prank(buyer);
        escrow.sellerCompletedTheDeal();
    }

    function testArbiterFinalizesToSeller() public {
        vm.startPrank(buyer);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(seller);
        escrow.sellerCompletedTheDeal();
        vm.stopPrank();

        vm.startPrank(arbiter);
        escrow.finalizeTo(payable(seller));
        assertEq(
            uint256(escrow.getStage()),
            uint256(Escrow.Stages.Final),
            "Stage mismatch after arbiter finalization"
        );
        assertEq(seller.balance, 1 ether, "Seller did not receive funds");
    }

    function testArbiterCannotCancelAfterFinal() public {
        vm.startPrank(buyer);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(seller);
        escrow.sellerCompletedTheDeal();
        vm.stopPrank();

        vm.startPrank(arbiter);
        escrow.finalizeTo(payable(seller));
        vm.stopPrank();

        vm.expectRevert("The deal is already finalized.");
        vm.prank(arbiter);
        escrow.cancel();
    }

    function testArbiterCancelsDeal() public {
        vm.startPrank(buyer);
        escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(arbiter);
        escrow.cancel();
        assertEq(
            uint256(escrow.getStage()),
            uint256(Escrow.Stages.DealSetup),
            "Stage mismatch after arbiter cancels"
        );
        assertEq(
            buyer.balance,
            1 ether,
            "Buyer did not receive refunded funds"
        );
    }
}
