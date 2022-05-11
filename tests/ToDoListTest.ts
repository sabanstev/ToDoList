import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ToDoList } from "../typechain";

describe("ToDoList", function () {
    let contract: ToDoList;
    let owner: SignerWithAddress;
    let code: number = 1;
    let description: string = "Start";
    let deadline: number = 1000;
    it("deploy", async () => {
        [owner] = await ethers.getSigners();
        const ToDoList = await ethers.getContractFactory(
            "ToDoList"
        );
        contract = await ToDoList.deploy(); // Разворачиваем контракт
        await contract.deployed();
    });

    it("should be deployed", async function() {
        expect(contract.address).to.be.properAddress // Проверяем корректность адреса
    });

    it("Add new task", async function () {
        await expect(
            contract.addTask(code, description, deadline) // Создаём новую задачу
        );
    });

    it("Add new task with the same code", async function () {
        await expect(
            contract.addTask(code, description, deadline) // Создаём новую задачу с тем же кодом, возвращается сообщение
        ).to.be.revertedWith("This code is already taken");
    });

    it("Get task", async function () {
        await expect(
            contract.getTask(code)
        ).to.equal("Start");
    });
});