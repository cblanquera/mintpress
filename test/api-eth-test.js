const { expect } = require('chai')
const ETH = require('../library/eth')

describe('ETH Library', function() {
  it('It should create a wallet and sign a message', async function() {
    const wallet = await ETH.createWallet()
    expect(wallet).to.have.property('address')
    expect(wallet).to.have.property('privateKey')

    const address = await ETH.getWalletAddress(wallet.privateKey)
    expect(address).to.equal(wallet.address)

    const signature = await ETH.signJson({foo: 'bar'}, wallet.privateKey)
    const verified = await ETH.verifyJson({foo: 'bar'}, signature, address)
    expect(verified).to.equal(true)

    const RSV = await ETH.getRSV(signature)
    expect(RSV).to.have.property('r')
    expect(RSV).to.have.property('s')
    expect(RSV).to.have.property('v')
  })
})
