import Web3 from 'web3';
const web3 = new Web3();

export default {
  /**
   * Creates a random wallet
   */
  async createWallet() {
    return web3.eth.accounts.create();
  },

  /**
   * Returns the public wallet address given its private key
   */
  getWalletAddress(privateKey: string): string {
    return web3.eth.accounts.privateKeyToAccount(privateKey).address;
  },

  /**
   * Signs any abitrary message given the message and private key
   * and returns the signature string
   */
  signMessage(message: string, privateKey: string): string {
    return web3.eth.accounts.sign(message, privateKey).signature;
  },

  /**
   * Signs any abitrary json given the json and private key
   * and returns the signature string
   */
  signJson(json: any, privateKey: string): string {
    return this.signMessage(JSON.stringify(json), privateKey);
  },

  /**
   * Verifies that the given address signed the given message
   */
  verifyMessage(
    message: string, 
    signature: string, 
    address: string
  ): boolean {
    return this.getSignatureOwner(message, signature) === address;
  },

  /**
   * Verifies that the given address signed the given json
   */
  verifyJson(
    json: any, 
    signature: 
    string, address: string
  ): boolean {
    return this.verifyMessage(JSON.stringify(json), signature, address);
  },

  /**
   * Returns the address owner of the signature
   */
  getSignatureOwner(message: string, signature: string): string {
    return web3.eth.accounts.recover(message, signature);
  },

  /**
   * Returns the RSV of a signature
   */
  getRSV(signature: string): {r: string, s: string, v: string} {
    const r = signature.slice(0,66);
    const s = '0x' + signature.slice(66,130);
    const v = '0x' + signature.slice(130,132);
    return {r, s, v};
  }
}
