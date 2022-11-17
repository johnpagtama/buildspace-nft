const main = async () => {
	const nftContractFactory = await hre.ethers.getContractFactory(
		'MyEpicNFT'
	);

	const nftContract = await nftContractFactory.deploy(1349);

	await nftContract.deployed();

	console.log('✅ Contract deployed to: ', nftContract.address);

	let txn = await nftContract.makeAnEpicNFT();

	let uri = await txn.wait();

	console.log('✅ NFT URI: ', uri);
};

const runMain = async () => {
	try {
		await main();

		process.exit(0);
	} catch (err) {
		console.error('❌', err);

		process.exit(1);
	}
};

runMain();
