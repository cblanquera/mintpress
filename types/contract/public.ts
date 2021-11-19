import type { MintpressContract, TX } from '../types';

/**
 * Public contract can be ran server or client side
 */
export default class Contract {
  public contract: MintpressContract;
  constructor(contract: MintpressContract) {
    this.contract = contract;
  }

  /**
   * Returns the class given `tokenId`
   */
  async classOf(tokenId: number): Promise<number> {
    return parseInt((await this.contract.classOf(tokenId)).toString());
  }

  /**
   * Returns true if `classId` supply and size are equal
   */
  async classFilled(classId: number): Promise<boolean> {
    return await this.contract.classFilled(classId);
  }

  /**
   * Returns the total possible supply size of `classId`
   */
  async classSize(classId: number): Promise<number> {
    return parseInt((await this.contract.classSize(classId)).toString());
  }

  /**
   * Returns the current supply size of `classId`
   */
  async classSupply(classId: number): Promise<number> {
    return parseInt((await this.contract.classSupply(classId)).toString());
  }

  /**
   * Returns the fee of a `recipient` in `classId`
   */
  async classFeeOf(classId: number, recipient: string): Promise<number> {
    return parseInt((await this.contract.classFeeOf(
      classId, 
      recipient
    )).toString());
  }

  /**
   * Returns the fee of a `recipient` in `classId`
   */
  async classFees(classId: number): Promise<number> {
    return parseInt((await this.contract.classFees(classId)).toString());
  }

  /**
   * Returns the data of `classId`
   */
  async classURI(classId: number): Promise<string> {
    return await this.contract.classURI(classId);
  }

  /**
   * Allows for a sender to exchange `tokenId` for the listed `amount`
   */
  async exchange(tokenId: number, amount: number): Promise<TX> {
    return { tx: await this.contract.exchange(
      tokenId, 
      { value: amount }
    ) };
  }

  /**
   * Allows anyone to self mint a token
   */
  async lazyMint(
    classId: number, 
    tokenId: number, 
    rating: number, 
    recipient: string, 
    signature: string
  ): Promise<TX> {
    return { tx: await this.contract.lazyMint(
      classId, 
      tokenId, 
      rating, 
      recipient, 
      signature
    ) };
  }

  /**
   * Returns the amount *(in wei)* a `tokenId` is being offered for.
   */
  async listingOf(tokenId: number): Promise<number> {
    return parseInt((await this.contract.listingOf(tokenId)).toString());
  }

  /**
   * Returns the owner of `tokenId`
   */
  async ownerOf(tokenId: number): Promise<string> {
    return await this.contract.ownerOf(tokenId)
  }

  /**
   * Returns the data of `tokenId`
   */
  async tokenURI(tokenId: number): Promise<string> {
    return await this.contract.tokenURI(tokenId);
  }

  /**
   * Returns the total number of tokens minted
   */
  async totalSupply(): Promise<number> {
    return await this.contract.totalSupply();
  }
}
