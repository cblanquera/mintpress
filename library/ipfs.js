const Hash = require('ipfs-only-hash')
const fs = require('fs')

module.exports = {
  /**
   * Returns an IPFS content identifier based from the data within a file path
   *
   * @param *string path (ex. /foo/bar)
   *
   * @return string
   */
  async getCidFromFilePath(path) {
    //convert to stream
    const stream = fs.createReadStream(path)

    //calculate cid hash
    return await Hash.of(stream)
  },

  /**
   * Returns an IPFS content identifier based from the given string data
   *
   * @param *string string
   *
   * @return string
   */
  async getCidFromString(string) {
    return await Hash.of(string)
  },

  /**
   * Returns an IPFS content identifier based from the given JSON object
   *
   * @param *object json
   *
   * @return string
   */
  async getCidFromJson(json) {
    return await this.getCidFromString(JSON.stringify(json))
  }
}
