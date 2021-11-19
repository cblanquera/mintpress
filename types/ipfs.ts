import fs from 'fs';
import Hash from 'ipfs-only-hash';

export default {
  /**
   * Returns an IPFS content identifier based from the data within a file path
   */
  async getCidFromFilePath(path: string): Promise<string> {
    //convert to stream
    const stream = fs.createReadStream(path);
    //calculate cid hash
    return await Hash.of(stream);
  },

  /**
   * Returns an IPFS content identifier based from the given string data
   */
  async getCidFromString(string: string): Promise<string> {
    return await Hash.of(string);
  },

  /**
   * Returns an IPFS content identifier based from the given JSON object
   */
  async getCidFromJson(json: any): Promise<string> {
    return await this.getCidFromString(JSON.stringify(json));
  }
};
