// run.js
const main = async() => {
  // コントラクトがコンパイルする
  // コントラクトを扱うために必要なファイルが、'artifacts'ディレクトリの直下に生される
  const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
  // HardhatがローカルのEthereumネットワークを作成する
  const nftContract = await nftContractFactory.deploy();
  // contractがmintされ、ローカルのブロックチェーンにデプロイされるまでまつ
  await nftContract.deployed();
  console.log('Contract deployed to', nftContract.address);

  // makeAnEpicNFT関数を呼び出す。NFTがmintされる
  let txn = await nftContract.makeAnEpicNFT();
  // Mintingが仮想マイナーにより承認されるのを待つ
  await txn.wait();
  // makeAnEpicNFT関数をもう一度呼び出す。NFTがまたMintされる
  txn = await nftContract.makeAnEpicNFT();
  // Mintingが仮想マイナーにより認証されるまで待つ
  await txn.wait();

  txn = await nftContract.makeAnEpicNFT();
  await txn.wait();
  txn = await nftContract.makeAnEpicNFT();
  await txn.wait();

  let mintCount = await nftContract.getMintCount();
  console.log(Object.keys(mintCount));
  console.log(mintCount.toNumber())

};

// error処理
const runMain = async() => {
  try{
    await main();
    process.exit(0);
  }catch(error){
    console.log(error);
    process.exit(1);
  }
}

runMain();