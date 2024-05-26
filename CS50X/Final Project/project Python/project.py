import os
import sqlite3
from tabulate import tabulate
from pyfiglet import Figlet

def main():
    createDatabase()
    while True:
        os.system('clear')
        figlet("Welcome to employee's system")
        try:
            option = int(input("Main Menu\n1. View employees.\n2. Add employees.\n3. Update employees.\n4. Delete employees.\n5. Exit.\nEnter your choice: "))

            match option:
                case 1:
                    viewEmployee()
                    pause()
                case 2:
                    addEmployee()
                    pause()
                case 3:
                    editEmployee()
                    pause()
                case 4:
                    deleteEmployee()
                    pause()
                case 5:
                    os.system('clear')
                    figlet("Thanks for using. Goodbyt!")
                    pause()
                    os.system('clear')
                    break
                case _:
                    print("Option invalid. Please try again.")
                    pause()
        except ValueError:
            print("\nOption invalid. Please try again.")
            pause()

def addEmployee():
    os.system('clear')
    figlet("Add employee")
    try:
        conn = sqlite3.connect("employee.db")

        name = input("Employee's name: ")
        position = input("Employee's position: ")
        salary = float(input("Employee's salary: "))

        query = conn.cursor()
        query.execute('INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)', (name, position, salary))
        conn.commit()

        print("\nEmployee added successfully.")
    except sqlite3.Error:
        print("\nError connect database.")
    except ValueError:
        print("\nData invalid.")
    finally:
        conn.close()


def editEmployee():
    os.system('clear')
    figlet("Edit employee")
    try:
        conn = sqlite3.connect("employee.db")

        employeeId = int(input("Employee's Id: "))

        query = conn.cursor()
        query.execute('SELECT * FROM employees WHERE id = ?', (employeeId,))
        employee = query.fetchone()

        if employee:
            print(f"Employee found.\nEmployee: {employee[1]}, {employee[2]}, {employee[3]}")
            print("\nEnter new information (leave blank to keep current): ")
            newName = input(f"Enter new name: ")
            newPosition = input(f"Enter new position: ")
            newSalary = float(input(f"Enter new salary: "))

            newName = newName.strip() if newName.strip() else employee[1]
            newPosition = newPosition.strip() if newPosition.strip() else employee[2]
            newSalary = newSalary if newSalary else employee[3]

            updateQuery = 'UPDATE employees SET name = COALESCE(?, name), position = COALESCE(?, position), salary = COALESCE(?, salary) WHERE id = ?'
            query.execute(updateQuery, (newName, newPosition, newSalary, employeeId))
            conn.commit()

            print("\nEmployee information updated successfully.")
        else:
            print("\nEmployee not found.")
    except sqlite3.Error:
        print("Error connect database.")
    except ValueError:
        print("\nData invalid.")
    finally:
        conn.close()


def deleteEmployee():
    os.system('clear')
    figlet("Delete employee")
    try:
        conn = sqlite3.connect("employee.db")

        employeeId = int(input("Employee's Id: "))

        query = conn.cursor()
        query.execute('SELECT * FROM employees WHERE id = ?', (employeeId,))
        employee = query.fetchone()

        if employee:
            print(f"Employee found.\nEmployee: {employee[1]}, {employee[2]}, {employee[3]}")
            option = input("\nAre you sure you want to delete it? (y/n): ")

            if option == "y" or option == "Y":
                query.execute('DELETE FROM employees WHERE id = ?', (employeeId,))
                conn.commit()
                print("\nEmployee deleted successfully.")
        else:
            print("\nEmployee not found.")
    except sqlite3.Error:
        print("\nError connect database.")
    except ValueError:
        print("\nData invalid.")
    finally:
        conn.close()


def viewEmployee():
    os.system('clear')
    figlet("View employee")
    try:
        conn = sqlite3.connect("employee.db")
        query = conn.cursor()
        query.execute('SELECT * FROM employees')
        employees = query.fetchall()

        if employees:
            headers = ['ID', 'Name', 'Position', 'Salary']
            print(tabulate(employees, headers = headers, tablefmt = 'grid'))
        else:
            print("No employees found.")
    except sqlite3.Error:
        print("\nError connect database.")
    finally:
        conn.close()


def pause():
    input("Press Enter to continue...")


def figlet(text):
    figlet = Figlet()
    figlet = Figlet(font="mini")
    print(figlet.renderText(text))


def createDatabase():
    conn = sqlite3.connect("employee.db")
    query = conn.cursor()
    query.execute('CREATE TABLE IF NOT EXISTS employees (id INTEGER PRIMARY KEY, name TEXT NOT NULL, position TEXT NOT NULL, salary REAL NOT NULL)')
    conn.commit()
    conn.close()

if __name__ == "__main__":
    main()
