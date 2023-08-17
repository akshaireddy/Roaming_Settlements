import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const RoamingContract = await hre.ethers.getContractFactory("RoamingContract");
  const contract = await RoamingContract.attach(process.env.CONTRACT_ADDRESS);
  
  // Get the current roaming fee
  const roamingFee = await contract.roamingFee();
  console.log("Current Roaming Fee:", roamingFee.toString());

  // Start a roaming session
  const txStart = await contract.startRoaming(1, { value: roamingFee });
  await txStart.wait();
  console.log("Roaming started:", txStart.hash);

  // Simulate some time passing
  await hre.network.provider.send("evm_increaseTime", [3600]); // Increase time by 1 hour

  // End the roaming session
  const txEnd = await contract.endRoaming(0);
  await txEnd.wait();
  console.log("Roaming ended:", txEnd.hash);

  // Settle the roaming payment for the user
  const txSettle = await contract.settleRoaming(deployer.address, 0);
  await txSettle.wait();
  console.log("Roaming settled:", txSettle.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
