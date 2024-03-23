#!/usr/bin/env node

const web3 = require('web3');
const fs = require('fs');

const filePath = process.argv[2];
const password = process.argv[3];

if (!filePath || (password === undefined)) {
  console.log('Usage: getkey.js <keyfile> <password>');
  process.exit(1);
}

const contents = fs.readFileSync(filePath, 'utf8');

async function decryptKey() {
  try {
    const account = await web3.eth.accounts.decrypt(contents, password);
    console.log(account.privateKey);
  } catch (error) {
    console.log(error.message);
  }
}

decryptKey();