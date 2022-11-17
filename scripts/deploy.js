const main = async () => {
	const nftContractFactory = await hre.ethers.getContractFactory(
		'MyEpicNFT'
	);

	const nftContract = await nftContractFactory.deploy(1349);

	await nftContract.deployed();

	console.log('✅ Contract deployed to: ', nftContract.address);

	// Request random number
	// const txn = await nftContract.requestRandomWords();

	// console.log('✅ Requested random number');

	// const data = await txn.wait();

	// console.log('✅ Receved random number: ', data);

	// Call mint function
	// const mint = await nftContract.makeAnEpicNFT();

	// const nft = await mint.wait();

	// console.log('✅ Minted NFT #1', nft);
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
