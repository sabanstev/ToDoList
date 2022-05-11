// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title To-do list
/// @author Sabantsev Aleksandr
/// @notice You can create and delete tasks for yourself, as well as find out information about your tasks. You can calculate the percentage of completed tasks
/// @dev Fixed error in percentage calculation, code formatted according to documentation
contract TodoList {
    struct Task {
        uint code; // Имя задачи
        string description; // Описание задачи
        uint deadline; // Время на выполнение
        bool completed; // Если True то задача выполнена 
        bool overdue; // Если True то задача просрочена
        bool trashed; // Если True то задача удалена и её не учитывать  
    }

    mapping(address => Task[]) todoList; // Для каждого адреса свой массив со списком задач

    /// @notice Triggered when a new task is created
    /// @param userAddress The address of the account that called the function
    /// @param code Task code
    /// @param deadline Task deadline
    event AddNewTask(address indexed userAddress, uint indexed code, uint deadline); // Фиксируем кто создал, code и deadline
    /// @notice Triggered task when change status
    /// @param userAddress The address of the account that called the function
    /// @param code Task code
    /// @param completed Is the task completed
    event ChangeStatus(address indexed userAddress, uint indexed code, bool completed); // Фиксируем кто изменил, какую задачу и на какой статус

    /// @notice Create a new task
    /// @param _code Task code
    /// @param _description Task decription
    /// @param _deadline Task deadline
    function addTask(uint _code, string memory _description, uint _deadline) external { // Создание новой задачи

        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            require(todoList[msg.sender][i].code == _code, "This code is already taken"); // Если в массиве пользователя еже есть такой код, то ошибка
        } 

        Task memory newTask = Task({
            code: _code,
            description: _description,
            deadline: block.timestamp + _deadline, // Время сейчас + время на задачу
            completed: false,
            overdue: false,
            trashed: false
        });

       todoList[msg.sender].push(newTask); // Добавили новую задачу в массив для msg.sender
       emit AddNewTask(msg.sender, _code, _deadline); // Фиксируем кто создал, code и deadline
    }

    /// @notice Deleting a task. After deletion, the task is not taken into account
    /// @param _code Task code
    function deleteTask(uint _code) external {
        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if(todoList[msg.sender][i].code == _code) { // Находим нужную задачу
                todoList[msg.sender][i].trashed = true; // Помечаем как удалённую
                break; // Цикл можно прекратить т.к. code не повторяется, экономим газ
            }
        }
    }

    /// @notice Changes the status of a task to the opposite
    /// @param _code Task code
    function changeTaskStatus(uint _code) external {
        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if(todoList[msg.sender][i].code == _code) { // Находим нужную задачу
                todoList[msg.sender][i].completed = !(todoList[msg.sender][i].completed); // Меняем статус
                if(todoList[msg.sender][i].completed == true) { // Если статус задачи изменён на выполнено, то проверяем просрочена она или нет
                    todoList[msg.sender][i].overdue = todoList[msg.sender][i].deadline <= block.timestamp ? true : false; // Если текущее время больше чем время дедлайна, то задача просрочена
                }
                emit ChangeStatus(msg.sender, _code, todoList[msg.sender][i].completed);
                break; // Цикл можно прекратить т.к. code не повторяется, экономим газ
            }
        }
    }

    /// @notice Provides information about the specified task
    /// @param _code Task code
    /// @return Returns a string with information about the task
    function getTask(uint _code) external view returns(string memory) { // Получаем конкретную задачу по коду
        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if(todoList[msg.sender][i].code == _code) { // Находим нужную задачу
            return todoList[msg.sender][i].description;
            }
        }
        return "code not found"; // Если код не существует, возвращаем сообщение
    }

    /// @notice Provides information about all tasks of the calling user
    /// @return Returns an array of strings with information about tasks
    function getAllTasks() external view returns(uint[] memory) { // Получаем список всех не удалённых задач
        uint[] memory allTasks;
        uint count;
        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if(todoList[msg.sender][i].trashed == false) { // Если задача не удалена, то добавлеём её код в возвращаемый массив
            allTasks[count] = todoList[msg.sender][i].code;
            count++;
            }
        } 
        return allTasks;
    }

    /// @notice The percentage of completed tasks is calculated, deleted tasks are not counted
    /// @dev When calculating percentages, the denominator is multiplied by one hundred to get an integer value
    /// @return An uint is returned without taking into account the value after the decimal point
    function getPercentageCompletedTasks() external view returns(uint) { // Расчитываем процент выполненных задач
        uint allTask = 1; // Чтобы не было ошибки деления на ноль
        uint completedTask;

        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if((todoList[msg.sender][i].completed == true) && (todoList[msg.sender][i].trashed == false)) { // Находим выполненные не удалённые задачи
            completedTask++;
            }
        }

        for(uint i = 0; i <= todoList[msg.sender].length; i++) { // Проходимся по всему массиву у msg.sender
            if(todoList[msg.sender][i].trashed == false) { // Находим все не удалённые задачи
            allTask++;
            }
        }  

        if(allTask > 1) {
            allTask--;
        }

        return (completedTask * 100) / allTask;
    }

}