const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const namehash = require("@ensdomains/eth-ens-namehash");

describe("Axelar Test Suite: ", function () {
  let owner,
    user1,
    user2,
    OnsFactory,
    AxelarMessengerFactory,
    AxelarMockFactory,
    onsA,
    onsB,
    onsC,
    axelarMessengerA,
    axelarMessengerB,
    axelarMessengerC,
    mock;

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    OnsFactory = await ethers.getContractFactory("Generic_ONS");
    AxelarMessengerFactory = await ethers.getContractFactory("AxlearMessenger");
    AxelarMockFactory = await ethers.getContractFactory("AxelarGatewayGasServiceMock");
  });

  beforeEach(async function () {
    mock = await AxelarMockFactory.deploy();
    axelarMessengerA = await AxelarMessengerFactory.deploy(mock.address, mock.address);
    axelarMessengerB = await AxelarMessengerFactory.deploy(mock.address, mock.address);
    axelarMessengerC = await AxelarMessengerFactory.deploy(mock.address, mock.address)
    onsA = await OnsFactory.deploy("OnsA", "ONSA", axelarMessengerA.address);
    onsB = await OnsFactory.deploy("OnsB", "ONSB", axelarMessengerB.address);
    onsC = await OnsFactory.deploy("OnsC", "ONSC", axelarMessengerC.address);

    await axelarMessengerA.setup(onsA.address, ["arb","avax"], [onsB.address, onsC.address]);
    await axelarMessengerB.setup(onsB.address, ["eth", "avax"], [onsA.address, onsC.address]);
    await axelarMessengerC.setup(onsC.address, ["eth", "arb"], [onsA.address, onsB.address]);
  });

  it.only("Mint domain and verify propagate", async function () {
    let nativeFee = ethers.utils.parseEther("1");
    let andrewNameHash = namehash.hash("andrew.eth");

    // verify doesn't exist
    expect(await onsA.registeredName(andrewNameHash)).to.equal(false);
    expect(await onsB.registeredName(andrewNameHash)).to.equal(false);
    expect(await onsC.registeredName(andrewNameHash)).to.equal(false);

    // mint andrew.eth
    await onsA.connect(user1).mint(user1.address, andrewNameHash, user1.address, {value: nativeFee});

    // verify it exists
    expect(await onsA.registeredName(andrewNameHash)).to.equal(true);
    expect(await onsB.registeredName(andrewNameHash)).to.equal(true);
    expect(await onsC.registeredName(andrewNameHash)).to.equal(true);
  });
});