const eth = require('./eth')
const ipfs = require('./ipfs')
const public = require('./contract/public')
const owner = require('./contract/owner')
const user = require('./contract/user')
const utils = require('./utils')

module.exports = {
  eth,
  ipfs,
  utils,
  contract: {
    public,
    owner,
    user
  }
}