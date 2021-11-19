import { ethers } from 'ethers';
import hardhat from 'hardhat';
import { HardhatNetworkConfig } from 'hardhat/types';

import Owner from './contract/owner';
import User from './contract/user';
import Public from './contract/public';

type HardhatNetworkConfigCustom = HardhatNetworkConfig & {
  url: string,
  accounts: string[],
  contracts: any[]
};

export type HardhatError = Error & {
  error: {
    body: string
  },
  reason: string
};

const Contract = { Owner, User, Public };
const defaultNetwork = hardhat.config.defaultNetwork;
const network = hardhat.config.networks[defaultNetwork] as HardhatNetworkConfigCustom;
const provider = new ethers.providers.JsonRpcProvider(network.url);

export function loadContract(
  name: string,
  artifact?: Record<string, any>, 
  contractOwner?: string, 
  contractAddress?: string
) {
  if (!artifact) {
    throw new Error('Cannot find artifact');
  }
  const signer = new ethers.Wallet(
    contractOwner || network.accounts[0], 
    provider
  );
  const factory = new ethers.ContractFactory(
    artifact.abi, 
    artifact.bytecode, 
    signer
  );

  const contract = factory.attach(
    contractAddress || network.contracts[0]
  );
  if (name === 'owner') {
    //@ts-ignore
    return new Contract.Owner(contract);
  } else if (name === 'user') {
    //@ts-ignore
    return new Contract.User(contract);
  }
  //@ts-ignore
  return new Contract.Public(contract);
};

const VM_ERROR = "Error: VM Exception while processing transaction: "
               + "reverted with reason string '";

export function getErrorMessage(e: HardhatError) {
  if (e.error && e.error.body) {
    const body = JSON.parse(e.error.body);
    if (body.error && body.error.message) {
      if (body.error.message.indexOf(VM_ERROR) === 0) {
        //find last quote
        const last = body.error.message.lastIndexOf("'");
        return body.error.message.substring(VM_ERROR.length, last);
      }
      return body.error.message;
    }
  }

  if (e.reason) {
    return e.reason;
  }

  return e.message;
};
