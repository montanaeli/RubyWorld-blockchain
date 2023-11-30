# Rubie World

## Autores
Nicolás Andreoli - 210630
Pablo Pereyra - 234636
Elisa Montaña - 262763

## Descripción
Este proyecto consta de una Dapp programada en Solidity que modela un sistema de tokens para representar personajes y assets de un videojuego basado en Blockchain. Los jugadores podrán comprar Rubies con ETH, la moneda media de pago de la economía del juego, luego con dichas monedas podrán comprar Experience y Weapons. Luego también pueden comprar Characters con ETH, y equiparle las Weapons ya compradas. Por último, los owners del protocolo podrán mintear Characters y Weapons especiales, y recibirán ganancias a medida que los jugadores utilicen la Blockchain que luego las van a poder recolectar desde el Owners Contract.


## Abstracciones
Utilizamos muchas abstracciones de ERC721 y ERC20 ya que muchas funcionalidades se repetían entre los contratos:

![ERC20](/assets/ERC20.png)
![ERC721](/assets/ERC721.png)
![Owners Contract](/assets/OwnersContract.png)

## Diagrama UML
TODO

## Setup
1. `npm i`
2. `npx hardhat compile`
3. `npx hardhat test`

## Deploy
1. Copiar el .env.example y renombrarlo a .env
2. Completar los datos del .env correctamente
3. Correr el comando `npx hardhat run scripcs/deploy.js --network sepolia`

## Address de los contratos deployados
- Owners Contract: `TODO`
- Rubie: `TODO`
- Experience: `TODO`
- Character: `TODO`
- Weapon: `TODO`

