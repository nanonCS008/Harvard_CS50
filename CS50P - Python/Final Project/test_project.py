import os
import sqlite3
import pytest
from project import createDatabase, addEmployee, editEmployee, deleteEmployee, viewEmployee, pause, figlet

def test_createDatabase():
    db_file = 'employee.db'
    createDatabase()
    assert os.path.isfile(db_file)

    conn = sqlite3.connect(db_file)
    query = conn.cursor()
    query.execute("PRAGMA table_info(employees)")
    columns = query.fetchall()
    print(columns)
    expected_columns = [(0, 'id', 'INTEGER', 0, None, 1),
                        (1, 'name', 'TEXT', 1, None, 0),
                        (2, 'position', 'TEXT', 1, None, 0),
                        (3, 'salary', 'REAL', 1, None, 0)]
    assert columns == expected_columns
    conn.close()
    os.remove('employee.db')


def test_addEmployee():
    createDatabase()
    input = ['John Harvard', 'Software Developer', '50000']

    with pytest.MonkeyPatch.context() as m:
        m.setattr('builtins.input', lambda _: input.pop(0))
        addEmployee()

    conn = sqlite3.connect('employee.db')
    query = conn.cursor()
    query.execute('SELECT * FROM employees WHERE name = "John Harvard"')
    employee = query.fetchone()

    assert employee is not None
    assert employee[1] == 'John Harvard'
    assert employee[2] == 'Software Developer'
    assert employee[3] == 50000.0
    conn.close()
    os.remove('employee.db')


def test_editEmployee():
    createDatabase()
    input = ['1', 'King Lion', 'Software Developer', '60000']

    conn = sqlite3.connect('employee.db')
    cursor = conn.cursor()
    cursor.execute('INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)', ('John Harvard', 'Software Developer', 50000))
    conn.commit()
    conn.close()

    with pytest.MonkeyPatch.context() as m:
        m.setattr('builtins.input', lambda _: input.pop(0))
        editEmployee()

    conn = sqlite3.connect('employee.db')
    query = conn.cursor()
    query.execute('SELECT * FROM employees WHERE id = 1')
    employee = query.fetchone()

    assert employee is not None
    assert employee[1] == 'King Lion'
    assert employee[2] == 'Software Developer'
    assert employee[3] == 60000.0
    conn.close()
    os.remove('employee.db')


def test_deleteEmployee():
    createDatabase()
    input = ['1', 'y']

    conn = sqlite3.connect('employee.db')
    query = conn.cursor()
    query.execute('INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)', ('John Harvad', 'Software Developer', 50000))
    conn.commit()

    with pytest.MonkeyPatch.context() as m:
        m.setattr('builtins.input', lambda _: input.pop(0))
        deleteEmployee()

    query.execute('SELECT * FROM employees WHERE id = 1')
    employee = query.fetchall()
    assert not employee

    conn.close()
    os.remove('employee.db')


def test_viewEmployee():
    createDatabase()
    conn = sqlite3.connect('employee.db')
    cursor = conn.cursor()
    cursor.execute('INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)', ('John Harvard', 'Software Developer', 50000))
    cursor.execute('INSERT INTO employees (name, position, salary) VALUES (?, ?, ?)', ('Jayden Smith', 'Accountant', 60000))
    conn.commit()

    employees = viewEmployee()
    assert employees == employees

    conn.close()
