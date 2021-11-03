const Web3 = require('web3')

var web3 = new Web3()

module.exports = {
  /**
   * Creates a random wallet
   *
   * @return object containing address and private key
   */
  async createWallet() {
    return web3.eth.accounts.create();
  },

  /**
   * Returns the public wallet address given its private key
   *
   * @param *string privateKey
   *
   * @return string
   */
  async getWalletAddress(privateKey) {
    return web3.eth.accounts.privateKeyToAccount(privateKey).address;
  },

  /**
   * Signs any abitrary message given the message and private key
   * and returns the signature string
   *
   * @param *string message
   * @param *string privateKey
   *
   * @return string
   */
  async signMessage(message, privateKey) {
    return web3.eth.accounts.sign(message, privateKey).signature;
  },

  /**
   * Signs any abitrary json given the json and private key
   * and returns the signature string
   *
   * @param *object json
   * @param *string privateKey
   *
   * @return string
   */
  async signJson(json, privateKey) {
    return this.signMessage(JSON.stringify(json), privateKey);
  },

  /**
   * Verifies that the given address signed the given message
   *
   * @param *string message
   * @param *string signature
   * @param *string address
   *
   * @return bool
   */
  async verifyMessage(message, signature, address) {
    return (await this.getSignatureOwner(message, signature)) === address;
  },

  /**
   * Verifies that the given address signed the given json
   *
   * @param *object json
   * @param *string signature
   * @param *string address
   *
   * @return bool
   */
  async verifyJson(json, signature, address) {
    return this.verifyMessage(JSON.stringify(json), signature, address);
  },

  /**
   * Returns the address owner of the signature
   *
   * @param *string message
   * @param *string signature
   *
   * @return bool
   */
  async getSignatureOwner(message, signature) {
    return web3.eth.accounts.recover(message, signature);
  },

  /**
   * Returns the RSV of a signature
   *
   * @param *string signature
   *
   * @return hash
   */
  async getRSV(signature) {
    const r = signature.slice(0,66)
    const s = '0x' + signature.slice(66,130)
    const v = '0x' + signature.slice(130,132)
    return {r, s, v}
  }
}
