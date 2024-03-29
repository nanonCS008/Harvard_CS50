def main():
    file = input("File name: ").lower().strip()
    print(getMedia(file))

def getMedia(file):
    extension = file.split('.')[-1]
    media = ""
    
    match extension:
        case "gif" | "jpeg" | "png":
            media = "image/" + extension
        case "jpg":
            media = "image/jpeg"
        case "pdf":
            media = "application/" + extension
        case "txt":
            media = "text/plain"
        case "zip":
            media = "application/zip"
        case _:
            media = "application/octet-stream"

    return media

main()
