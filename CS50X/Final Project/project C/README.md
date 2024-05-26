
# CS50x


## Description
This is my final project for "Harvard CS50's Introduction to Computer Science".
This is a comprehensive employee management system developed in C as a final project for a programming course. The system provides a user-friendly interface for managing employee records efficiently. It uses a text file as the backend database to store employee information.

The program offers the following functionalities:
1. Add Employee: Allows the user to enter the name, position, and salary of a new employee, which is then stored in the text file.
2. Edit Employee: Allows the user to modify the information of an existing employee in the text file. The user can choose which fields they want to update (name, position, or salary).
3. Delete Employee: Allows the user to delete an employee from the text file using their ID.
4. View Employees: Displays a table with all employees registered in the text file, including their ID, name, position, and salary.

## Installation & Use
1. Clone the code.
2. Compile the program using `gcc -o employee_system employee_system.c`.
3. Run the compiled program: `./employee_system`.

## Overviews
```
Welcome to employee's system
Main Menu
1. View employees.
2. Add employees.
3. Update employees.
4. Delete employees.
5. Exit.
Enter your choice:
```
```
View employees
No employees found.
Press Enter to continue...
```
```
Add employee
Employee's name: John
Employee's position: Developer
Employee's salary: 60000

Employee added successfully.
Press Enter to continue...
```
```
Edit employee
Employee's Id: 1
Employee found.

Edit employee
Employee's Id: 1
Employee found.
Employee: John, Developer, 65000.00

Enter new information (leave blank to keep current):
Enter new name: John
Enter new position: Developer
Enter new salary: 70000

Employee information updated successfully.
Press Enter to continue...
```
```
Delete employee
Employee's Id: 1
Employee found.
Employee: John, Developer, 70000.00

Are you sure you want to delete it? (y/n): y

Employee deleted successfully.
Press Enter to continue...
```
```
Thanks for using. Goodbye!
Press Enter to continue...
```
