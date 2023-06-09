module.exports = async hre => {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy('ValueArrayTester', {
    from: deployer,
    args: [],
    log: true,
  })
}

module.exports.tags = ['ValueArrayTester', 'test']
module.exports.dependencies = []
