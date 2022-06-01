import { ethers } from "hardhat";

async function main() {
  // Contract Owner
  const OWNER_ADDRESS = "0x400dE79D92f1f4D08b703614E4C1491C568e6De4";

  // BSC USDT
  const USDT_ADDRESS = "0x55d398326f99059fF775485246999027B3197955";

  // FundSplitter
  const FundSplitter = await ethers.getContractFactory("FundSplitter");
  // const fundSplitter = await FundSplitter.deploy();
  // await fundSplitter.deployed();

  const fundSplitter = await FundSplitter.attach("0x7cFd8b5d03Fd44a22A9Fa07E4D026ffcD260714b");
  console.log("FundSplitter deployed to:", fundSplitter.address);

  // DreamVault
  const DreamVault = await ethers.getContractFactory("DreamVault");
  // const dreamVault = await DreamVault.deploy();
  // await dreamVault.deployed();

  const dreamVault = await DreamVault.attach("0x4bfbb8Be1389e21770c6d2bAe37105D184D75040");
  console.log("DreamVault deployed to:", dreamVault.address);

  // DreamToken
  const DreamToken = await ethers.getContractFactory("DreamToken");
  // const dreamToken = await DreamToken.deploy(
  //   "https://dreamdao.network/tokens/{id}.json",
  //   dreamVault.address,
  //   1000
  // );
  // await dreamToken.deployed();

  const dreamToken = await DreamToken.attach("0xEffcD0c829797BD3173e4247cC070A47ECD08B96");
  console.log("DreamToken deployed to:", dreamToken.address);

  // TimelockController
  const TimelockController = await ethers.getContractFactory("TimelockController");
  // const timelockController = await TimelockController.deploy(
  //   86400,
  //   [OWNER_ADDRESS],
  //   [OWNER_ADDRESS]
  // );
  // await timelockController.deployed();

  const timelockController = await TimelockController.attach("0x983fCA75D02829A31bca57F2207B345b357EE676");
  console.log("TimelockController deployed to:", timelockController.address);

  // DreamGovernor
  const DreamGovernor = await ethers.getContractFactory("DreamGovernor");
  // const dreamGovernor = await DreamGovernor.deploy(
  //   dreamToken.address,
  //   timelockController.address
  // );
  // await dreamGovernor.deployed();

  const dreamGovernor = await DreamGovernor.attach("0x7f26492cdF0c75CAe999cA6889A6d16cbAf59563");
  console.log("DreamGovernor deployed to:", dreamGovernor.address);

  // Store
  const Store = await ethers.getContractFactory("Store");
  // const store = await Store.deploy(
  //   dreamToken.address,
  //   USDT_ADDRESS,
  //   fundSplitter.address
  // );
  // await store.deployed();

  const store = await Store.attach("0xb14F5645F5C22B555f95fD16C34D2e8308D5cf4C");
  console.log("Store deployed to:", store.address);

  // const minterRole = await dreamToken.MINTER_ROLE();
  // await dreamToken.grantRole(minterRole, store.address);

  // await dreamToken.setDefaultRoyalty(dreamVault.address, 5000);

  // await dreamToken.mint("0x114c4347bf0Acf13D34dBF616F863EE9A229cF52", 0, 20, "0x");

  // await fundSplitter.addPayee("0x6D1aE41a02749562Ab35aAC7c9E23187C8DF5d0C", 400);
  // await fundSplitter.addPayee(dreamVault.address, 600);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
