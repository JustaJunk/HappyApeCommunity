import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer, boss, kingsley, artist, developer } = await hre.getNamedAccounts();

    // the following will only deploy "GenericMetaTxProcessor" if the contract was never deployed or if the code changed since last deployment
    const happyApe = await deploy("HappyApe", {
        from: deployer,
        args: [
            [boss,  kingsley,   artist, developer],
            [85,    5,          5,      5]
        ],
        // gasPrice: 100000000000,
    });

    if (happyApe.receipt?.status) {
        console.log("HappyApe deployed to:", happyApe.address);
    }
    else {
        console.log("Deploy Error!");
    }
};
export default func;
func.tags = ['HappyApe'];