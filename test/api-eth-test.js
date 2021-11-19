const { expect } = require('chai')
const ETH = require('../library/eth').default

describe('ETH Library', function() {
  it('It should create a wallet and sign a message', async function() {
    const wallet = ETH.createWallet()
    expect(wallet).to.have.property('address')
    expect(wallet).to.have.property('privateKey')

    const address = ETH.getWalletAddress(wallet.privateKey)
    expect(address).to.equal(wallet.address)

    const signature = ETH.signJson({foo: 'bar'}, wallet.privateKey)
    const verified = ETH.verifyJson({foo: 'bar'}, signature, address)
    expect(verified).to.equal(true)

    const RSV = ETH.getRSV(signature)
    expect(RSV).to.have.property('r')
    expect(RSV).to.have.property('s')
    expect(RSV).to.have.property('v')
  })
})
