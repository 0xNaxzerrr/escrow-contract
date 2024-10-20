// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EscrowFactory.sol";
import "../src/Escrow.sol";

contract EscrowFactoryTest is Test {
    EscrowFactory _factory;
    address _buyer = address(0x1);
    address _seller = address(0x2);
    address _arbiter = address(0x3);

    function setUp() public {
        // Déployer l'instance de la factory avant chaque test
        _factory = new EscrowFactory();
    }

    function testCreateEscrowEmitsEvent() public {
        // Act & Assert: Vérifier que l'événement `EscrowCreated` est bien émis
        vm.expectEmit(true, true, true, true);
        emit EscrowFactory.EscrowCreated(address(0), _buyer, _seller, _arbiter); // Spécifier l'événement attendu

        // Appel de la fonction qui devrait émettre l'événement
        _factory.createEscrow(_buyer, _seller, _arbiter);
    }

    function testCreateEscrow() public {
        // Act: Créer un nouvel escrow via la factory
        address escrowAddress = _factory.createEscrow(
            _buyer,
            _seller,
            _arbiter
        );

        // Assert: Vérifier que l'instance d'escrow a bien été créée
        assertTrue(
            escrowAddress != address(0),
            "Escrow address should not be zero"
        );

        // Vérifier que l'instance d'escrow est bien enregistrée dans le tableau `escrows`
        Escrow escrow = Escrow(_factory.getEscrow(0));
        assertEq(address(escrow), escrowAddress, "Escrow address mismatch");
    }

    function testGetEscrows() public {
        // Act: Créer plusieurs instances d'escrow
        _factory.createEscrow(_buyer, _seller, _arbiter);
        _factory.createEscrow(_buyer, _seller, _arbiter);

        // Assert: Vérifier que les escrows sont bien enregistrés
        Escrow[] memory escrows = _factory.getEscrows();
        assertEq(escrows.length, 2, "Should have created 2 escrows");
    }

    function testEscrowDetails() public {
        // Act: Créer un nouvel escrow et récupérer ses détails
        address escrowAddress = _factory.createEscrow(
            _buyer,
            _seller,
            _arbiter
        );
        Escrow escrow = Escrow(escrowAddress);

        // Assert: Vérifier les informations initiales de l'escrow
        assertEq(escrow.getBuyer(), _buyer, "Buyer address mismatch");
        assertEq(escrow.getSeller(), _seller, "Seller address mismatch");
        assertEq(escrow.getArbiter(), _arbiter, "Arbiter address mismatch");
    }

    function testOnlyOwnerCanCreate() public {
        // Arrange: Définir un utilisateur non propriétaire
        address nonOwner = address(0x4);

        // Act & Assert: Vérifier que seul le propriétaire peut créer des escrows
        vm.prank(nonOwner);
        vm.expectRevert(); // Revert attendu car nonOwner n'est pas le propriétaire
        _factory.createEscrow(_buyer, _seller, _arbiter);
    }
}
