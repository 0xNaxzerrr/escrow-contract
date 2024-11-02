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

    function testCreateEscrow() public {
        // Act: Créer un nouvel escrow via la factory
        address payable escrowAddress = payable(
            _factory.createEscrow(_buyer, _seller, _arbiter)
        );

        // Assert: Vérifier que l'instance d'escrow a bien été créée
        assertTrue(
            escrowAddress != address(0),
            "Escrow address should not be zero"
        );

        // Vérifier que l'instance d'escrow est bien enregistrée dans le tableau `escrows`
        Escrow escrow = Escrow(escrowAddress);
        assertEq(address(escrow), escrowAddress, "Escrow address mismatch");
    }

    function testGetEscrows() public {
        // Act: Créer plusieurs instances d'escrow
        _factory.createEscrow(_buyer, _seller, _arbiter);
        _factory.createEscrow(_buyer, _seller, _arbiter);

        // Assert: Vérifier que les escrows sont bien enregistrés
        assertEq(
            _factory.getEscrows().length,
            2,
            "Should have created 2 escrows"
        );
    }

    function testEscrowDetails() public {
        // Act: Créer un nouvel escrow et récupérer ses détails
        address payable escrowAddress = payable(
            _factory.createEscrow(_buyer, _seller, _arbiter)
        );
        Escrow _escrow = Escrow(escrowAddress);

        // Assert: Vérifier les informations initiales de l'escrow
        (address buyer, address seller, address arbiter) = _escrow
            .getParticipants();

        assertEq(buyer, _buyer, "Buyer address mismatch");
        assertEq(seller, _seller, "Seller address mismatch");
        assertEq(arbiter, _arbiter, "Arbiter address mismatch");
    }

    function testOnlyOwnerCanCreate() public {
        // Arrange: Définir un utilisateur non propriétaire
        address nonOwner = address(0x4);

        // Act & Assert: Vérifier que seul le propriétaire peut créer des escrows
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        _factory.createEscrow(_buyer, _seller, _arbiter);
    }
}
