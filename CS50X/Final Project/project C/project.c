#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FILENAME "employees.txt"

typedef struct
{
    int id;
    char name[100];
    char position[100];
    double salary;
} Employee;

void createDatabase();
void viewEmployee();
void addEmployee();
void editEmployee();
void deleteEmployee();
void pause();
void clearScreen();
void printTitle(const char *title);
void saveEmployees(Employee *employees, int count);
int loadEmployees(Employee **employees);
int getNextId(Employee *employees, int count);

int main()
{
    createDatabase();

    while (1)
    {
        clearScreen();
        printTitle("Welcome to employee's system");
        int option;

        printf("Main Menu\n1. View employees.\n2. Add employees.\n3. Update employees.\n4. Delete "
               "employees.\n5. Exit.\nEnter your choice: ");

        if (scanf("%d", &option) != 1)
        {
            printf("\nOption invalid. Please try again.\n");
            pause();
            while (getchar() != '\n')
                ;
            continue;
        }

        switch (option)
        {
            case 1:
                viewEmployee();
                pause();
                break;
            case 2:
                addEmployee();
                pause();
                break;
            case 3:
                editEmployee();
                pause();
                break;
            case 4:
                deleteEmployee();
                pause();
                break;
            case 5:
                clearScreen();
                printTitle("Thanks for using. Goodbye!");
                pause();
                clearScreen();
                exit(0);
            default:
                printf("Option invalid. Please try again.\n");
                pause();
                break;
        }
    }

    return 0;
}

void createDatabase()
{
    FILE *file = fopen(FILENAME, "a");
    if (file == NULL)
    {
        printf("Error creating database file.\n");
    }
    else
    {
        fclose(file);
    }
}

void viewEmployee()
{
    clearScreen();
    printTitle("View employees");

    Employee *employees = NULL;
    int count = loadEmployees(&employees);

    if (count == 0)
    {
        printf("No employees found.\n");
    }
    else
    {
        printf("ID\tName\t\tPosition\tSalary\n");
        printf("-------------------------------------------------\n");
        for (int i = 0; i < count; i++)
        {
            printf("%d\t%s\t\t%s\t\t%.2f\n", employees[i].id, employees[i].name,
                   employees[i].position, employees[i].salary);
        }
    }

    free(employees);
}

void addEmployee()
{
    clearScreen();
    printTitle("Add employee");

    Employee *employees = NULL;
    int count = loadEmployees(&employees);

    Employee newEmployee;
    newEmployee.id = getNextId(employees, count);

    printf("Employee's name: ");
    scanf("%s", newEmployee.name);
    printf("Employee's position: ");
    scanf("%s", newEmployee.position);
    printf("Employee's salary: ");
    if (scanf("%lf", &newEmployee.salary) != 1)
    {
        printf("\nData invalid.\n");
        free(employees);
        return;
    }

    employees = realloc(employees, sizeof(Employee) * (count + 1));
    employees[count] = newEmployee;
    saveEmployees(employees, count + 1);

    printf("\nEmployee added successfully.\n");
    free(employees);
}

void editEmployee()
{
    clearScreen();
    printTitle("Edit employee");

    Employee *employees = NULL;
    int count = loadEmployees(&employees);

    if (count == 0)
    {
        printf("No employees found.\n");
        return;
    }

    int employeeId;
    printf("Employee's Id: ");
    if (scanf("%d", &employeeId) != 1)
    {
        printf("\nData invalid.\n");
        free(employees);
        return;
    }

    for (int i = 0; i < count; i++)
    {
        if (employees[i].id == employeeId)
        {
            printf("Employee found.\nEmployee: %s, %s, %.2f\n", employees[i].name,
                   employees[i].position, employees[i].salary);
            printf("\nEnter new information (leave blank to keep current): \n");

            char newName[100], newPosition[100];
            double newSalary;

            printf("Enter new name: ");
            scanf("%s", newName);
            if (strlen(newName) > 0)
            {
                strcpy(employees[i].name, newName);
            }

            printf("Enter new position: ");
            scanf("%s", newPosition);
            if (strlen(newPosition) > 0)
            {
                strcpy(employees[i].position, newPosition);
            }

            printf("Enter new salary: ");
            if (scanf("%lf", &newSalary) == 1)
            {
                employees[i].salary = newSalary;
            }

            saveEmployees(employees, count);
            printf("\nEmployee information updated successfully.\n");
            free(employees);
            return;
        }
    }

    printf("\nEmployee not found.\n");
    free(employees);
}

void deleteEmployee()
{
    clearScreen();
    printTitle("Delete employee");

    Employee *employees = NULL;
    int count = loadEmployees(&employees);

    if (count == 0)
    {
        printf("No employees found.\n");
        return;
    }

    int employeeId;
    printf("Employee's Id: ");
    if (scanf("%d", &employeeId) != 1)
    {
        printf("\nData invalid.\n");
        free(employees);
        return;
    }

    for (int i = 0; i < count; i++)
    {
        if (employees[i].id == employeeId)
        {
            printf("Employee found.\nEmployee: %s, %s, %.2f\n", employees[i].name,
                   employees[i].position, employees[i].salary);
            char option;
            printf("\nAre you sure you want to delete it? (y/n): ");
            scanf(" %c", &option);

            if (option == 'y' || option == 'Y')
            {
                for (int j = i; j < count - 1; j++)
                {
                    employees[j] = employees[j + 1];
                }

                saveEmployees(employees, count - 1);
                printf("\nEmployee deleted successfully.\n");
                free(employees);
                return;
            }
            else
            {
                printf("\nDeletion cancelled.\n");
                free(employees);
                return;
            }
        }
    }

    printf("\nEmployee not found.\n");
    free(employees);
}

void pause()
{
    printf("Press Enter to continue...");
    while (getchar() != '\n')
        ;
    getchar();
}

void clearScreen()
{
    printf("\033[H\033[J");
}

void printTitle(const char *title)
{
    printf("\n%s\n", title);
}

void saveEmployees(Employee *employees, int count)
{
    FILE *file = fopen(FILENAME, "w");
    if (file == NULL)
    {
        printf("Error opening file for writing.\n");
        return;
    }

    for (int i = 0; i < count; i++)
    {
        fprintf(file, "%d %s %s %.2f\n", employees[i].id, employees[i].name, employees[i].position,
                employees[i].salary);
    }

    fclose(file);
}

int loadEmployees(Employee **employees)
{
    FILE *file = fopen(FILENAME, "r");
    if (file == NULL)
    {
        *employees = NULL;
        return 0;
    }

    int count = 0;
    Employee temp;
    while (fscanf(file, "%d %s %s %lf", &temp.id, temp.name, temp.position, &temp.salary) == 4)
    {
        *employees = realloc(*employees, sizeof(Employee) * (count + 1));
        (*employees)[count++] = temp;
    }

    fclose(file);
    return count;
}

int getNextId(Employee *employees, int count)
{
    int maxId = 0;
    for (int i = 0; i < count; i++)
    {
        if (employees[i].id > maxId)
        {
            maxId = employees[i].id;
        }
    }

    return maxId + 1;
}
