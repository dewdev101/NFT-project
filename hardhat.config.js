require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

// const { ALCHEMY_TESTNET_RPC_URL, METAMASK_PRIVATE_KEY } = process.env;
// console.log("ALCHEMY_TESTNET_RPC_URL:",ALCHEMY_TESTNET_RPC_URL)
ALCHEMY_TESTNET_RPC_URL= "https://eth-sepolia.g.alchemy.com/v2/UMUVPo-rmba4Fg6oWZ2YjgrfNOjIVqgi"
METAMASK_PRIVATE_KEY="ef8e05a08ecafd474a6ccc950e2a85aad113ba2df0aa0587c68bd6411338eff0"
// console.log("METAMASK_PRIVATE_KEY:",METAMASK_PRIVATE_KEY)
module.exports = {
  solidity: "0.8.25",
  networks : {
    sepolia:{
      url: ALCHEMY_TESTNET_RPC_URL,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`]
    }
  }
};
