import { expect } from "chai";
import { deployments, ethers, network } from "hardhat";

describe("Greeter", function () {
  it("Simple flow", async function () {
    // Accounts
    const users = await ethers.getSigners();

    // Deployment
    await deployments.fixture(["HappyApe"]);
    const hapaDeployments = await deployments.get("HappyApe");
    const happyApe = await ethers.getContractAt("HappyApe", hapaDeployments.address);
  
    // Settings
    const apePrice = ethers.utils.parseEther("0.09");

    // Test start
    console.log("\nTest start");

    // user8 mint 8 apes
    console.log("\nuser8 mint 8 apes");
    const tx0 = await happyApe.connect(users[8]).mint(8, {value: apePrice.mul(8)});
    const receipt0 = await tx0.wait();
    if (receipt0.events) {
      for (let ethEvent of receipt0.events) {
        if (ethEvent.args) console.log(ethEvent.args.tokenId.toNumber());
      }
    }

    // user9 mint 9 apes
    console.log("\nuser9 mint 9 apes");
    const tx1 = await happyApe.connect(users[9]).mint(9, {value: apePrice.mul(9)});
    const receipt1 = await tx1.wait();
    if (receipt1.events) {
      for (let ethEvent of receipt1.events) {
        if (ethEvent.args) console.log(ethEvent.args.tokenId.toNumber());
      }
    }

    // user5 mint 5 apes
    console.log("\nuser5 mint 5 apes");
    const tx2 = await happyApe.connect(users[5]).mint(5, {value: apePrice.mul(5)});
    const receipt2 = await tx2.wait();
    if (receipt2.events) {
      for (let ethEvent of receipt2.events) {
        if (ethEvent.args) console.log(ethEvent.args.tokenId.toNumber());
      }
    }
    
    // check contract balance
    console.log("\ncheck contract balance");
    const contractBalance = await users[0].provider?.getBalance(happyApe.address);
    if (contractBalance) {
      console.log(ethers.utils.formatEther(contractBalance));
      expect(contractBalance).to.equal(apePrice.mul(await happyApe.totalSupply()));
    }
  });
});
