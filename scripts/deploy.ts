import hre from "hardhat";

async function main() {
  // Hardhat 3 explicit network connection
  const connection = await hre.network.create();
  
  const [deployer] = await connection.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const CertificateRegistry = await connection.ethers.getContractFactory("CertificateRegistry");
  const registry = await CertificateRegistry.deploy();
  await registry.waitForDeployment();

  const address = await registry.getAddress();
  console.log("CertificateRegistry deployed to:", address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
