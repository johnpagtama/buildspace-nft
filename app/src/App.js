import './App.css';
import useConnect from './hooks/useConnect';

function App() {
	const { currentAccount, connectWallet, mintNFT, data } = useConnect();

	return (
		<div className='nft-page'>
			{data.color && (
				<div className='nft tooltip'>
					<a
						href={`https://testnets.opensea.io/assets/goerli/${process.env.REACT_APP_CONTRACT_ADDRESS}/${data.id}`}
						target='_blank'
						rel='noreferrer'>
						<h3 className='nft-name'>
							{data.name}
						</h3>
						<img
							className='nft-image'
							src={data.color}
							alt={data.name}
						/>
					</a>
					<span class='tooltiptext'>
						🌊 View on OpenSea
					</span>
				</div>
			)}

			{currentAccount && (
				<>
					<button
						className='nft-mint'
						onClick={mintNFT}>
						Mint NFT
					</button>

					<button className='nft-view'>
						<a
							href={`https://testnets.opensea.io/${currentAccount}`}
							target='_blank'
							rel='noreferrer'>
							View Collections
						</a>
					</button>
				</>
			)}

			{!currentAccount && (
				<button
					className='connect-wallet'
					onClick={connectWallet}>
					Connect Wallet
				</button>
			)}
		</div>
	);
}

export default App;
