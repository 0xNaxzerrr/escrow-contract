// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow _escrow;
    address _buyer = address(0x1);
    address _seller = address(0x2);
    address _arbiter = address(0x3);

    function setUp() public {
        // Déployer l'instance de l'escrow avant chaque test
        _escrow = new Escrow(_buyer, _seller, _arbiter);
    }

    function testDeployment() public {
        // Vérifier que les adresses sont bien configurées
        assertEq(
            _escrow.getParticipants(),
            _buyer,
            _seller,
            _arbiter,
            "Incorrect address"
        );
    }

    function testGetParticipants() public {
        // Vérifier que les adresses des participants sont correctes
        (address buyer, address seller, address arbiter) = _escrow
            .getParticipants();
        assertEq(buyer, _buyer, "Incorrect buyer address");
        assertEq(seller, _seller, "Incorrect seller address");
        assertEq(arbiter, _arbiter, "Incorrect arbiter address");
    }
    function testTokenTransferredByBuyer() public {
        // Simuler l'envoi de fonds par le buyer
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();

        // Vérifier que le stage est bien passé à TokenTransferredByBuyer
        assertEq(
            uint(_escrow.getStage()),
            uint(Escrow.Stages.TokenTransferredByBuyer),
            "Stage should be TokenTransferredByBuyer"
        );
        assertEq(
            _escrow.getEscrowBalance(),
            1 ether,
            "Escrow balance should be 1 ether"
        );
    }

    function testOnlyBuyerCanTransferTokens() public {
        // Simuler l'envoi de fonds par une autre adresse que le buyer
        vm.prank(address(0x4));
        vm.expectRevert("Only buyer can call this function.");
        _escrow.tokenTransferredByBuyer{value: 1 ether}();
    }

    function testSellerCompletesDeal() public {
        // Passer le stage à TokenTransferredByBuyer
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();

        // Simuler la complétion du deal par le seller
        vm.prank(_seller);
        _escrow.sellerCompletedTheDeal();

        // Vérifier que le stage est bien passé à SellerCompletedTheDeal
        assertEq(
            uint(_escrow.getStage()),
            uint(Escrow.Stages.SellerCompletedTheDeal),
            "Stage should be SellerCompletedTheDeal"
        );
    }

    function testOnlySellerCanCompleteDeal() public {
        // Passer le stage à TokenTransferredByBuyer
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();

        // Tenter de compléter le deal depuis une autre adresse que le seller
        vm.prank(address(0x4));
        vm.expectRevert("Only seller can call this function.");
        _escrow.sellerCompletedTheDeal();
    }

    function testArbiterFinalizesToSeller() public {
        // Passer le stage à SellerCompletedTheDeal
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.prank(_seller);
        _escrow.sellerCompletedTheDeal();

        // Finaliser le deal vers le seller
        vm.prank(_arbiter);
        _escrow.finalizeTo(payable(_seller));

        // Vérifier que le stage est bien passé à Final
        assertEq(
            uint(_escrow.getStage()),
            uint(Escrow.Stages.Final),
            "Stage should be Final"
        );
        assertEq(
            _seller.balance,
            1 ether,
            "Seller should have received 1 ether"
        );
    }

    function testArbiterCancelsDeal() public {
        // Passer le stage à TokenTransferredByBuyer
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();

        // Annuler le deal depuis l'arbitre
        vm.prank(_arbiter);
        _escrow.cancel();

        // Vérifier que les fonds ont été renvoyés au buyer
        assertEq(
            _buyer.balance,
            1 ether,
            "Buyer should have received the refunded amount"
        );
        assertEq(
            uint(_escrow.getStage()),
            uint(Escrow.Stages.DealSetup),
            "Stage should be DealSetup"
        );
    }

    function testArbiterCannotCancelAfterFinal() public {
        // Passer le stage à Final
        vm.prank(_buyer);
        _escrow.tokenTransferredByBuyer{value: 1 ether}();
        vm.prank(_seller);
        _escrow.sellerCompletedTheDeal();
        vm.prank(_arbiter);
        _escrow.finalizeTo(payable(_seller));

        // Tenter d'annuler après finalisation
        vm.prank(_arbiter);
        vm.expectRevert("The deal is already finalized.");
        _escrow.cancel();
    }

    function testDestroy() public {
        // Passer le stage à GoodToDestruct
        vm.prank(_arbiter);
        _escrow.destroy();

        // Le contrat devrait être détruit, mais cela ne peut pas être directement vérifié par Foundry
        // car il n'y a pas d'état accessible après la destruction du contrat.
    }
}
