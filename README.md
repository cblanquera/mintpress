# Mintpress

ERC721 NFT for everything. Compatible is Rarible, Mintable, OpenSea. 
Can be deployed onto any Ethreum Layer 2 including Polygon and Binance 
Smart Chain.

## 1. Install

```bash
$ cp .env.sample to .env
$ npm install
```

## 2. Setup Development Test Wallet

Switch your MetaMask to Ropsten network and get some ETH from the faucet.

- [https://ipfs.io/ipfs/QmVAwVKys271P5EQyEfVSxm7BJDKWt42A2gHvNmxLjZMps/](https://ipfs.io/ipfs/QmVAwVKys271P5EQyEfVSxm7BJDKWt42A2gHvNmxLjZMps/)
- [https://faucet.dimensions.network/](https://faucet.dimensions.network/)
- [https://faucet.metamask.io/](https://faucet.metamask.io/)
- [https://faucet.ropsten.be/](https://faucet.ropsten.be/)
- [https://faucet.bitfwd.xyz/](https://faucet.bitfwd.xyz/)

For MATIC theres only one place,
[https://faucet.matic.network/](https://faucet.matic.network/). Make sure you
choose `mumbai` from the options.

> NOTE: You could be waiting between 10 to 30 minutes...

## 3. Unit Testing

Make sure in `.env`, change `NETWORK` to `hardhat`.

```bash
$ npm test
```

After running the tests you should see a gas chart. The last table 
below shows the estimated gas fees for running each function.

```
·--------------------------------|---------------------------|-------------|-----------------------------·
|      Solc version: 0.8.9       ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 12450000 gas  │
·································|···························|·············|······························
|  Methods                       ·              200 gwei/gas               ·       4563.48 usd/eth       │
··············|··················|·············|·············|·············|···············|··············
|  Contract   ·  Method          ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  allocate        ·      36422  ·     114186  ·      90340  ·            9  ·      82.45  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  deallocate      ·          -  ·          -  ·      25136  ·            1  ·      22.94  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  delist          ·          -  ·          -  ·      15517  ·            1  ·      14.16  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  exchange        ·      56937  ·     100907  ·      71594  ·            3  ·      65.34  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  lazyMint        ·      97947  ·     151764  ·     112037  ·            4  ·     102.26  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  list            ·          -  ·          -  ·      48178  ·            4  ·      43.97  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  mint            ·      94623  ·     145923  ·     138594  ·            7  ·     126.49  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  register        ·      47719  ·      70006  ·      67980  ·           11  ·      62.05  │
··············|··················|·············|·············|·············|···············|··············
|  Deployments                   ·                                         ·  % of limit   ·             │
·································|·············|·············|·············|···············|··············
|  Mintpress                     ·          -  ·          -  ·    3302492  ·       26.5 %  ·    3014.17  │
·--------------------------------|-------------|-------------|-------------|---------------|-------------·
```

## 4. Developing on a Local Host Node

Make sure in `.env`, change `NETWORK` to `localhost`. Then run the
ethereum node server in a separate terminal with the following command.

```bash
$ npx hardhat node

Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/
...
```

Next run the following script to deploy the contract to your local node and
pre-populate the storage.

```bash
$ npx hardhat run scripts/deploy-populate-script.js --network localhost

NFT contract deployed to (update .env): 0xCONTRACT_ADDRESS

Token Classes:

 - Class 1 has a limit of 10 tokens
   https://ipfs.io/ipfs/QmXrknumwVrvNhgPFUJSEoakGLsF4NJgQ6cgdx1SBA8PUJ
 - Class 2 has a limit of 3 tokens
   https://ipfs.io/ipfs/QmXbPZG5kcB9bzJRz6rdgKoDSTNAufMCRojZcaRtwigfmV

Fees:

 - 0xWALLET_ADDRESS_1 wants 20% of class 1
 - 0xWALLET_ADDRESS_2 wants 10% of class 1

Minted Tokens:

 - 0xWALLET_ADDRESS_3 owns token 1 in class 1
 - 0xWALLET_ADDRESS_4 owns token 2 in class 1
 - 0xWALLET_ADDRESS_3 owns token 3 in class 2
 - 0xWALLET_ADDRESS_4 owns token 4 in class 2

Air Drops:

 - 0xWALLET_ADDRESS_3 can redeem token 5 in class 1
 - 0xWALLET_ADDRESS_4 can redeem token 6 in class 1

Order Book:

 - 0xWALLET_ADDRESS_3 listed token 1 for sale for 0.001 ETH/MATIC
```

Lastly, copy the contract hash found in the results given after running 
`npx hardhat run scripts/deploy-populate-script.js --network localhost` 
and paste it in `.env`. Lastly run the following command.

```bash
$ npm run dev
```

## 5. Developing on Polygon MATIC TestNet

Make sure in `.env`, change `NETWORK` to `mumbai`.

Next run the following script to deploy the contract to your local node and
pre-populate the storage.

```bash
$ npx hardhat run scripts/deploy-script.js --network localhost
```

Lastly run the following command.

```bash
$ npm run dev
```

## API

The marketplace is the main contract that implements all the extensions.
Feel free to make your own version and use less or attach other ERC721
extensions to it. The following covers the methods defined in this 
contract.

### Deploy to Blockchain

 - **name (string):** ex. Your Project Title
 - **symbol (string):** ex. DEMO

```js
//load the factory
const NFT = await ethers.getContractFactory('ERC721Marketplace')
//deploy the contract
const nft = await NFT.deploy('Your Project Title', 'DEMO')
//wait for it to be confirmed
await nft.deployed()

console.log('Contract deployed to:', nft.address)
```

#### Contract Owner Actions

Only the contract owner can do the following actions. These are included in the
project's API.

##### Register

Registers a new `classId` with max token assignment `size` that
references a `uri`.

> A class ID does not need to be registered to use it in other methods.

`register(uint256 classId, uint256 size, string memory uri)`

 - **classId** - arbitrary class ID *(Should be unique)*
 - **size** - Max allowance of tokens that can be assigned
 - **uri** - Any URI that gives more details of this token class

```js
await nft.register(100, 200, 'ipfs://abc123')
```

##### Allocate

Sets a `fee` that will be paid to the `recipient` when a token in a `classId`
is exchanged.

`allocate(uint256 classId, address recipient, uint256 fee)`

 - **classId** - arbitrary class ID
 - **recipient** - Wallet address to pay when a token of the given class is exchanged
 - **fee** - The percent of the amount to give where 10000 means 100.00%

```js
await nft.allocate(100, '0xabc123', 1000) // 1000 is 10.00%
```

##### Deallocate

Removes a `recipient` from the fee table of a `classId`.

`deallocate(uint256 classId, address recipient)`

 - **classId** - arbitrary class ID
 - **recipient** - Wallet address to remove from the fee table

```js
await nft.deallocate(100, '0xabc123')
```

##### Mint

Mints `tokenId`, classifies it as `classId` and transfers to `recipient`.

`mint(uint256 classId, uint256 tokenId, address recipient)`

 - **classId** - arbitrary class ID
 - **tokenId** - arbitrary token ID *(Should be unique)*
 - **recipient** - Wallet address to send the token to

```js
await nft.mint(100, 200 '0xabc123')
```

##### Pause

Pauses all token transfers.

`pause()`

```js
await nft.pause()
```

##### Unpause

Unpauses all token transfers.

`unpause()`

```js
await nft.unpause()
```

#### Token Owner Actions

Only the token owner can do the following actions. These are not included in the
project's API and should be implemented on the client side.

#### Burn

Burns a token.

`burn(uint256 tokenId)`

 - **tokenId** - ex. 1

```js
await nft.burn(1)
```

##### List

Lists `tokenId` on the order book for `amount` in wei.

`list(uint256 tokenId, uint256 amount)`

 - **tokenId** - token ID caller already owns
 - **amount** - Amount in wei to sell it for

```js
await nft.list(200, ethers.utils.parseEther('1.5'))
```

##### Delist

Removes `tokenId` from the order book.

`delist(uint256 tokenId)`

 - **tokenId** - token ID caller already owns

```js
await nft.delist(200)
```

#### Public Actions

Anyone can do the following actions. These are not included in the
project's API and should be implemented on the client side.

##### Lazy Mint

Allows anyone to mint a token

`lazyMint(uint256 classId, uint256 tokenId, address recipient, bytes proof)`

 - **classId** - arbitrary class ID
 - **tokenId** - arbitrary token ID *(Should be unique)*
 - **recipient** - Wallet address to send the token to
 - **proof** - Signature the contract ownner must have signed

```js
await nft.lazyMint(100, 200, '0xabc123', '0xabc123')
```

##### Exchange

Allows for a sender to exchange `tokenId` for the listed amount

`exchange(uint256 tokenId) payable`

 - **tokenId** - token ID to purchase *(Should be listed)*

```js
await nft.delist(200)
```

#### Read Only Methods

Anyone can retrieve the following information from the contract.

##### Get a Token's Class

Returns the class given `tokenId`

`classOf(uint256 tokenId)`

```js
await nft.classOf(200) //--> 100
```

##### Get a Token Class' Reference

Returns the data of `classId`

`classURI(uint256 classId)`

```js
await nft.referenceOf(100) //--> ipfs://abc123
```

##### Get a Token Class' Max Size

Returns the total possible supply size of `classId`

`classSize(uint256 classId)`

```js
await nft.classSize(100) //--> 1000
```

##### Check if a Token Class is Full

Returns true if `classId` supply and size are equal

`classFilled(uint256 classId)`

```js
await nft.classFilled(100) //--> 1000
```

##### Check How Many Tokens Are in a Token Class

Returns the current supply size of `classId`

`classSupply(uint256 classId)`

```js
await nft.classSupply(100) //--> 1000
```

##### Get the Fee of a Person

Returns the fee of a `recipient` in `classId`

`classFeeOf(uint256 classId, address recipient)`

```js
await nft.classFeeOf(100, '0x63FC745B5309cE72921ED6dF48D4eAdddEB55f27') //--> 1000 (10.00%)
```

##### Get the Total Fees of a Token Class

Returns the fee of a `recipient` in `classId`

`classFees(uint256 classId)`

```js
await nft.classFees(100) //--> 1500 (15.00%)
```

##### Get a Token's Listing Price

Returns the amount *(in wei)* a `tokenId` is being offered for.

`listingOf(uint256 tokenId)`

```js
await nft.listingOf(200) //--> 1.5 ether
```

## Contributing to the Project

 - Manually assigning IDs is preferred over enumerating *(cheaper gas)*
 - Batch minting is discouraged *(impractical gas cost)*
 - Looping cannot be scaled *(unpredictable gas)*
 - Mappings are preferred over structs *(cheaper gas)*
