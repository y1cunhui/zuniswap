require("@nomiclabs/hardhat-waffle")

const { expect } = require("chai");
const { ethers } = require("hardhat");


const toWei = (value) => ethers.utils.parseEther(value.toString());


const fromWei = (value) => {
    ethers.utils.fromWei(
        typeof value == "string" ? value : value.toString()
    );
}

const getBalance = ethers.provider.getBalance;

describe("Exchange", async () => {
    let owner;
    let user;
    let token;
    let exchange;

    beforeEach(async () => {
        [owner, user] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("Token");

        token = await Token.deploy("Token", "TKN", toWei(1000000));
        await token.deployed();

        const Exchange = await ethers.getContractFactory("Exchange");
        exchange = await Exchange.deploy(token.address);
        await exchange.deployed();
    })

    

    describe("addLiquidity", async () => {
        it("add liquitity succeed", async () => {
            await token.approve(exchange.address, toWei(200));
            await exchange.addLiquidity(toWei(200), {value : toWei(100)});

            expect(await getBalance(exchange.address)).to.equal(toWei(100));
            expect(await exchange.getReserve()).to.equal(toWei(200));
        })
    })

    describe("getPrice", async () => {
        it ("get correct price", async () => {
            await token.approve(exchange.address, toWei(200));
            await exchange.addLiquidity(toWei(200), {value : toWei(100)});

            ethReserve = await getBalance(exchange.address);
            tokenReserve = await exchange.getReserve();

            expect(await exchange.getPrice(ethReserve, tokenReserve)).to.equal(500);
            expect(await exchange.getPrice(tokenReserve, ethReserve)).to.equal(2000);

        })
    })

    describe("getTokenAmount", async () => {
        it ("get correct token amount", async () => {
            await token.approve(exchange.address, toWei(200));
            await exchange.addLiquidity(toWei(200), {value : toWei(100)});

            expect(await exchange.getTokenAmount(toWei(100))).to.equal(toWei(100));
        })
    })

    describe("getEthAmount", async () => {
        it ("get correct eth amount", async () => {
            await token.approve(exchange.address, toWei(200));
            await exchange.addLiquidity(toWei(200), {value : toWei(100)});

            expect(await exchange.getEthAmount(toWei(50))).to.equal(toWei(20));
        })
    })
})