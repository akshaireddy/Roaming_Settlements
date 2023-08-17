const hre = require("hardhat");

async function main() {
  const RoamingContract = await hre.ethers.getContractFactory("RoamingContract");
  const contract = await RoamingContract.deploy(process.env.ROAMING_FEE);
  await contract.deployed();
  console.log("RoamingContract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
