// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EscrowFactory.sol";
import "../src/Escrow.sol";

contract EscrowFactoryTest is Test {
    EscrowFactory factory;
    address buyer = address(0x1);
    address seller = address(0x2);
    address arbiter = address(0x3);

    function setUp() public {
        // Déployer l'instance de la factory avant chaque test
        factory = new EscrowFactory();
    }

    function testCreateEscrow() public {
        // Act: Créer un nouvel escrow via la factory
        address escrowAddress = factory.createEscrow(buyer, seller, arbiter);

        // Assert: Vérifier que l'instance d'escrow a bien été créée
        assertTrue(
            escrowAddress != address(0),
            "Escrow address should not be zero"
        );

        // Vérifier que l'instance d'escrow est bien enregistrée dans le tableau `escrows`
        Escrow escrow = Escrow(factory.getEscrow(0));
        assertEq(address(escrow), escrowAddress, "Escrow address mismatch");
    }

    function testGetEscrows() public {
        // Act: Créer plusieurs instances d'escrow
        factory.createEscrow(buyer, seller, arbiter);
        factory.createEscrow(buyer, seller, arbiter);

        // Assert: Vérifier que les escrows sont bien enregistrés
        Escrow[] memory escrows = factory.getEscrows();
        assertEq(escrows.length, 2, "Should have created 2 escrows");
    }

    function testEscrowDetails() public {
        // Act: Créer un nouvel escrow et récupérer ses détails
        address escrowAddress = factory.createEscrow(buyer, seller, arbiter);
        Escrow escrow = Escrow(escrowAddress);

        // Assert: Vérifier les informations initiales de l'escrow
        assertEq(escrow.getBuyer(), buyer, "Buyer address mismatch");
        assertEq(escrow.getSeller(), seller, "Seller address mismatch");
        assertEq(escrow.getArbiter(), arbiter, "Arbiter address mismatch");
    }

    function testOnlyOwnerCanCreate() public {
        // Arrange: Définir un utilisateur non propriétaire
        address nonOwner = address(0x4);

        // Act & Assert: Vérifier que seul le propriétaire peut créer des escrows
        vm.prank(nonOwner);
        vm.expectRevert(); // Revert attendu car nonOwner n'est pas le propriétaire
        factory.createEscrow(buyer, seller, arbiter);
    }

    function testCreateEscrowEmitsEvent() public {
        // Act & Assert: Vérifier que l'événement `EscrowCreated` est bien émis
        vm.expectEmit(true, true, true, true);
        emit EscrowCreated(address(0), buyer, seller, arbiter);
        factory.createEscrow(buyer, seller, arbiter);
    }
}
