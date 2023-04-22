module.exports = async hre => {
  const { deployments, getNamedAccounts, ethers } = hre
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy('Bridge', { from: deployer, args: [], log: true })
}

module.exports.tags = ['Bridge']
module.exports.dependencies = []
