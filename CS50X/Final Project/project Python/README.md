
# CS50x
#### Video Demo: 

## Description
This is my final project for "Harvard CS50 Introduction to Computer Science".
The project is an employee registration or payroll system developed in Python using an SQLite database to store the information.

The program offers the following functionalities:
1. Add Employee: Allows the user to enter the name, position and salary of a new employee, which is then stored in the database.
2. Edit Employee: Allows the user to modify the information of an existing employee in the database. The user can choose which fields they want to update (name, position or salary).
3. Delete Employee: Allows the user to delete an employee from the database using their ID.
4. View Employees: Displays a table with all employees registered in the database, including their ID, name, position and salary.

## Installation & Use
1. Clone the code.
1. Run the command `pip install -r requirements.txt` in the app directory.
2. Than run it: `python project.py`

## Overviews
```

\    /_ | _ _ ._ _  _  _|_ _   _ ._ _ ._ | _    _  _/ _  _   __|_ _ ._ _
 \/\/(/_|(_(_)| | |(/_  |_(_) (/_| | ||_)|(_)\/(/_(/__> _>\/_> |_(/_| | |
                                      |      /            /

Main Menu
1. View employees.
2. Add employees.
3. Update employees.
4. Delete employees.
5. Exit.
Enter your choice:
```
```
\  /o _       _ ._ _ ._ | _    _  _
 \/ |(/_\/\/ (/_| | ||_)|(_)\/(/_(/_
                     |      /

No employees found.
Press Enter to continue...
```
```

 /\  _| _|  _ ._ _ ._ | _    _  _
/--\(_|(_| (/_| | ||_)|(_)\/(/_(/_
                   |      /

Employee's name: King Lion
Employee's position: Developer
Employee's salary: 60000

Employee added successfully.
Press Enter to continue...
```
```
 _
|_ _|o_|_  _ ._ _ ._ | _    _  _
|_(_|| |_ (/_| | ||_)|(_)\/(/_(/_
                  |      /

Employee's Id: 1
Employee found.
Employee: King Lion, Developer, 60000.0

Enter new information (leave blank to keep current):
Enter new name: King Lion
Enter new position: Software Developer
Enter new salary: 65000

Employee information updated successfully.
Press Enter to continue...
```
```
 _
| \ _ | __|_ _   _ ._ _ ._ | _    _  _
|_/(/_|(/_|_(/_ (/_| | ||_)|(_)\/(/_(/_
                        |      /

Employee's Id: 1
Employee found.
Employee: King Lion, Software Developer, 65000.0

Are you sure you want to delete it? (y/n): y

Employee deleted successfully.
Press Enter to continue...
```
```
___               _                    __
 ||_  _.._ |  _ _|__ ._     _o._  _   /__ _  _  _||_  _|_|
 || |(_|| ||<_>  |(_)|  |_|_>|| |(_|o \_|(_)(_)(_||_)\/|_o
                                  _|                 /

Press Enter to continue...
```
