import { ethers, utils } from 'ethers';
import { useState, useEffect } from 'react';
import abi from '../utils/MyEpicNFT.json';

const useConnect = () => {
	const [currentAccount, setCurrentAccount] = useState('');

	const [data, setData] = useState({});

	const contractAddress = '0xB98d38E627418a55175814CA93f757E3A9D5477a';

	const contractABI = abi.abi;

	const checkIfWalletIsConnected = async () => {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				console.log('Make sure you have MetaMask.');

				return;
			} else {
				console.log('Ethereum object: ', ethereum);
			}

			const accounts = await ethereum.request({
				method: 'eth_accounts',
			});

			if (accounts.length !== 0) {
				const account = accounts[0];

				console.log(
					`Found an authorized account: ${account}`
				);

				setCurrentAccount(
					ethers.utils.getAddress(account)
				);
			} else {
				console.warn('No authorized account found');
			}
		} catch (err) {
			console.error(err);
		}
	};

	const connectWallet = async () => {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				alert('Get Metamask');
				return;
			}

			const accounts = await ethereum.request({
				method: 'eth_requestAccounts',
			});

			console.log(`Connected: ${accounts[0]}`);

			setCurrentAccount(utils.getAddress(accounts[0]));
		} catch (err) {
			console.error(err);
		}
	};

	const mintNFT = async () => {
		try {
			const { ethereum } = window;

			if (ethereum) {
				const provider =
					new ethers.providers.Web3Provider(
						ethereum
					);

				const signer = provider.getSigner();

				const epicNftContract = new ethers.Contract(
					contractAddress,
					contractABI,
					signer
				);

				console.log(contractAddress);

				const numTxn =
					await epicNftContract.requestRandomWords(
						{ gasLimit: 300000 }
					);

				console.log(`Generating... ${numTxn.hash}`);

				await numTxn.wait();

				console.log(`Generated: ${numTxn.hash}`);

				let nftTxn =
					await epicNftContract.makeAnEpicNFT({
						gasLimit: 600000,
					});

				console.log(`Minting... ${nftTxn.hash}`);

				await nftTxn.wait();

				console.log('Minted: ', nftTxn);

				let idTxn = await epicNftContract.getItemId({
					gasLimit: 600000,
				});

				console.log('Nft id: ', idTxn);

				let nameTxn = await epicNftContract.getItemName(
					{
						gasLimit: 600000,
					}
				);

				console.log('Nft name: ', nameTxn);

				let colorTxn =
					await epicNftContract.getItemColor({
						gasLimit: 600000,
					});

				console.log('Nft color: ', colorTxn);

				setData({
					id: idTxn,
					name: nameTxn,
					color: colorTxn,
				});
			} else {
				console.warn('Etherum object does not exist');
			}
		} catch (err) {
			console.error(err);
		}
	};

	useEffect(() => {
		checkIfWalletIsConnected();
	}, []);

	return { currentAccount, connectWallet, mintNFT, data };
};

export default useConnect;
