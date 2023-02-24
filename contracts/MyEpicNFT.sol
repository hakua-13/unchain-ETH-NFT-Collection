// MyEpicNFT.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// import OpenZeppelin
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';

import '@openzeppelin/contracts/utils/Counters.sol';
import 'hardhat/console.sol';

// Base64.soコントラクトからSVGとJSONをBase64に変換する関数をインポートする
import {Base64} from './libraries/Base64.sol';

// インポートした OpenZepplinのコントラクトを継承する
// 継承したコントラクトのメソッドにアクセスできるようになる
contract MyEpicNFT is ERC721URIStorage{
  // OpenZeppelinがtokenIdsを簡単に追跡するために提供するライブラリを呼び出
  using Counters for Counters.Counter;
  // _tokenIdsを初期化する
  Counters.Counter private _tokenIds;

  uint8 maxMint = 50;

  // SVGコードを作成する
  // 変更させるのは、表示される単語のみ
  // すべてのNFTにSVGaコードを適用するために、baseSvg変数を作成する
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // 3つの配列 string[]に、それぞれランダムな単語を設定する
  string[] firstWords = ["motel", "table", "happy", "shine", "smile", "apple", "peace", "woman", "fable", "bread", "flood", "store", "honey", "brave", "spoon", "queen", "maple", "plant", "world", "color"];
  string[] secondWords = ["grass", "juice", "horse", "dream", "spice", "river", "sound", "jolly", "bloom", "light", "chess", "trick", "match", "pride", "trade", "faith", "heart", "angel", "drama", "flute"];
  string[] thirdWords = ["image", "gifts", "beard", "brisk", "waste", "joker", "gloom", "laugh", "smirk", "music", "tiger", "treat", "candy", "faith", "radio", "bloom", "shark", "knife", "globe"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  // NFTトークンの名前とそのシンボルを渡す
  constructor() ERC721 ('SquareNFT', 'SQUARE'){
    console.log('This is my NFT contract');
  }

  function getMintCount()public view returns(uint256){
    return _tokenIds.current();
  }

  // シードを生成する関数を作成する
  function random(string memory input) internal pure returns (uint256){
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // 各配列からランダムに単語を選ぶ関数を3つ作成する
  // pickRandomFirstWord関数は、最初の単語を選ぶ
  function pickRandomFirstWord(uint256 tokenId) public view returns(string memory){
    // pickRandomFirstWord関数のシードとなるrandを作成する
    uint256 rand = random(string(abi.encodePacked('FIRST_WORD', Strings.toString(tokenId))));
    // seed randをターミナルに出力
    console.log('rand seed: ', rand);
    // firstWords配列の長さを基準に rand番目の単語を選ぶ
    rand = rand % firstWords.length;
    // firstWords配列から何番目の単語が選ばれるかターミナルに出力する
    console.log('rand first word: ', rand);
    return firstWords[rand];
  }

  // pickRandomSecondWord配列は、2番目に表示される単語を選ぶ。
  function pickRandomSecondWord(uint256 tokenId) public view returns(string memory){
    uint256 rand = random(string(abi.encodePacked('SECOND_WORD', Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  // pickRandomSecondWord配列は、3番目に表示される単語を選ぶ
  function pickRandomThirdWord(uint tokenId) public view returns(string memory){
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  // ユーザーが NFT を取得するために実行する関数
  function makeAnEpicNFT() public{
    // 現在のtokenIdを取得する。tokenIdは0から始まる
    uint256 newItemId = _tokenIds.current();
    // mint上限に達している場合はerrorを出す
    require(maxMint > newItemId, 'upper mint limit...');

    // 3つの配列からそれぞれ１つの単語をランダムに取り出す
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);

    // 3つの単語を連結して格納する変数 combinedWordを定義する
    string memory combinedWord = string(abi.encodePacked(first, second, third));
    // 3つの単語を連結して、<text>タグと<svg>タグで閉じる
    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    // NFTに出力されるテキストをターミナルに出力する
    console.log('\n--------------------');
    console.log(finalSvg);
    console.log('--------------------\n');

    // JSONファイルを所定の位置に取得し、base64としてエンコードする
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            // NFTのタイトルを生成する言葉（例: GrandCuteBird)を設定する
            combinedWord,
            '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
            // data: image/svg+xml;base64 を追加し、SVGをbase64でエンコードした結果を追加する
            Base64.encode(bytes(finalSvg)),
            '"}'
          )
        )
      )
    );

    // データの先頭に data:application/json;base64を追加する
    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    console.log('\n----- Token URI -----');
    console.log(finalTokenUri);
    console.log('---------------------\n');

    // msg.senderを使ってNFTを送信者にMintする
    _safeMint(msg.sender, newItemId);

    // tokenURIを更新する
    _setTokenURI(newItemId, finalTokenUri);

    // NFTがいつ誰に作成されたか確認する
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    // 次のNFTがMintされるときのカウンターをインクリメントする
    _tokenIds.increment();

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}