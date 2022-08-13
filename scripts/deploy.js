const main = async () => {
	const nftContractFactory = await hre.ethers.getContractFactory(
		'MyEpicNFT'
	);

	const nftContract = await nftContractFactory.deploy(10101);

	await nftContract.deployed();

	console.log('✅ Contract deployed to: ', nftContract.address);

	// Call mint function
	let txn = await nftContract.makeAnEpicNFT();

	let data = await txn.wait();

	console.log('✅ Minted NFT #1', data);
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
