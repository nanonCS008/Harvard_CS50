import emoji

prompt = input("Input: ")

emojized = emoji.emojize(prompt, language="alias")

print("Output:", emojized)
