//to run this on testnet:
// $ npx hardhat run scripts/sign-script.js

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
  await hre.run('compile');

  //make a message
  const message = hashToken(1, 2, '0xD7D190cdC6A7053CD5Ee76E966a1b9056dbA4774')
  //sign message
  const wallet = '3c03e4dd8b370beccae5410d1bade4fa27e37b9f3c89bc8a16b5e33624c17411'
  const signer = new ethers.Wallet(wallet);

  const signature = await signer.signMessage(message);

  console.log('Signature:', signature)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
})
