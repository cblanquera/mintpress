const { expect } = require('chai')
const IPFS = require('../library/ipfs').default

describe('IPFS Library', function() {
  it('It should generate content identifiers', async function() {
    const cid1 = await IPFS.getCidFromFilePath(__dirname + '/assets/bank.png')
    expect(cid1).to.equal('QmXbPZG5kcB9bzJRz6rdgKoDSTNAufMCRojZcaRtwigfmV')

    const cid2 = await IPFS.getCidFromString('foobar')
    expect(cid2).to.equal('QmdLbcg1LnNqtNwYmYm4vXW6H7DTegdZsxKnPUw4XgVuhM')

    const cid3 = await IPFS.getCidFromJson({foo: 'bar'})
    expect(cid3).to.equal('Qmbjig3cZbUUufWqCEFzyCppqdnmQj3RoDjJWomnqYGy1f')
  })
})
