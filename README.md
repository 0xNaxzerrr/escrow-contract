# Escrow Smart Contract

**Escrow Smart Contract** est un contrat décentralisé construit en Solidity pour faciliter les transactions sécurisées entre un acheteur et un vendeur avec la participation d'un arbitre. Ce contrat garantit la sécurité des fonds lors des transactions en utilisant une logique de dépôt fiduciaire (escrow) et permet la résolution de litiges via un arbitre désigné.

## Table des matières

1. [Description](#description)
2. [Fonctionnalités](#fonctionnalités)
3. [Technologies Utilisées](#technologies-utilisées)
4. [Installation](#installation)
5. [Utilisation](#utilisation)
6. [Tests](#tests)
7. [Scripts](#scripts)
10. [License](#license)

## Description

Le contrat Escrow permet à un acheteur et un vendeur de sécuriser leurs transactions via un contrat intelligent. Les fonds sont verrouillés jusqu'à ce que l'acheteur confirme la réception de la marchandise ou que l'arbitre intervienne en cas de litige. Cette solution décentralisée apporte une sécurité accrue pour les transactions sans nécessiter de confiance préalable entre les parties.

## Fonctionnalités

- **Escrow sécurisé** : Les fonds sont bloqués dans le contrat jusqu'à la finalisation de la transaction.
- **Arbitrage** : Un arbitre peut intervenir pour annuler ou valider la transaction en cas de litige.
- **Gestion des étapes de transaction** : Le contrat passe par différentes étapes, de la configuration de l'accord à sa finalisation.
- **Annulation** : L'arbitre peut annuler la transaction et rembourser l'acheteur si nécessaire.
- **Finalisation** : L'arbitre peut transférer les fonds au vendeur une fois la transaction complétée.

## Technologies Utilisées

- **Solidity** : Langage de programmation pour le contrat intelligent.
- **Foundry** : Outil de développement et de test pour Solidity.
- **OpenZeppelin** : Bibliothèque de sécurité pour Solidity, notamment pour le modificateur `ReentrancyGuard`.

## Installation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/ton-utilisateur/escrow-contract.git
   cd escrow-contract
   ```

2. **Installer les dépendances** :
   ```bash
   forge install
   ``` 

3. **Compiler le contrat** :
    ```bash
    forge build
    ``` 

## Utilisatation

1. **Déploiement via Script** :
    ```bash
    forge script script/Escrow.s.sol:EscrowScript --broadcast --rpc-url <YOUR_RPC_URL>
    ```

2. **Interagir avec le Contrat** :
Une fois le contrat déployé, vous pouvez interagir avec ses fonctions principales :

- **`tokenTransferredByBuyer`** : Permet à l'acheteur de transférer des fonds dans l'escrow. Cette action marque le début de la transaction et verrouille les fonds.
    ```solidity
    escrow.tokenTransferredByBuyer{value: 1 ether}();
    ```

- **`sellerCompletedTheDeal`** : Le vendeur peut appeler cette fonction une fois qu'il a rempli sa part de l'accord, signalant que la transaction est prête à être finalisée.
    ```solidity
    escrow.sellerCompletedTheDeal();
    ```

- **`finalizeTo`** : L'arbitre utilise cette fonction pour finaliser la transaction en transférant les fonds au vendeur, clôturant ainsi la transaction.
    ```solidity
    escrow.finalizeTo(payable(seller));
    ```

- **`cancel`** : En cas de litige ou d'annulation, l'arbitre peut appeler cette fonction pour annuler la transaction et rembourser l'acheteur.

    ```solidity
    escrow.cancel();
    ```

## Tests

1. **Exécuter les tests** :
    ```bash
    forge test
    ```

2. **Couverture des tests** :
Couverture des tests : Les tests couvrent :

- La vérification des rôles et permissions pour l'acheteur, le vendeur et l'arbitre.
- Les transitions entre les différentes étapes de la transaction.
- Le transfert des fonds et les reverts attendus pour les appels non autorisés.

## Scripts

Le fichier `Escrow.s.sol` contient un script pour automatiser le déploiement du contrat `Escrow`. Ce script crée une nouvelle instance du contrat avec les adresses de l'acheteur, du vendeur et de l'arbitre définies dans le script.

### Lancer le Script de Déploiement

Pour déployer le contrat sur un réseau, utilisez la commande suivante. Assurez-vous de remplacer `<YOUR_RPC_URL>` par l'URL RPC de votre réseau cible (comme Infura ou Alchemy).

```bash
forge script script/Escrow.s.sol:EscrowScript --broadcast --rpc-url <YOUR_RPC_URL>
```

## License

Ce projet est sous licence MIT. Cela signifie que vous êtes libre d'utiliser, copier, modifier et distribuer ce logiciel, tant que vous incluez une copie de la licence MIT dans toute redistribution.

Veuillez consulter le fichier [LICENSE](LICENSE) pour plus de détails.