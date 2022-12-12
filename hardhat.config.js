require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config;

const fs = require("fs");

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
 solidity: "0.8.17",
 networks: {
  //  goerli: {
  //    url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
  //    accounts: [process.env.PRIVATE_KEY],
  //  },
   ganache: {
    url : 'https://localhost:8545'
   }
 },

};


