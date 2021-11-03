const PublicContract = require('./public')

/**
 * User contract can be ran server or client side
 */
class Contract extends PublicContract {
  /**
   * Burns `tokenId`.
   *
   * @param *number tokenId Owned token ID
   *
   * @return object
   */
  async burn(tokenId) {
    return { tx: await this.contract.burn(tokenId) }
  }

  /**
   * Removes `tokenId` from the order book.
   *
   * @param *number tokenId Owned token ID
   *
   * @return object
   */
  async delist(tokenId) {
    return { tx: await this.contract.delist(tokenId) }
  }

  /**
   * Lists `tokenId` on the order book for `amount` in wei.
   *
   * @param *number tokenId Owned token ID
   * @param *number amount Amount in wei to sell it for
   *
   * @return object
   */
  async list(tokenId, amount) {
    return { tx: await this.contract.list(tokenId, amount) }
  }
}

module.exports = Contract
