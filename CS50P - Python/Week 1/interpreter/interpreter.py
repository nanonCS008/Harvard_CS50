def main():
    expression = input("Expression: ")
    print(operation(expression))

def operation(expression):
    x = int(expression.split()[0])
    y = int(expression.split()[2])
    operator = expression.split()[1]

    match operator:
        case '+':
            return float(x + y)
        case '-':
            return float(x - y)
        case '*':
            return float(x * y)
        case '/':
            return float(x / y)

main()
