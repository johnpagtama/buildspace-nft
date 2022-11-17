require('@nomicfoundation/hardhat-toolbox');
require('@nomicfoundation/hardhat-chai-matchers');
require('@nomiclabs/hardhat-ethers');
require('dotenv').config({ path: '.env' });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: '0.8.9',
	networks: {
		goerli: {
			url: process.env.INFURA_API_URL,
			accounts: [process.env.METAMASK_PRIVATE_KEY],
		},
	},
};
