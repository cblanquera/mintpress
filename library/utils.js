const VM_ERROR = "Error: VM Exception while processing transaction: reverted with reason string '"

const ethers = require('ethers')
const hardhat = require('hardhat')

const contracts = {
  owner: require('./contract/owner'),
  user: require('./contract/user'),
  public: require('./contract/public')
}

module.exports = {
  loadContract(name, artifact, contractOwner, contractAddress) {
    const Contract = contracts[name]
    const network = hardhat.config.networks[hardhat.config.defaultNetwork]
    const provider = new ethers.providers.JsonRpcProvider(network.url)
    const signer = new ethers.Wallet(contractOwner || network.accounts[0], provider)
    const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, signer)
    const contract = factory.attach(contractAddress || network.contracts[0])
    return new Contract(contract)
  },
  getErrorMessage(e) {
    if (e.error && e.error.body) {
      const body = JSON.parse(e.error.body)
      if (body.error && body.error.message) {
        if (body.error.message.indexOf(VM_ERROR) === 0) {
          //find last quote
          const last = body.error.message.lastIndexOf("'")
          return body.error.message.substring(VM_ERROR.length, last)
        }
        return body.error.message
      }
    }

    if (e.reason) {
      return e.reason
    }

    return e.message
  }
}
