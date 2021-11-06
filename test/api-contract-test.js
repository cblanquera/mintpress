const { expect } = require('chai')
const utils = require('../library/utils')
const artifact = require('../artifacts/contracts/Mintpress.sol/Mintpress.json')

async function loadContract(name, ...params) {
  //deploy the contract
  const ContractFactory = await ethers.getContractFactory(name)
  const contract = await ContractFactory.deploy(...params)
  await contract.deployed()
  //get the signers
  const signers = await ethers.getSigners(1)
  return utils.loadContract('public', artifact, signers[0].address, contract.address)
}

describe('Contract Library', function() {
  it('Should access library', async function() {
    const contract = await loadContract(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    expect(typeof contract.totalSupply).to.equal('function')
  })
})