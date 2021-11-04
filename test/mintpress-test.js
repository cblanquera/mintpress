const { expect } = require('chai');
require('dotenv').config()

if (process.env.NETWORK != 'hardhat') {
  console.error('Exited testing with network:', process.env.NETWORK)
  process.exit(1);
}

async function getSigners(name, ...params) {
  //deploy the contract
  const ContractFactory = await ethers.getContractFactory(name)
  const contract = await ContractFactory.deploy(...params)
  await contract.deployed()
  //get the signers
  const signers = await ethers.getSigners()
  //attach contracts
  for (let i = 0; i < signers.length; i++) {
    const Contract = await ethers.getContractFactory(name, signers[i])
    signers[i].withContract = await Contract.attach(contract.address)
  }

  return signers
}

function hashToken(classId, tokenId, recipient) {
  return Buffer.from(
    ethers.utils.solidityKeccak256(
      ['uint256', 'uint256', 'address'],
      [classId, tokenId, recipient]
    ).slice(2),
    'hex'
  )
}

describe('Mintpress Tests', function () {
  it('Should register class and setup fees, mint/list/delist and buy token', async function () {
    const [contractOwner, creator, manager, tokenOwner, buyer] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // These are the current balance states
    creator.state = parseFloat(
      ethers.utils.formatEther(await creator.getBalance())
    )

    manager.state = parseFloat(
      ethers.utils.formatEther(await manager.getBalance())
    )

    tokenOwner.state = parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    )

    buyer.state = parseFloat(
      ethers.utils.formatEther(await buyer.getBalance())
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 3
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the fee setup
    //The creator wants 20% (2000 is 20.00%)
    await contractOwner.withContract.allocate(classId, creator.address, 2000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, creator.address)
    ).to.equal(2000)

    //The manager wants 10% (1000 is 10.00%)
    await contractOwner.withContract.allocate(classId, manager.address, 1000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, manager.address)
    ).to.equal(1000)

    //total fees should now be 30.00%
    expect(await contractOwner.withContract.classFees(classId)).to.equal(3000)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)

    //----------------------------------------//
    // This is the lazy minting
    //define tokens
    const tokenId2 = 300
    const tokenId3 = 400

    //make a message (its a buffer)
    const messages = [
      hashToken(classId, tokenId2, tokenOwner.address),
      hashToken(classId, tokenId3, tokenOwner.address)
    ]
    //let the contract owner sign it (its a buffer)
    const signatures = [
      await contractOwner.signMessage(messages[0]),
      await contractOwner.signMessage(messages[1])
    ]

    //let the contract owner lazy mint a token for the token owner
    await contractOwner.withContract.lazyMint(
      classId,
      tokenId2,
      tokenOwner.address,
      signatures[0]
    )

    //let the token owner lazy mint a token for themself
    await tokenOwner.withContract.lazyMint(
      classId,
      tokenId3,
      tokenOwner.address,
      signatures[1]
    )

    expect(await contractOwner.withContract.ownerOf(tokenId2)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId2)).to.equal(classId)
    expect(await contractOwner.withContract.ownerOf(tokenId3)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId3)).to.equal(classId)

    //----------------------------------------//
    // This is the listing
    const listedAmount = ethers.utils.parseEther('10.0')
    //the token owner can only list their token for sale
    await tokenOwner.withContract.list(tokenId, listedAmount)
    const listing = await tokenOwner.withContract.listingOf(tokenId)
    expect(listing).to.equal(listedAmount)
    //update token owner state
    tokenOwner.state = parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    )

    //----------------------------------------//
    // This is the exchange
    //the buyer will purchase it for the right amount
    await buyer.withContract.exchange(tokenId, { value: listedAmount })

    //----------------------------------------//
    // This is the test
    expect(
      ethers.utils.formatEther(
        await ethers.provider.getBalance(contractOwner.withContract.address)
      )
    ).to.equal('0.0')

    expect(parseFloat(
      ethers.utils.formatEther(await creator.getBalance())
    ) - parseFloat(creator.state)).to.equal(2)

    expect(parseFloat(
      ethers.utils.formatEther(await manager.getBalance())
    ) - parseFloat(manager.state)).to.equal(1)

    expect(parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    ) - parseFloat(tokenOwner.state)).to.equal(7)

    expect(
      Math.ceil(
        parseFloat(
          ethers.utils.formatEther(await buyer.getBalance())
        ) - parseFloat(buyer.state)
      )
    ).to.equal(-10)
  })

  it('Should stress lazy minting', async function () {
    const [contractOwner, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 3
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the lazy mint
    //define tokens
    const tokenId1 = 200
    const tokenId2 = 300
    const tokenId3 = 400

    //make a message (its a buffer)
    const messages = [
      hashToken(classId, tokenId1, tokenOwner.address),
      hashToken(classId, tokenId2, tokenOwner.address),
      hashToken(classId, tokenId3, tokenOwner.address)
    ]

    //let the contract owner sign it (its a buffer)
    const signatures = [
      await contractOwner.signMessage(messages[0]),
      await contractOwner.signMessage(messages[1]),
      await contractOwner.signMessage(messages[2])
    ]

    //let the contract owner lazy mint a token for the token owner
    await contractOwner.withContract.lazyMint(
      classId,
      tokenId1,
      tokenOwner.address,
      signatures[0]
    )

    //let the token owner lazy mint a token for themself
    await tokenOwner.withContract.lazyMint(
      classId,
      tokenId2,
      tokenOwner.address,
      signatures[1]
    )

    //----------------------------------------//
    // This is the test
    expect(await contractOwner.withContract.ownerOf(tokenId1)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId1)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId1)).to.equal(classURI)
    expect(await contractOwner.withContract.ownerOf(tokenId2)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId2)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId2)).to.equal(classURI)

    //let the token owner mint a token that they already have
    expect(
      tokenOwner.withContract.lazyMint(
        classId,
        tokenId1,
        tokenOwner.address,
        signatures[0]
      )
    ).to.be.revertedWith('ERC721: token already minted')

    //let the contract owner redeem a token for themself
    expect(
      contractOwner.withContract.lazyMint(
        classId,
        tokenId2,
        contractOwner.address,
        signatures[1]
      )
    ).to.be.revertedWith('Mintpress: Invalid proof.')

    //let the contract owner redeem a token an unclaimed token for themself using a valid signature
    expect(
      contractOwner.withContract.lazyMint(
        classId,
        tokenId3,
        contractOwner.address,
        signatures[2]
      )
    ).to.be.revertedWith('Mintpress: Invalid proof.')
  })

  it('Should stress minting', async function () {
    const [contractOwner, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 2
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)
    expect(await contractOwner.withContract.balanceOf(tokenOwner.address)).to.equal(1)

    //----------------------------------------//
    // This is the test
    //try to register a class again
    expect(
      contractOwner.withContract.register(classId, classSize, classURI)
    ).to.be.revertedWith('MultiClass: Class is already referenced')

    //try to mint the same token again
    expect(
      contractOwner.withContract.mint(classId, tokenId, contractOwner.address)
    ).to.be.revertedWith('ERC721: token already minted')

    //this should work
    contractOwner.withContract.mint(classId, 2, tokenOwner.address)

    //try to mint again
    expect(
      contractOwner.withContract.mint(classId, 3, tokenOwner.address)
    ).to.be.revertedWith('Mintpress: Class filled.')
  })

  it('Should stress fees', async function () {
    const [owner, creator, manager] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 1
    const classURI = 'ipfs://abc123'
    await owner.withContract.register(classId, classSize, classURI)
    expect(await owner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the fee setup
    //The creator wants 20% (2000 is 20.00%)
    await owner.withContract.allocate(classId, creator.address, 2000)
    expect(
      await owner.withContract.classFeeOf(classId, creator.address)
    ).to.equal(2000)

    //The manager wants 10% (1000 is 10.00%)
    await owner.withContract.allocate(classId, manager.address, 1000)
    expect(
      await owner.withContract.classFeeOf(classId, manager.address)
    ).to.equal(1000)

    //total fees should now be 30.00%
    expect(await owner.withContract.classFees(classId)).to.equal(3000)

    //----------------------------------------//
    // This is the test
    //try to under allocate
    expect(
      owner.withContract.allocate(classId, manager.address, 0)
    ).to.be.revertedWith('MultiClassFees: Fee should be more than 0')
    //try to over allocate
    expect(
      owner.withContract.allocate(classId, manager.address, 10000)
    ).to.be.revertedWith('MultiClassFees: Exceeds allowable fees')

    //manager now wants fee from 10% to 30%
    await owner.withContract.allocate(classId, manager.address, 3000)
    expect(await owner.withContract.classFeeOf(classId, manager.address)).to.equal(3000)
    //The creator wanted 20% so total should now be 50.00%
    expect(await owner.withContract.classFees(classId)).to.equal(5000)

    //creator fires manager for being too greedy
    await owner.withContract.deallocate(classId, manager.address)
    //total should now be 20.00%
    expect(await owner.withContract.classFees(classId)).to.equal(2000)

    //remove fee of someone that hasn't been entered
    expect(
      owner.withContract.deallocate(classId, owner.address)
    ).to.be.revertedWith('MultiClassFees: Recipient has no fees')
  })

  it('Should stress exchange', async function () {
    const [contractOwner, tokenOwner, buyer] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // These are the current balance states
    tokenOwner.state = parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    )

    buyer.state = parseFloat(
      ethers.utils.formatEther(await buyer.getBalance())
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 1
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)

    //----------------------------------------//
    // This is the listing
    const listedAmount = ethers.utils.parseEther('10.0')
    //the token owner can only list their token for sale
    await tokenOwner.withContract.list(tokenId, listedAmount)
    const listing = await tokenOwner.withContract.listingOf(tokenId)
    expect(listing).to.equal(listedAmount)
    //update token owner state
    tokenOwner.state = parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    )

    //----------------------------------------//
    // This is the exchange
    //the buyer will purchase it for the right amount
    await buyer.withContract.exchange(tokenId, { value: listedAmount })

    //----------------------------------------//
    // This is the test
    expect(
      ethers.utils.formatEther(
        await ethers.provider.getBalance(contractOwner.withContract.address)
      )
    ).to.equal('0.0')

    expect(parseFloat(
      ethers.utils.formatEther(await tokenOwner.getBalance())
    ) - parseFloat(tokenOwner.state)).to.equal(10)

    expect(
      Math.ceil(
        parseFloat(
          ethers.utils.formatEther(await buyer.getBalance())
        ) - parseFloat(buyer.state)
      )
    ).to.equal(-10)

    //NOTE: Remember the buyer now owns the token
    //let the buyer try to delist
    expect(
      buyer.withContract.delist(tokenId)
    ).to.be.revertedWith('MultiClassExchange: Token is not listed')

    //let the owner try to list the token for sale
    expect(
      contractOwner.withContract.list(tokenId, listedAmount)
    ).to.be.revertedWith('MultiClassExchange: Only the token owner can list a token')
    //let the buyer try to list the token for sale
    expect(
      buyer.withContract.list(tokenId, 0)
    ).to.be.revertedWith('MultiClassExchange: Listing amount should be more than 0')

    //the buyer should now properly list it
    await buyer.withContract.list(tokenId, listedAmount)
    expect(await contractOwner.withContract.listingOf(tokenId)).to.equal(listedAmount)
    //let the owner try to delist the token
    expect(
      contractOwner.withContract.delist(tokenId)
    ).to.be.revertedWith('MultiClassExchange: Only the token owner can delist a token')
    //the buyer should now properly delist it
    await buyer.withContract.delist(tokenId)
    expect(await contractOwner.withContract.listingOf(tokenId)).to.equal(0)
    //even non existent tokens are 0
    expect(await contractOwner.withContract.listingOf(123456)).to.equal(0)

    //let the old token owner try to buy it for the right amount
    expect(
      tokenOwner.withContract.exchange(tokenId, { value: listedAmount })
    ).to.be.revertedWith('MultiClassExchange: Token is not listed')

    //list it again so we can try to exchange it
    await buyer.withContract.list(tokenId, listedAmount)
    //let the old token try to buy it for the wrong amount
    expect(
      buyer.withContract.exchange(tokenId, {
        value: ethers.utils.parseEther('1.0')
      })
    ).to.be.revertedWith('MultiClassExchange: Amount sent does not match the listing amount')
    //let the old token owner buy it for the right amount
    tokenOwner.withContract.exchange(tokenId, { value: listedAmount })
    //let the old token owner try to buy it for the right amount again
    expect(
      tokenOwner.withContract.exchange(tokenId, { value: listedAmount })
    ).to.be.revertedWith('MultiClassExchange: Token is not listed')
  })

  it('Should support BEP721', async function () {
    const [contractOwner, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 3
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)

    //----------------------------------------//
    // This is the test
    expect(await contractOwner.withContract.name()).to.equal('Mintpress Collection')
    expect(await contractOwner.withContract.symbol()).to.equal('MPC')
    expect(await contractOwner.withContract.totalSupply()).to.equal(1)
    expect(await contractOwner.withContract.balanceOf(tokenOwner.address)).to.equal(1)
  })

  it('Should support ERC2981', async function () {
    const [contractOwner, creator, manager, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 3
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the fee setup
    //The creator wants 20% (2000 is 20.00%)
    await contractOwner.withContract.allocate(classId, creator.address, 2000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, creator.address)
    ).to.equal(2000)

    //The manager wants 10% (1000 is 10.00%)
    await contractOwner.withContract.allocate(classId, manager.address, 1000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, manager.address)
    ).to.equal(1000)

    //total fees should now be 30.00%
    expect(await contractOwner.withContract.classFees(classId)).to.equal(3000)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)

    //----------------------------------------//
    // This is the test
    const royalty = await contractOwner.withContract.royaltyInfo(tokenId, 10)
    expect(parseFloat(royalty.royaltyAmount)).to.equal(2)
    expect(royalty.receiver).to.equal(creator.address)
  })

  it('Should support Rarible', async function () {
    const [contractOwner, creator, manager, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId = 100
    const classSize = 3
    const classURI = 'ipfs://abc123'
    await contractOwner.withContract.register(classId, classSize, classURI)
    expect(await contractOwner.withContract.classURI(classId)).to.equal(classURI)

    //----------------------------------------//
    // This is the fee setup
    //The creator wants 20% (2000 is 20.00%)
    await contractOwner.withContract.allocate(classId, creator.address, 2000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, creator.address)
    ).to.equal(2000)

    //The manager wants 10% (1000 is 10.00%)
    await contractOwner.withContract.allocate(classId, manager.address, 1000)
    expect(
      await contractOwner.withContract.classFeeOf(classId, manager.address)
    ).to.equal(1000)

    //total fees should now be 30.00%
    expect(await contractOwner.withContract.classFees(classId)).to.equal(3000)

    //----------------------------------------//
    // This is the minting
    const tokenId = 200
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mint(classId, tokenId, tokenOwner.address)
    expect(await contractOwner.withContract.ownerOf(tokenId)).to.equal(tokenOwner.address)
    expect(await contractOwner.withContract.classOf(tokenId)).to.equal(classId)
    expect(await contractOwner.withContract.tokenURI(tokenId)).to.equal(classURI)

    //----------------------------------------//
    // This is the test
    const royalties = await contractOwner.withContract.getRaribleV2Royalties(tokenId)
    expect(royalties[0].value).to.equal(2000)
    expect(royalties[0].account).to.equal(creator.address)
    expect(royalties[1].value).to.equal(1000)
    expect(royalties[1].account).to.equal(manager.address)
  })

  it('Should mint pack', async function () {
    const [contractOwner, creator, manager, tokenOwner] = await getSigners(
      'Mintpress',
      'Mintpress Collection',
      'MPC',
      'http://mintpress.nft/contract.json',
      'http://mintpress.nft/token/'
    )

    //----------------------------------------//
    // This is the class setup
    const classId1 = 100
    const classSize1 = 3
    const classURI1 = 'ipfs://abc123'

    const classId2 = 200
    const classSize2 = 0
    const classURI2 = 'ipfs://def234'

    const classId3 = 300
    const classSize3 = 3
    const classURI3 = 'ipfs://ghi345'

    await contractOwner.withContract.register(classId1, classSize1, classURI1)
    await contractOwner.withContract.register(classId2, classSize2, classURI2)
    await contractOwner.withContract.register(classId3, classSize3, classURI3)

    //----------------------------------------//
    // This is the minting
    const fromTokenId = 200
    const tokensInPack = 10
    const defaultSize = 4
    //fast forward ... (go straight to the token owner)
    await contractOwner.withContract.mintPack(
      [classId1, classId2, classId3], 
      fromTokenId, 
      tokenOwner.address, 
      tokensInPack, 
      defaultSize, 
      'client seed'
    )

    //----------------------------------------//
    // This is the test
    for(let i = 0; i < tokensInPack; i++) {
      expect(await contractOwner.withContract.ownerOf(fromTokenId + i)).to.equal(tokenOwner.address)
    }
  })
})
