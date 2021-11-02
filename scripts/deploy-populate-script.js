//to run this on testnet:
// $ npx hardhat run scripts/deploy-populate-script.js --network mumbai

const hardhat = require('hardhat')

function hashToken(classId, tokenId, recipient) {
  return Buffer.from(
    ethers.utils.solidityKeccak256(
      ['uint256', 'uint256', 'address'],
      [classId, tokenId, recipient]
    ).slice(2),
    'hex'
  )
}

async function main() {
  if (hardhat.config.defaultNetwork != 'localhost') {
    console.error('Exited testing with network:', process.env.NETWORK)
    process.exit(1);
  }

  await hre.run('compile');

  const NFT = await hardhat.ethers.getContractFactory('ERC721Marketplace')
  const nft = await NFT.deploy('Burdick Fantasy Club DEMO', 'DEMOBD')
  await nft.deployed()
  console.log('NFT contract deployed to (update .env):', nft.address)

  //Player 1 Card 
  await nft.register(1, 10, 'https://ipfs.io/ipfs/QmW8yrrvys7Cic2XedTVVt9W4ho6v4sndQv7K7x4Y7Td91')
  //player 2 Card
  await nft.register(2, 5, 'https://ipfs.io/ipfs/QmNmbCX3rVZ1SJb6A3Yivu8aGmW8GohYuCtLPhohWH9UYs')

  const signers = await hardhat.ethers.getSigners()

  //the first 2 signers are token holders
  await nft.mint(1, 1, 90, signers[1].address)
  await nft.mint(1, 2, 80, signers[2].address)
  await nft.mint(2, 3, 70, signers[1].address)
  await nft.mint(2, 4, 60, signers[2].address)

  //make a message (its a buffer)
  const messages = [
    hashToken(1, 5, 50, signers[1].address),
    hashToken(1, 6, 40, signers[2].address),
    hashToken(2, 7, 30, signers[1].address),
    hashToken(2, 8, 20, signers[2].address)
  ]

  //let the contract owner sign it
  const signatures = [
    await signers[0].signMessage(messages[0]),
    await signers[0].signMessage(messages[1]),
    await signers[0].signMessage(messages[2]),
    await signers[0].signMessage(messages[3])
  ]

  //first token owner lists their token 1 for sale
  const Contract = await ethers.getContractFactory('ERC721Marketplace', signers[1])
  const signer1Contract = await Contract.attach(nft.address)
  await signer1Contract.list(1, ethers.utils.parseEther('0.001'))

  console.log('Contract populated !')
  console.log('Token Classes:')
  console.log(' - Class 1 has a limit of 10 tokens')
  console.log('   https://ipfs.io/ipfs/QmW8yrrvys7Cic2XedTVVt9W4ho6v4sndQv7K7x4Y7Td91')
  console.log(' - Class 2 has a limit of 5 tokens')
  console.log('   https://ipfs.io/ipfs/QmNmbCX3rVZ1SJb6A3Yivu8aGmW8GohYuCtLPhohWH9UYs')
  console.log('Minted Tokens:')
  console.log(' -', signers[1].address, 'owns token 1 in class 1')
  console.log(' -', signers[2].address, 'owns token 2 in class 1')
  console.log(' -', signers[1].address, 'owns token 3 in class 2')
  console.log(' -', signers[2].address, 'owns token 4 in class 2')
  console.log('Air Drops:')
  console.log(' -', signers[1].address, 'can lazy mint token 5 in class 1 with signature', signatures[0])
  console.log(' -', signers[2].address, 'can lazy mint token 6 in class 1 with signature', signatures[1])
  console.log(' -', signers[1].address, 'can lazy mint token 7 in class 2 with signature', signatures[2])
  console.log(' -', signers[2].address, 'can lazy mint token 8 in class 2 with signature', signatures[3])
  console.log('Order Book:')
  console.log(' -', signers[1].address, 'listed token 1 for sale for 0.001 ETH/MATIC')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
})
