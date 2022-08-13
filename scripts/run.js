const main = async () => {
	const nftContractFactory = await hre.ethers.getContractFactory(
		'MyEpicNFT'
	);

	const nftContract = await nftContractFactory.deploy(10101);

	await nftContract.deployed();

	console.log('✅ Contract deployed to: ', nftContract.address);

	// Call mint function
	let txn = await nftContract.makeAnEpicNFT();

	// Wait for it to be mined
	await txn.wait();

	txn = await nftContract.makeAnEpicNFT();

	await txn.wait();
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
