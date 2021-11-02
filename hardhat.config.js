require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require('dotenv').config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: process.env.NETWORK,
  networks: {
    hardhat: {
      chainId: 1337,
      mining: {
        //set this to false if you want localhost to mimick a real blockchain
        auto: true,
        interval: 5000
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      //accounts: [],
      contracts: [process.env.LOCALHOST_CONTRACT_ADDRESS]
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.MUMBAI_PRIVATE_KEY],
      contracts: [process.env.MUMBAI_CONTRACT_ADDRESS]
    },
    prebsc: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [process.env.PREBSC_PRIVATE_KEY],
      contracts: [process.env.PREBSC_CONTRACT_ADDRESS]
    },
    ropsten: {
      url: "https://eth-ropsten.alchemyapi.io/v2/YoNVLItXnYnhbJkzY9PMEAyOYn5dDGpn",
      accounts: [process.env.ROPSTEN_PRIVATE_KEY],
      contracts: [process.env.ROPSTEN_CONTRACT_ADDRESS]
    }
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  gasReporter: {
    currency: 'USD',
    //token: 'MATIC', //comment this out if you want ETH
    coinmarketcap: process.env.CMC_KEY,
    gasPrice: 200,
  }
};
