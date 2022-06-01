import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("DreamToken", function () {
  let owner, user1, user2, user3;
  let testToken: Contract, dreamToken: Contract, store: Contract;

  beforeEach(async function () {
    [owner, user1, user2, user3] = await ethers.getSigners();

    let TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.deploy();

    const DreamToken = await ethers.getContractFactory("DreamToken");
    const dreamToken = await DreamToken.deploy(
      "https://dreamdao.network/tokens/{id}.json",
      user3.address,
      1000
    );
    await dreamToken.deployed();

    const Store = await ethers.getContractFactory("Store");
    const store = await Store.deploy(
      dreamToken.address,
      testToken.address,
      user2.address
    );
    await store.deployed();

    const minterRole = await dreamToken.MINTER_ROLE();
    await dreamToken.grantRole(minterRole, store.address);
  });

  it("Purchase test", async function () {
    await testToken.approve(store.address, ethers.utils.parseEther("10000"));


  });
});
