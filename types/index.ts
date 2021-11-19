import eth from './eth';
import ipfs from './ipfs';
import Public from './contract/public';
import Owner from './contract/owner';
import User from './contract/user';
import { loadContract, getErrorMessage } from './utils';

import { MintpressContract } from './types';

const contract = {
  Public,
  Owner,
  User
};

const utils = {
  loadContract,
  getErrorMessage
};

export {
  eth,
  ipfs,
  utils,
  contract,
  MintpressContract
}