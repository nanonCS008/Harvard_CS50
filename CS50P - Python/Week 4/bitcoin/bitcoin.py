import requests
import sys

def bitcoinPrice():
    try:
        response = requests.get("https://api.coindesk.com/v1/bpi/currentprice.json")
        response.raise_for_status()
        data = response.json()
        return float(data["bpi"]["USD"]["rate_float"])
    except (requests.RequestException, KeyError, ValueError):
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Missing command-line argument")
        sys.exit(1)

    try:
        bitcoins = float(sys.argv[1])
    except ValueError:
        print("Command-line argument is not a number")
        sys.exit(1)

    total = bitcoins * bitcoinPrice()

    print(f"${total:,.4f}")


if __name__ == "__main__":
    main()
