import { task } from "hardhat/config";

export default task("delete", "description")
    .addParam("contract", "address of the contract")
    .addParam("code", "Task code")
    .setAction(async (taskArgs, hre) => {
        const contract = await hre.ethers.getContractAt(
            "ToDoList",
            taskArgs.contract
        );

        await contract.deleteTask(
            taskArgs.code
        );
    });