import { task } from "hardhat/config";

export default task("addTask", "description")
    .addParam("contract", "address of the contract")
    .addParam("code", "Code new task")
    .addParam("decription", "Decription new task")
    .addParam("deadline", "Deadline new task in seconds")
    .setAction(async (taskArgs, hre) => {
        const contract = await hre.ethers.getContractAt(
            "ToDoList",
            taskArgs.contract
        );

        await contract.addTask(
            taskArgs.code,
            taskArgs.decription,
            taskArgs.deadline
        );
    });