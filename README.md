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
![UML] TODO

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
- Owners Contract: `0x6170a32D6faf0518d85CbB335D06c3bd18D03Fb8`
- Rubie: `0xa8c30C39aB58a6751157fE2A022FA9Ef6F6895BC`
- Experience: `0xF39e17DBc734E163609F1B75988131096A5d9d32`
- Character: `0xE526958F4fd43C6876b8DD1e2E7C96093C58CFbC`
- Weapon: `0xCa537C1209667f8e2e761FBF95d0ED16A7690Ad6`


