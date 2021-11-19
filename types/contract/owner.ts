import ethers from 'ethers';
import type { TX } from '../types';
import PublicContract from './public';

/**
 * Owner contract methods are meant to run on the server only
 */
export default class Contract extends PublicContract {
  /**
   * Sets a `fee` that will be paid to the `recipient` when a token
   * in a `classId` is exchanged.
   */
  async allocate(
    classId: number, 
    recipient: string, 
    fee: number
  ): Promise<TX> {
    return { tx: await this.contract.allocate(classId, recipient, fee) };
  }

  /**
   * Removes a `recipient` from the fee table of a `classId`.
   */
  async deallocate(classId: number, recipient: string): Promise<TX> {
    return { tx: await this.contract.deallocate(classId, recipient) };
  }

  /**
   * Removes all fees of a `classId`.
   */
  async deallocateAll(classId: number): Promise<TX> {
    return { tx: await this.contract.deallocateAll(classId) };
  }

  /**
   * Allows for the creator to make an offering on their tokens
   */
   async makeOffer(
    classId: number, 
    offerAmount: number, 
    offerStart: Date,
    offerEnd: Date
  ): Promise<TX> {
    return { tx: await this.contract.makeOffer(
      classId, 
      offerAmount, 
      Math.floor(offerStart.getTime() / 1000),
      Math.floor(offerEnd.getTime() / 1000)
    ) };
  }

  /**
   * Mints `tokenId`, classifies it as `classId` and transfers to `recipient`.
   */
  async mint(
    classId: number, 
    tokenId: number, 
    recipient: string
  ): Promise<TX> {
    return { tx: await this.contract.mint(classId, tokenId, recipient) };
  }

  /**
   * Registers a new `classId` with max token assignment `size`
   * that references a `uri`.
   */
  async register(
    classId: number, 
    size: number, 
    uri: string
  ): Promise<TX> {
    return { tx: await this.contract.register(classId, size, uri) };
  }

  /**
   * Registers a new `classId` with max token assignment `size`
   * that references a `uri`.
   */
  async registerToCreator(
    classId: number, 
    size: number, 
    uri: string,
    creator: string
  ): Promise<TX> {
    return { tx: await this.contract.registerToCreator(classId, size, uri, creator) };
  }

  /**
   * Creates a hash of the following parameters
   */
  hashToken(classId: number, tokenId: number, recipient: string): Buffer {
    return Buffer.from(
      ethers.utils.solidityKeccak256(
        ['uint256', 'uint256', 'address'],
        [classId, tokenId, recipient]
      ).slice(2),
      'hex'
    );
  }
}
