import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { configVariable, defineConfig } from "hardhat/config";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, "../backend/.env") });
dotenv.config({ path: path.resolve(__dirname, ".env") });

const isValidHexKey = (key?: string) => {
  if (!key) return false;
  let trimmed = key.trim().replace(/^["']|["']$/g, "");
  if (!trimmed.startsWith("0x")) trimmed = `0x${trimmed}`;
  return /^0x[0-9a-fA-F]{64}$/.test(trimmed);
};

const formatKey = (key: string) => {
  let trimmed = key.trim().replace(/^["']|["']$/g, "");
  return trimmed.startsWith("0x") ? trimmed : `0x${trimmed}`;
};

const getPrivateKey = () => {
  if (isValidHexKey(process.env.SEPOLIA_PRIVATE_KEY)) {
    return formatKey(process.env.SEPOLIA_PRIVATE_KEY!);
  }
  if (isValidHexKey(process.env.ADMIN_PRIVATE_KEY)) {
    return formatKey(process.env.ADMIN_PRIVATE_KEY!);
  }
  return configVariable("SEPOLIA_PRIVATE_KEY");
};

const isValidUrl = (url?: string) => {
  if (!url) return false;
  const trimmed = url.trim();
  return (
    trimmed.length > 0 &&
    !trimmed.includes("YOUR_ALCHEMY_API_KEY") &&
    !trimmed.includes("YOUR_KEY")
  );
};

const getRpcUrl = () => {
  if (isValidUrl(process.env.SEPOLIA_RPC_URL)) {
    return process.env.SEPOLIA_RPC_URL!.trim();
  }
  if (isValidUrl(process.env.RPC_URL)) {
    return process.env.RPC_URL!.trim();
  }
  return configVariable("SEPOLIA_RPC_URL");
};

export default defineConfig({
  plugins: [hardhatToolboxMochaEthersPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: getRpcUrl(),
      accounts: [getPrivateKey() as any],
    },
  },
});
