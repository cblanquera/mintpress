import type { TX } from '../types';
import PublicContract from './public';

/**
 * User contract can be ran server or client side
 */
export default class Contract extends PublicContract {
  /**
   * Burns `tokenId`.
   */
  async burn(tokenId: number): Promise<TX> {
    return { tx: await this.contract.burn(tokenId) }
  }

  /**
   * Removes `tokenId` from the order book.
   */
  async delist(tokenId: number): Promise<TX> {
    return { tx: await this.contract.delist(tokenId) }
  }

  /**
   * Lists `tokenId` on the order book for `amount` in wei.
   */
  async list(tokenId: number, amount: number): Promise<TX> {
    return { tx: await this.contract.list(tokenId, amount) }
  }
}
