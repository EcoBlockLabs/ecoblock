module.exports = async hre => {
  const { deployments, getNamedAccounts, ethers } = hre
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy('BridgeStub', { from: deployer, args: [], log: true })
}

module.exports.tags = ['BridgeStub', 'test']
module.exports.dependencies = []
