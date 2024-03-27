#!/usr/bin/env node

const { Web3 } = require('web3')
const fs = require('fs')

const web3 = new Web3('http://localhost:8545')

const filePath = process.argv[2]
const signerAccount = process.argv[3]
const receiverAccount = process.argv[4]
const nTokens = process.argv[5]

if (!filePath || !receiverAccount || !nTokens || !signerAccount) {
  console.log('Usage: mint-tokens.js <token-hardhat-deploy-json> <signer-account> <receiver-account> <token-ammount>')
  process.exit(1)
}

console.log(`Signer account is ${signerAccount}.`)
console.log(`Receiver account is ${receiverAccount}.`)

const deploy = JSON.parse(fs.readFileSync(filePath, 'utf8'));

const abi = deploy.abi;
const address = deploy.address;

console.log(`Read contract ABI. Address is ${address}.`)

const contract = new web3.eth.Contract(abi, address);

async function mint() {
  try {
    console.log(`Minting ${nTokens} tokens to account ${receiverAccount}`)
    const result = await contract.
      methods.
      mint(receiverAccount, parseInt(nTokens)).
      send({ from: signerAccount });

    console.log(result);
    console.log(`Balance at ${receiverAccount} is now ${await contract.methods.balanceOf(receiverAccount).call()}`)
  } catch (error) {
    console.log(error.message);
  }
}

mint()