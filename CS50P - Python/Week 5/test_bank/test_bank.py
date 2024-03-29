import pytest
from bank import value

def main():
    test_value()

def test_value():
    assert value("hello") == 0
    assert value("HELLO") == 0
    assert value("hi") == 20
    assert value("HI") == 20
    assert value("wey") == 100
    assert value("WEY") == 100

if __name__ == "__main__":
    main()
