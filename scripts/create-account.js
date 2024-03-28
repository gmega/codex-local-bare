#!/usr/bin/env node

/* Creates a regular account and saves private key and address to files. */

const ethers = require('ethers');
const fs = require('fs').promises;

const basePath = process.argv[2];
const accountName = process.argv[3];

if (!basePath || !accountName) {
  console.log('Usage: geth-accounts.js <folder> <account-name>')
  process.exit(1)
}

const wallet = ethers.Wallet.createRandom();
const keystorePath = `${basePath}/${accountName}-key`;

fs.writeFile(keystorePath, wallet.privateKey);
console.log(`Private key saved to ${keystorePath}`);

fs.writeFile(`${basePath}/${accountName}-account`, wallet.address);
console.log(`Account address saved to ${basePath}/${accountName}-account`);
