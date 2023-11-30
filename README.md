# Rubie World

## Autores
Nicolás Andreoli - 210630
Pablo Pereyra - 234636
Elisa Montaña - 262763

## Descripción
Este proyecto consta de una Dapp programada en Solidity que modela un sistema de tokens para representar personajes y assets de un videojuego basado en Blockchain. Los jugadores podrán comprar Rubies con ETH, la moneda media de pago de la economía del juego, luego con dichas monedas podrán comprar Experience y Weapons. Luego también pueden comprar Characters con ETH, y equiparle las Weapons ya compradas. Por último, los owners del protocolo podrán mintear Characters y Weapons especiales, y recibirán ganancias a medida que los jugadores utilicen la Blockchain que luego las van a poder recolectar desde el Owners Contract.

## Testing coverage
Hicimos mucho esfuerzo por testear la mayoría de las funcionalidades. Tenemos 127 tests corriendo OK y una cobertura formidable:

![Cobertura](/assets/TestCoverage.png)

Donde estamos más flojo es en el ERC721TokenReceiver ya que para cubrir sus líneas deberíamos emular ser un Contrato Inteligenente.

## Abstracciones
Utilizamos muchas abstracciones de ERC721 y ERC20 ya que muchas funcionalidades se repetían entre los contratos:

![ERC20](/assets/ERC20.png)
![ERC721](/assets/ERC721.png)
![Owners Contract](/assets/OwnersContract.png)

## Diagrama UML
![UML](/assets/UML.png)

## Setup

### Backend

Correr los siguiente comandos para setupear el entorno:

1. `npm i`
2. `npx hardhat compile`

Luego, para correr tests y covertura:

3. `npx hardhat test`
4. `npx hardhat coverage`


### Frontend

Recordar copiar los abis finales en `apps/src/constants/contracts.js`, luego correr:

1. `cd app`
2. `npm i`
3. `npm run dev`

## Deploy
1. Copiar el .env.example y renombrarlo a .env
2. Completar los datos del .env correctamente
3. Correr el comando `npx hardhat run scripts/deploy.js --network sepolia`

![Deployed Contracts](/assets/DeployedContracts.png)

![Deployed Sepolia Transactions] TODO

## Address de los contratos deployados
- Owners Contract: `0x9949593319B6a1F6e495Bb0db206b34400eA847b`
- Rubie: `0x54CD8B3968F4389f184806B8CCCdfbC651fb6F93`
- Experience: `0x44CdE851eA6205bB7AD7F36520EA8aBB9dd1709a`
- Character: `0xD811859E48c7E97fBdBd8242E36CBcD049bBF5b6`
- Weapon: `0xd999669f0a63fF62064C8088cf0330c86Ea17dad`

