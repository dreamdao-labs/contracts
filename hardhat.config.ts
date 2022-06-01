import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      accounts: {
        mnemonic: process.env.MNEMONIC || "",
      },
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s2.binance.org:8545",
      chainId: 97,
      accounts: {
        mnemonic: process.env.MNEMONIC || "",
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      bsc: process.env.ETHERSCAN_BSC_API_KEY || "",
      bscTestnet: process.env.ETHERSCAN_BSC_API_KEY || ""
    }
  },
  solidity: {
    version: "0.8.12",
    settings: {
        optimizer: {
            enabled: true,
            runs: 200
        },
    },
  },
};

export default config;
