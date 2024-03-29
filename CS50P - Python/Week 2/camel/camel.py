camel = input("camelCase: ")

if camel.islower():
    print("snake_case:", camel)
else:
    snake = ""
    for char in camel:
        if char.isupper():
            snake += "_" + char.lower()
        else:
            snake += char

    print(snake)
