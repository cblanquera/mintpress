/**
 * Public contract can be ran server or client side
 */
class Contract {
  constructor(contract) {
    this.contract = contract
  }

  /**
   * Returns the class given `tokenId`
   *
   * @param *number tokenId
   *
   * @return number classId
   */
  async classOf(tokenId) {
    return parseInt((await this.contract.classOf(tokenId)).toString())
  }

  /**
   * Returns true if `classId` supply and size are equal
   *
   * @param *number classId
   *
   * @return bool
   */
  async classFilled(classId) {
    return await this.contract.classFilled(classId)
  }

  /**
   * Returns the total possible supply size of `classId`
   *
   * @param *number classId
   *
   * @return number size
   */
  async classSize(classId) {
    return parseInt((await this.contract.classSize(classId)).toString())
  }

  /**
   * Returns the current supply size of `classId`
   *
   * @param *number classId
   *
   * @return number supply
   */
  async classSupply(classId) {
    return parseInt((await this.contract.classSupply(classId)).toString())
  }

  /**
   * Returns the fee of a `recipient` in `classId`
   *
   * @param *number classId
   * @param *string recipient
   *
   * @return number fee
   */
  async classFeeOf(classId, recipient) {
    return parseInt((await this.contract.classFeeOf(classId, recipient)).toString())
  }

  /**
   * Returns the fee of a `recipient` in `classId`
   *
   * @param *number classId
   *
   * @return number fees
   */
  async classFees(classId) {
    return parseInt((await this.contract.classFees(classId)).toString())
  }

  /**
   * Returns the data of `classId`
   *
   * @param *number classId
   *
   * @return string uri
   */
  async classURI(classId) {
    return await this.contract.classURI(classId)
  }

  /**
   * Allows for a sender to exchange `tokenId` for the listed `amount`
   *
   * @param *number tokenId
   * @param *number amount
   *
   * @return object
   */
  async exchange(tokenId, amount) {
    return { tx: await this.contract.exchange(tokenId, { value: amount }) }
  }

  /**
   * Allows anyone to self mint a token
   *
   * @param *number classId Arbitrary class ID
   * @param *number tokenId Arbitrary token ID (should be unique)
   * @param *number rating Token rating
   * @param *string recipient Wallet address to send the token to
   * @param *string signature
   *
   * @return object The nft contract instance.
   */
  async lazyMint(classId, tokenId, rating, recipient, signature) {
    return { tx: await this.contract.lazyMint(classId, tokenId, rating, recipient, signature) }
  }

  /**
   * Returns the amount *(in wei)* a `tokenId` is being offered for.
   *
   * @param *number  tokenId
   *
   * @return number amount
   */
  async listingOf(tokenId) {
    return parseInt((await this.contract.listingOf(tokenId)).toString())
  }

  /**
   * Returns the owner of `tokenId`
   *
   * @param *number tokenId
   *
   * @return string address
   */
  async ownerOf(tokenId) {
    return await this.contract.ownerOf(tokenId)
  }

  /**
   * Returns the data of `tokenId`
   *
   * @param *number tokenId
   *
   * @return string uri
   */
  async tokenURI(tokenId) {
    return await this.contract.tokenURI(tokenId)
  }

  /**
   * Returns the total number of tokens minted
   *
   * @return number
   */
  async totalSupply() {
    return await this.contract.totalSupply()
  }
}

module.exports = Contract
