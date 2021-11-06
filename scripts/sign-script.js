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
  const message = hashToken(1, 2, '0xWalletAddress')
  //sign message wallet PK
  const wallet = 'PrivateKey'
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
