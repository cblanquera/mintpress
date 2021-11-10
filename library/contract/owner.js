const PublicContract = require('./public')

/**
 * Owner contract methods are meant to run on the server only
 */
class Contract extends PublicContract {
  /**
   * Sets a `fee` that will be paid to the `recipient` when a token
   * in a `classId` is exchanged.
   *
   * @param *number classId Arbitrary class ID
   * @param *string recipient Wallet address to pay when a token of the given class is exchanged
   * @param *number fee The percent of the amount to give where 10000 means 100.00%
   *
   * @return object The nft contract instance.
   */
  async allocate(classId, recipient, fee) {
    return { tx: await this.contract.allocate(classId, recipient, fee) }
  }

  /**
   * Removes a `recipient` from the fee table of a `classId`.
   *
   * @param *number classId Arbitrary class ID
   * @param *string recipient Wallet address to remove from the fee table
   *
   * @return object The nft contract instance.
   */
  async deallocate(classId, recipient) {
    return { tx: await this.contract.deallocate(classId, recipient) }
  }

  /**
   * Mints `tokenId`, classifies it as `classId` and transfers to `recipient`.
   *
   * @param *number classId Arbitrary class ID
   * @param *number tokenId Arbitrary token ID (should be unique)
   * @param *string recipient Wallet address to send the token to
   *
   * @return object The nft contract instance.
   */
  async mint(classId, tokenId, recipient) {
    return { tx: await this.contract.mint(classId, tokenId, recipient) }
  }

  /**
   * Registers a new `classId` with max token assignment `size`
   * that references a `uri`.
   *
   * @param *number classId Arbitrary class ID (should be unique)
   * @param *number size Max allowance of tokens that can be assigned
   * @param *string uri Any URI that gives more details of this token class
   *
   * @return object The nft contract instance.
   */
  async register(classId, size, uri) {
    return { tx: await this.contract.register(classId, size, uri) }
  }

  /**
   * Creates a hash of the following parameters
   *
   * @param *number classId
   * @param *number tokenId
   * @param *string recipient Wallet address to send the token to
   *
   * @return Buffer
   */
  hashToken(classId, tokenId, recipient) {
    return Buffer.from(
      hardhat.ethers.utils.solidityKeccak256(
        ['uint256', 'uint256', 'address'],
        [classId, tokenId, recipient]
      ).slice(2),
      'hex'
    )
  }
}

module.exports = Contract
