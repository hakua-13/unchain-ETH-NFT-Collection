// deploy.js
const main = async() => {
  // コントラクトをコンパイルする
  // コントラクトを扱うために必要なファイルが 'artifacts' ディレクトリの直下に生成される
  const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
  // Hardhat がローカルのethereum ネットワークを作成する
  const nftContract = await nftContractFactory.deploy();
  // コントラクトがmintされデプロイされるのを待つ
  await nftContract.deployed();
  console.log('contract deployed to: ', nftContract.address)
  // makeAnEpicNFT関数を呼び出す。NFTがMintされる
  let txn = await nftContract.makeAnEpicNFT();
  await txn.wait();
  console.log('Minted NFT #1');
};

// エラー処理
const runMain = async() => {
  try{
    await main();
    process.exit(0);
  }catch(error){
    console.log(error);
    process.exit(1);
  }
};

runMain();